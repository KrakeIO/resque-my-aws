# Given a list of shell script parameters terminate all EC2 instances that have tag values that match
getAwsClient = require '../helper/get_aws_client'
Kraken = require '../model/kraken'

massacreTheKrakens = (awsRegion, shellScriptParams, callback)->
  console.log '[MASSACRE] : consolidating hit list'
  Kraken.getAll awsRegion, shellScriptParams, (err, theKrakens)->
    if err
      callback && callback(new Error(err))
      
    else if !theKrakens
      callback && callback(new Error("No Krakens were found"))
      
    else if theKrakens
      killList = theKrakens.map (kraken)->
        console.log '[MASSACRE] %s : Terminating instance', kraken.InstanceId
        kraken.InstanceId
      
      tOpts =
        InstanceIds : killList
      ec2Client = getAwsClient awsRegion
      ec2Client.terminateInstances tOpts, (err, data)->    
        if err
          callback && callback(new Error(err))
        else
          callback && callback()
        
    
module.exports = massacreTheKrakens