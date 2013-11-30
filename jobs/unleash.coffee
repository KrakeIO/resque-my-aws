# Runs the shell script against an AWS EC2

# dependencies
exec = require("child_process").exec
getAwsClient = require '../helper/get_aws_client'
Kraken = require '../model/kraken'



# @Description: run the shell/start_slave.sh script
#   Will call itself again if there is an error in the shell script call
# @param: awsRegion:String
# @param: instanceId:String
# @param: shellScriptParams:Array[String]
# @param: callback:function()
unleashTheKraken = (awsRegion, instanceId, shellScriptParams, callback)->

  console.log  "%s [UNLEASH] %s : Unleashing Kraken in ", new Date(), instanceId, awsRegion
  Kraken.getByID awsRegion, instanceId, (err, kraken)->
    if err
      console.log '%s [UNLEASH] : Error getting kraken', new Date()
      callback && callback()
    
    else if !kraken
      console.log "%s [UNLEASH] %s : the kraken does not exist", new Date(), instanceId    
      callback && callback()
      
    command = __dirname + "/../shell_scripts/start_slave.sh " + kraken.PublicDnsName
    paramsLength = shellScriptParams.length - 1      
    for x in [0..paramsLength]
      command += " " + shellScriptParams[x]
      
    console.log  "%s [UNLEASH] %s : Shell command to be executed" + 
      "\n\t\t%s", new Date(), instanceId, command
       
    executeShellScript awsRegion, instanceId, command, (err, data)->
      if err
        callback && callback(err)
      else
        callback && callback()
      


# @Description : Executes the actual shell script on the EC2 instance
# @param: awsRegion:String
# @param: instanceId:String
# @param: command:String
# @param: callback:function()
executeShellScript = (awsRegion, instanceId, command, callback)->

  console.log  '%s [UNLEASH] %s : Executing shell command', new Date(), instanceId
  Kraken.getByID awsRegion, instanceId, (err, kraken)->    
    if err
      console.log  "%s [UNLEASH] %s : Error getting kraken", new Date(), instanceId          
      callback && callback()
  
    else if !kraken
      console.log  "%s [UNLEASH] %s : the kraken does not exist", new Date(), instanceId    
      callback && callback()
        
    else if kraken
      switch kraken.State.Code
        when 16 # when is awake
          exec command, (err, stdout, stderr)=>
            if err
              console.log '%s [UNLEASH] %s : Shell command failed.', new Date(), instanceId
              executeShellScript awsRegion, instanceId, command, callback
            
            else
              console.log "%s [UNLEASH] %s : the kraken has been unleashed", new Date(), instanceId
              callback && callback()
              
        when 0
          executeShellScript awsRegion, instanceId, command, callback
        
        else
          console.log "%s [UNLEASH] %s : Cannot unleash inactive kraken", new Date(), instanceId
          callback && callback()



module.exports = unleashTheKraken

