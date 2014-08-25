# Spins up an AWS EC2 instance

# dependencies
exec            = require("child_process").exec
getAwsClient    = require '../helper/get_aws_client'
Kraken          = require '../model/kraken'
redis           = require 'redis'
resqueClient    = require('coffee-resque').connect({
    host: REDIS_HOST,
    port: REDIS_PORT
  })
redisClient     = redis.createClient REDIS_PORT, REDIS_HOST

# @Description: Launches a EC2 Instance and when the instance is ready awakens the monster within.
# @param: awsRegion:String
# @param: imageId:String
# @param: securityGroup:String
# @param: instanceType:String
# @param: shellScriptParams:Array[String]
# @param: callback:function()
summonTheKraken = (awsRegion, imageId, securityGroup, instanceType, shellScriptParams, callback)->
  console.log '%s [SUMMON] : Summoning a Kraken %s', new Date(), shellScriptParams.join()

  redisClient = redis.createClient REDIS_PORT, REDIS_HOST  

  queueName = shellScriptParams[0]
  
  redisClient.multi([
        ["llen", queueName],
        ["get", "#{queueName}_BUSY"]
      ]).exec (err, replies)->
        console.log arguments
        is_busy = replies[0] > 0 || replies[1] == "BUSY"

        if is_busy
          console.log "#{new Date()} [SUMMON] #{queueName} has work to be done. Proceeding to summon EC2"
          spinUpEC2Instance awsRegion, imageId, securityGroup, instanceType, shellScriptParams, 0, callback

        else
          console.log "#{new Date()} [SUMMON] #{queueName} has no work to be done. Not summoning another EC2 instance"
          callback?()



# Spins up an actual EC2 instance
spinUpEC2Instance = (awsRegion, imageId, securityGroup, instanceType, shellScriptParams, retries, callback)->
  summoning_options = 
    ImageId : imageId
    MinCount : 1
    MaxCount : 1
    SecurityGroups : [securityGroup]
    InstanceType : instanceType
  
  ec2Client = getAwsClient awsRegion
  ec2Client.runInstances summoning_options, (err, data)=>

    if err && retries < 3
      console.log '%s [SUMMON] %s retries %s, %s', new Date(), shellScriptParams.join(), retries, err
      spinUpEC2Instance awsRegion, imageId, securityGroup, instanceType, shellScriptParams, retries + 1, callback

    else if (!data.Instances || data.Instances.length == 0) && retries < 3
      console.log '%s [SUMMON] %s no instances were spun up. retries %s', new Date(), shellScriptParams.join(), retries
      spinUpEC2Instance awsRegion, imageId, securityGroup, instanceType, shellScriptParams, retries + 1, callback

    else if retries >= 3
      console.log '%s [SUMMON] %s Finally failed to respin up any EC2 instances after retries %s', new Date(), shellScriptParams.join(), retries
      callback?()

    else    
      for x in [0...data.Instances.length]
        console.log '%s [SUMMON] %s : Checking the status of our kraken', new Date(), data.Instances[x].InstanceId
        instanceId = data.Instances[x].InstanceId
        afterSummon awsRegion, imageId, securityGroup, instanceType, instanceId, shellScriptParams, 0, callback



afterSummon = (awsRegion, imageId, securityGroup, instanceType, instanceId, shellScriptParams, retries, callback)->
  nameTheKraken awsRegion, instanceId, shellScriptParams
  awakenTheKraken awsRegion, instanceId, (err, currInstanceId)=>
    if err
      console.log '%s [SUMMON] %s Error — Line 190 \n\t\t%s %s', new Date(), shellScriptParams.join(), currInstanceId, err

      if retries < 3
        console.log '%s [SUMMON] %s Retrying to awaken\n\t\t%s for %s times', new Date(), shellScriptParams.join(), currInstanceId, retries, err
        afterSummon awsRegion, imageId, securityGroup, instanceType, instanceId, shellScriptParams, retries + 1, callback

      else
        console.log '%s [SUMMON] %s Summoning another Kraken instead. Finally failed with %s — %s', new Date(), shellScriptParams.join(), currInstanceId, err

        resqueClient.enqueue( "aws", "summon", [
          awsRegion, 
          imageId,
          securityGroup, 
          instanceType,
          shellScriptParams ] )

        callback && callback()
      
    else
      console.log  '%s [SUMMON] %s %s : Kraken sent for unleashing' +
        '\n\t\t%s', new Date(), currInstanceId, shellScriptParams.join(), awsRegion
      
      resqueClient.enqueue( 'aws', 'unleash', [awsRegion, currInstanceId, shellScriptParams] )
      callback && callback()



# @Description: goes into a recursive loop base case till when the instance is up and ready
#   When instance is up and ready, we name the kraken and unleash it
# @params: awsRegion:string
# @params: instanceId:string
awakenTheKraken = (awsRegion, instanceId, callback)=>

  Kraken.getByID awsRegion, instanceId, (err, kraken)->
    if err
      console.log '%s [SUMMON] %s : ERROR with instance\n\t\t%s', new Date(), instanceId, err
      callback && callback(err, instanceId)
              
    else if !kraken == 0
      console.log  '%s [SUMMON] %s : The Kraken remains a myth. It cannot be unleashed.', new Date(), instanceId      
        
    else if kraken
      
      switch kraken.State.Code
        when 16 
          console.log '%s [SUMMON] %s : The kraken is awake.', new Date(), instanceId
          callback && callback(null, instanceId)

        when 0
          console.log '%s [SUMMON] %s : The kraken is still waking up. Recheck in 5secs', new Date(), instanceId
          setTimeout ()=>
            awakenTheKraken awsRegion, instanceId, callback 
          , 10000
          
        else
          console.log '%s [SUMMON] %s : The kraken is dead. It will never wake up', new Date(), instanceId
          callback && callback("The Kraken is dead", instanceId)



# @Description: Tags a kraken in a name for better viewing AWS console
# @param awsRegion:String
# @param instanceId:String
# @param: params:Array[String]
nameTheKraken = (awsRegion, instanceId, shellScriptParams)=>
  console.log '%s [SUMMON] %s : writing shell script parameters to krake > %s', new Date(), instanceId, shellScriptParams.join(",")
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
      console.log '%s [SUMMON] %s : cannot name Kraken ' + 
        '\n\t\tERROR : %s', new Date(), instanceId, err
      
    else 
      console.log '%s [SUMMON] %s : Shell script parameters written', new Date(), instanceId



quit = (callback)->
  redisClient?.quit()
  callback?()


module.exports = 
  summonTheKraken:  summonTheKraken
  awakenTheKraken:  awakenTheKraken
  nameTheKraken:    nameTheKraken
  quit:             quit