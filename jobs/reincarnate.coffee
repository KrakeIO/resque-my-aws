# Gets a running EC2 instance, fetches its TAGs and sends a request to spawn a new one

# dependencies
getAwsClient = require '../helper/get_aws_client'
Kraken = require '../model/kraken'

reincarnateTheKraken = (awsRegion, queueName, instanceId, callback)->
  console.log "#{new Date()} [REINCARNATE]: Reincarnating Kraken\r\n\tqueueName: #{queueName}\r\n\tinstanceId: #{instanceId}"
  Kraken.getByID awsRegion, instanceId, (err, kraken)->
  
    if !kraken
      console.log '%s [REINCARNATE] %s : Kraken not found', new Date(), instanceId
      callback && callback()
      
    else
      shellScriptParams    = []
      shellScriptParams[0] = queueName
  
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