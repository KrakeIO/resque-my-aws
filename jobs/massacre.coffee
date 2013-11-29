# Given a list of shell script parameters terminate all EC2 instances that have tag values that match
getAwsClient = require '../helper/get_aws_client'
Kraken = require '../model/kraken'

massacreTheKrakens = (awsRegion, shellScriptParams, callback)->
  console.log new Date() + ' [MASSACRE] : consolidating hit list queuename : %s', shellScriptParams[0]
  Kraken.getAll awsRegion, shellScriptParams, (err, theKrakens)->
    if err
      console.log new Date() + ' [MASSACRE] : %s', err
      callback && callback()
      
    else if !theKrakens
      console.log new Date() + ' [MASSACRE] : No Krakens were found'
      callback && callback()
      
    else if theKrakens
      killList = theKrakens.map (kraken)->
        console.log new Date() + ' [MASSACRE] %s : Terminating instance', kraken.InstanceId
        kraken.InstanceId
      
      tOpts =
        InstanceIds : killList
      ec2Client = getAwsClient awsRegion
      ec2Client.terminateInstances tOpts, (err, data)->    
        if err
          console.log new Date() + ' [MASSACRE] : %s', err
          callback && callback()
        else
          callback && callback()
        
    
module.exports = massacreTheKrakens