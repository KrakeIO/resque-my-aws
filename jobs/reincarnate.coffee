# Gets a running EC2 instance, fetches its TAGs and sends a request to spawn a new one

# dependencies
getAwsClient = require '../helper/get_aws_client'
Kraken = require '../model/kraken'

reincarnateTheKraken = (awsRegion, instanceId, callback)->
  console.log '[REINCARNATE] %s : Reincarnating Kraken', instanceId
  Kraken.getByID awsRegion, instanceId, (err, kraken)->
  
    if !kraken
      callback && callback(new Error('Kraken not found'))
      
    else
      shellScriptParams = []
      kraken.Tags.forEach (tag)=>
        shellScriptParams[tag.Key * 1] = tag.Value
  
      resque = require('coffee-resque').connect({
        host: REDIS_HOST,
        port: REDIS_PORT
      })    

      ec2Client = getAwsClient awsRegion
      console.log '[REINCARNATE] %s : Terminating Kraken', instanceId
      ec2Client.terminateInstances { InstanceIds : [instanceId] }, (err, data)->
        if err
          callback && callback(new Error(err))
          
        else
          resque.enqueue( "aws", "summon", [
              awsRegion, 
              kraken.ImageId,
              kraken.SecurityGroups[0].GroupName, 
              kraken.InstanceType,
              shellScriptParams ] )
    
          callback && callback()

module.exports = reincarnateTheKraken