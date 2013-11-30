# Gets a running EC2 instance, fetches its TAGs and sends a request to spawn a new one

# dependencies
getAwsClient = require '../helper/get_aws_client'
Kraken = require '../model/kraken'

reincarnateTheKraken = (awsRegion, instanceId, callback)->
  console.log '%s [REINCARNATE] %s : Reincarnating Kraken', new Date(), instanceId
  Kraken.getByID awsRegion, instanceId, (err, kraken)->
  
    if !kraken
      console.log '%s [REINCARNATE] %s : Kraken not found', new Date(), instanceId
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
      console.log '%s [REINCARNATE] %s : Terminating Kraken', new Date(), instanceId
      ec2Client.terminateInstances { InstanceIds : [instanceId] }, (err, data)->
        if err
          console.log '%s [REINCARNATE] %s : %s', new Date(), instanceId, err
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