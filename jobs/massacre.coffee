# Given a list of shell script parameters terminate all EC2 instances that have tag values that match
getAwsClient = require '../helper/get_aws_client'
Kraken = require '../model/kraken'

massacreTheKrakens = (awsRegion, shellScriptParams, callback)->
  console.log '%s [MASSACRE] : consolidating hit list queuename : %s', new Date(), shellScriptParams[0]
  Kraken.getAll awsRegion, shellScriptParams, (err, theKrakens)->
    if err
      console.log '%s [MASSACRE] %s : %s', new Date(), shellScriptParams[0], err
      callback && callback()
      
    else if !theKrakens
      console.log '%s [MASSACRE] %s : No Krakens were found', new Date(), shellScriptParams[0]
      callback && callback()
      
    else if theKrakens
      killList = theKrakens.map (kraken)->
        kraken.InstanceId
      
      tOpts =
        InstanceIds : killList
      ec2Client = getAwsClient awsRegion
      ec2Client.terminateInstances tOpts, (err, data)->    
        if err
          console.log '%s [MASSACRE] %s : Termination error %s', new Date(), killList.join(), err
          callback && callback()
        else
          console.log '%s [MASSACRE] %s : Instances terminated', new Date(), killList.join()          
          callback && callback()
        
    
module.exports = massacreTheKrakens