# Gets a running EC2 instance, fetches its TAGs and sends a request to spawn a new one

# dependencies
getAwsClient = require './helper/get_aws_client'
getKraken = require './helper/get_kraken'

reincarnateTheKraken = (awsRegion, instanceId, callback)->
  console.log '[REINCARNATE] %s : Reincarnating Kraken', instanceId
  getKraken awsRegion, instanceId, (err, kraken)->
  
    if !kraken
      callback && callback(new Error('Kraken not found'))
      
    else
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
      console.log '[REINCARNATE] %s : Terminating Kraken', instanceId
      ec2Client.terminateInstances { InstanceIds : [instanceId] }, (err, data)->
        if err
          callback && callback(new Error(err))
          
        else
          resque.enqueue( "aws", "summon", [
              awsRegion, 
              kraken.ImageId,
              kraken.SecurityGroups[0].GroupName, 
              kraken.InstanceType, 1, 1, 
              taskQueue, 
              eventEnqueue ] )
    
          callback && callback()

module.exports = reincarnateTheKraken