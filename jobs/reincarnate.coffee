# Gets a running EC2 instance, fetches its TAGs and sends a request to spawn a new one

# dependencies
getAwsClient = require '../helper/get_aws_client'
Kraken = require '../model/kraken'

reincarnateTheKraken = (awsRegion, instanceId, callback)->
  console.log new Date() + ' [REINCARNATE] %s : Reincarnating Kraken', instanceId
  Kraken.getByID awsRegion, instanceId, (err, kraken)->
  
    if !kraken
      console.log new Date() + ' [MASSACRE] : Kraken not found'
      callback && callback()
      
    else
      shellScriptParams = []
      kraken.Tags.forEach (tag)=>
        shellScriptParams[tag.Key * 1] = tag.Value
  
      resque = require('coffee-resque').connect({
        host: REDIS_HOST,
        port: REDIS_PORT
      })    

      ec2Client = getAwsClient awsRegion
      console.log new Date() + ' [REINCARNATE] %s : Terminating Kraken', instanceId
      ec2Client.terminateInstances { InstanceIds : [instanceId] }, (err, data)->
        if err
          console.log new Date() + ' [MASSACRE] : %s', err
          callback && callback()
          
        else
          resque.enqueue( "aws", "summon", [
              awsRegion, 
              kraken.ImageId,
              kraken.SecurityGroups[0].GroupName, 
              kraken.InstanceType,
              shellScriptParams ] )
    
          callback && callback()

module.exports = reincarnateTheKraken