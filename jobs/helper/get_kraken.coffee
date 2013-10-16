# dependencies
getAwsClient = require './get_aws_client'



# @Description: gets the state of the EC2 given an instanceID
# @params: awsRegion:String
# @params: instanceId:String
# @param : callback:function(kraken:Object)
getKraken = (awsRegion, instanceId, callback)->

  ec2Client = getAwsClient awsRegion
    
  query = {
    InstanceIds : [instanceId]
  }
  
  ec2Client.describeInstances query, (err, data)=>
    if err || data.Reservations.length == 0
      callback && callback err, false
          
    else if data.Reservations.length > 0
      callback && callback err, data.Reservations[0].Instances[0]

module.exports = getKraken