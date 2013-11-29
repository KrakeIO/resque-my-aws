# Spins up an AWS EC2 instance

# dependencies
exec = require("child_process").exec
getAwsClient = require '../helper/get_aws_client'
Kraken = require '../model/kraken'



# @Description: Launches a EC2 Instance and when the instance is ready awakens the monster within.
# @param: awsRegion:String
# @param: imageId:String
# @param: securityGroup:String
# @param: instanceType:String
# @param: shellScriptParams:Array[String]
# @param: callback:function()
summonTheKraken = (awsRegion, imageId, securityGroup, instanceType, shellScriptParams, callback)->
  console.log new Date() + '[SUMMON] : Summoning a Kraken'
  
  summoning_options = 
    ImageId : imageId
    MinCount : 1
    MaxCount : 1
    SecurityGroups : [securityGroup]
    InstanceType : instanceType
  
  ec2Client = getAwsClient awsRegion
  ec2Client.runInstances summoning_options, (err, data)=>
    if err then console.log  new Date() + ' [SUMMON] %s', err
    
    for x in [0...data.Instances.length]
      console.log new Date() + ' [SUMMON] %s : Checking the status of our kraken', data.Instances[x].InstanceId
      instanceId = data.Instances[x].InstanceId
      nameTheKraken awsRegion, instanceId, shellScriptParams
      awakenTheKraken awsRegion, instanceId, (err, currInstanceId)=>
        if err
          console.log new Date() + ' [SUMMON] Error — Line 190 \n\t\t%s', err
          callback && callback(new Error(err))
          
        else
          console.log  new Date() + ' [SUMMON] %s : Kraken sent for unleashing' +
            '\n\t\t%s', currInstanceId, awsRegion
            
          resque = require('coffee-resque').connect({
            host: REDIS_HOST,
            port: REDIS_PORT
          })
          
          resque.enqueue( 'aws', 'unleash', [awsRegion, currInstanceId, shellScriptParams] )
          callback && callback()



# @Description: goes into a recursive loop base case till when the instance is up and ready
#   When instance is up and ready, we name the kraken and unleash it
# @params: awsRegion:string
# @params: instanceId:string
awakenTheKraken = (awsRegion, instanceId, callback)=>

  Kraken.getByID awsRegion, instanceId, (err, kraken)->
    if err
      console.log  new Date() + ' [SUMMON] %s : ERROR with instance\n\t\t%s', instanceId, err
      callback && callback(err, instanceId)
              
    else if !kraken == 0
      console.log  new Date() + ' [SUMMON] %s : The Kraken remains a myth. It cannot be unleashed.', instanceId      
        
    else if kraken
      
      switch kraken.State.Code
        when 16 
          console.log new Date() + ' [SUMMON] %s : The kraken is awake.', instanceId
          callback && callback(null, instanceId)

        when 0
          console.log new Date() + ' [SUMMON] %s : The kraken is still waking up. Recheck in 5secs', instanceId
          setTimeout ()=>
            awakenTheKraken awsRegion, instanceId, callback 
          , 10000
          
        else
          console.log new Date() + ' [SUMMON] %s : The kraken is dead. It will never wake up', instanceId          
          callback && callback("The Krake is dead", instanceId)



# @Description: Tags a kraken in a name for better viewing AWS console
# @param awsRegion:String
# @param instanceId:String
# @param: params:Array[String]
nameTheKraken = (awsRegion, instanceId, shellScriptParams)=>
  console.log new Date() + ' [SUMMON] %s : writing shell script parameters to krake', instanceId
  paramsLength = shellScriptParams.length - 1
  tags = []
  for x in [0..paramsLength]
    currTag =
      Key : x + ""
      Value : shellScriptParams[x]

    tags.push currTag
    
  options = 
    Resources : [instanceId],
    Tags : tags  
  
  ec2Client = getAwsClient awsRegion
  ec2Client.createTags options, (err, data)=>
    if err
      console.log new Date() + ' [SUMMON] %s : cannot name Kraken ' + 
        '\n\t\tERROR : %s', instanceId, err
      
    else 
      console.log new Date() + ' [SUMMON] %s : Shell script parameters written', instanceId



module.exports = summonTheKraken

