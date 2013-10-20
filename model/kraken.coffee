# Gets the details of an EC2 instance

# dependencies
getAwsClient = require '../helper/get_aws_client'

class Kraken
  
  # @Description: gets the EC2 given an instanceID
  # @param: awsRegion:String
  # @param: instanceId:String
  # @param: callback:function(kraken:Object)
  getByID : (awsRegion, instanceId, callback)->

    ec2Client = getAwsClient awsRegion
    query =
      InstanceIds : [instanceId]
  
    ec2Client.describeInstances query, (err, data)=>
      if err || data.Reservations.length == 0
        callback && callback err, false
          
      else if data.Reservations.length > 0
        callback && callback err, data.Reservations[0].Instances[0]



  # @Description: gets the a list of all active EC2 given a set of tags
  # @param: awsRegion:String
  # @param: shellScriptParams:Array[ String ]
  # @param: callback:function( Array[ kraken:Object ] )
  getAll : (awsRegion, shellScriptParams, callback)->
  
    paramsLength = shellScriptParams.length - 1
    
    filters = []
    for x in [0..paramsLength]
      currFilter = 
        Name : "tag:" + x
        Values : [ shellScriptParams[x] ]
      filters.push currFilter
      
    currFilter =
      Name : "instance-state-code"
      Values : ['0', '16']
    filters.push currFilter
    
    ec2Client = getAwsClient awsRegion
    query = 
      Filters : filters

    ec2Client.describeInstances query, (err, data)=>
      if err || data.Reservations.length == 0
        callback && callback err, false
      
      else if data.Reservations.length > 0
        instances = []
        data.Reservations.forEach (resInstances)->
          instances = instances.concat(resInstances.Instances)
        callback && callback err, instances



KModel = new Kraken()
module.exports = KModel
