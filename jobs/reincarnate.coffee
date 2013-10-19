# Gets a running EC2 instance, fetches its TAGs and sends a request to spawn a new one

# dependencies
getAwsClient = require './helper/get_aws_client'
getKraken = require './helper/get_kraken'

reincarnateTheKraken = (awsRegion, instanceId, callback)->
  console.log '[REINCARNATE] %s : Reincarnating a Kraken', instanceId
  getKraken awsRegion, instanceId, (err, kraken)->
    taskQueue = false
    eventEnqueue = false
    kraken.Tags.forEach (tag)=>
      if tag.Key == 'taskQueue' then taskQueue = tag.Value
      else if tag.Key == 'eventEnqueue' then eventEnqueue = tag.Value
    
    resque = require('coffee-resque').connect({
      host: REDIS_HOST,
      port: REDIS_PORT
    })

    ec2Client = getAwsClient awsRegion
    ec2Client.terminateInstances { InstanceIds : [instanceId] }
    
    resque.enqueue( "aws", "summon", [
        awsRegion, 
        AWS_IMAGE_ID, 
        AWS_SECURITY_GROUP, 
        AWS_INSTANCE_TYPE, 1, 1, 
        taskQueue, 
        eventEnqueue ] )
    
    callback && callback()

module.exports = reincarnateTheKraken