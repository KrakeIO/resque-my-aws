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

  console.log  new Date() + " [UNLEASH] %s : Unleashing Kraken in ", instanceId, awsRegion
  Kraken.getByID awsRegion, instanceId, (err, kraken)->
    if err
      callback && callback(new Error("Error getting kraken"))
    
    else if !kraken
      console.log  new Date() + " [UNLEASH] %s : the kraken does not exist", instanceId    
      callback && callback(new Error("the kraken does not exist"))
      
    command = __dirname + "/../shell_scripts/start_slave.sh "+ kraken.PublicDnsName
    paramsLength = shellScriptParams.length - 1      
    for x in [0..paramsLength]
      command += " " + shellScriptParams[x]
      
    console.log  new Date() + " [UNLEASH] %s : Shell command to be executed" + 
      "\n\t\t%s", instanceId, command
       
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

  console.log  new Date() + ' [UNLEASH] %s : Executing shell command', instanceId
  Kraken.getByID awsRegion, instanceId, (err, kraken)->    
    if err
      callback && callback(new Error("Error getting kraken"))
  
    else if !kraken
      console.log  new Date() + " [UNLEASH] %s : the kraken does not exist", instanceId    
      callback && callback(new Error("the kraken does not exist"))
        
    else if kraken
      switch kraken.State.Code
        when 16 # when is awake
          exec command, (err, stdout, stderr)=>
            if err
              console.log  new Date() + ' [UNLEASH] %s : Shell command failed.', instanceId
              executeShellScript awsRegion, instanceId, command, callback
            
            else
              console.log  new Date() + " [UNLEASH] %s : the kraken has been unleashed", instanceId
              callback && callback()
              
        when 0
          executeShellScript awsRegion, instanceId, command, callback
        
        else
          console.log  new Date() + " [UNLEASH] %s : Cannot unleash inactive kraken", instanceId
          callback && callback( new Error("kraken is no longer active") )



module.exports = unleashTheKraken

