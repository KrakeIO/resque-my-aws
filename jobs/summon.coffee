# Spins up an AWS EC2 instance

# dependencies
exec = require("child_process").exec
getAwsClient = require './helper/get_aws_client'
getKraken = require './helper/get_kraken'



# @Description: Launches a EC2 Instance and when the instance is ready awakens the monster within.
# @param: awsRegion:String
# @param: imageId:String
# @param: securityGroup:String
# @param: instanceType:String
# @param: minCount:String
# @param: maxCount:String
# @param: callback:function()
summonTheKraken = (awsRegion, imageId, securityGroup, instanceType, minCount, maxCount, queueName, eventName, callback)->

  summoning_options = 
    ImageId : imageId
    MinCount : minCount || 1
    MaxCount : maxCount || 1
    SecurityGroups : [securityGroup]
    InstanceType : instanceType
  
  ec2Client = getAwsClient awsRegion
  ec2Client.runInstances summoning_options, (err, data)=>
    if err then console.log '[NETWORK_SUPERVISOR] %s', err
    
    console.log typeof data.Instances
    for x in [0...data.Instances.length]
      console.log '[NETWORK_SUPERVISOR] %s : Checking the status of our kraken', data.Instances[x].InstanceId
      instanceId = data.Instances[x].InstanceId
      nameTheKraken awsRegion, instanceId, queueName, eventName
      awakenTheKraken awsRegion, instanceId, (err, currInstanceId)=>
        if err
          console.log '[NETWORK_SUPERVISOR] Error — Line 190 \n\t\t%s', err
          callback && callback(new Error(err))
          
        else
          console.log '[NETWORK_SUPERVISOR] %s : Kraken added to unleash pool' +
            '\n\t\t%s', currInstanceId, awsRegion
            
          resque = require('coffee-resque').connect({
            host: REDIS_HOST,
            port: REDIS_PORT
          })
          
          resque.enqueue( 'aws', 'unleash', [awsRegion, currInstanceId, queueName, eventName] )
          callback && callback()



# @Description: goes into a recursive loop base case till when the instance is up and ready
#   When instance is up and ready, we name the kraken and unleash it
# @params: awsRegion:string
# @params: instanceId:string
awakenTheKraken = (awsRegion, instanceId, callback)=>

  getKraken awsRegion, instanceId, (err, kraken)->
    if err
      console.log '[NETWORK_SUPERVISOR] %s : ERROR with instance\n\t\t%s', instanceId, err
      callback && callback(err, instanceId)
              
    else if !kraken == 0
      console.log '[NETWORK_SUPERVISOR] %s : The Kraken remains a myth. It cannot be unleashed.', instanceId      
        
    else if kraken
      
      switch kraken.State.Code
        when 16 
          console.log '[NETWORK_SUPERVISOR] %s : The kraken is awake.', instanceId
          callback && callback(null, instanceId)

        when 0
          console.log '[NETWORK_SUPERVISOR] %s : The kraken is still waking up. Recheck in 5secs', instanceId
          setTimeout ()=>
            awakenTheKraken awsRegion, instanceId, callback 
          , 10000
          
        else
          console.log '[NETWORK_SUPERVISOR] %s : The kraken is dead. It will never wake up', instanceId          
          callback && callback("The Krake is dead", instanceId)



# @Description: Tags a kraken in a name for better viewing AWS console
# @param awsRegion:String
# @param instanceId:String
nameTheKraken = (awsRegion, instanceId, queueName, eventName)=>
  console.log '[NETWORK_SUPERVISOR] %s : naming the krake', instanceId
  options = 
    Resources : [instanceId],
    Tags : [{
        Key : 'Name'
        Value : queueName + ' > ' + eventName
      },{
        Key : 'taskQueue'
        Value : queueName
      },{
        Key : 'eventEnqueue'
        Value : eventName     
    }]    
  
  ec2Client = getAwsClient awsRegion
  ec2Client.createTags options, (err, data)=>
    if err
      console.log '[NETWORK_SUPERVISOR] %s : cannot name Kraken ' + 
        '\n\t\tERROR : %s', instanceId, err
      
    else 
      console.log '[NETWORK_SUPERVISOR] %s : Kraken has been named', instanceId



module.exports = summonTheKraken

