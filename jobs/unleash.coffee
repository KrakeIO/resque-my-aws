# Runs the shell script against an AWS EC2

# dependencies
exec = require("child_process").exec
getAwsClient = require './helper/get_aws_client'
getKraken = require './helper/get_kraken'



# @Description: run the shell/start_slave.sh script
#   Will call itself again if there is an error in the shell script call
# @param: awsRegion:String
# @param: instanceId:String
# @param: listName:String
# @param: eventName:String
# @param: callback:function()
unleashTheKraken = (awsRegion, instanceId, listName, eventName, callback)->
  console.log "[UNLEASH] %s : Unleashing Kraken", instanceId
  getKraken awsRegion, instanceId, (err, kraken)->
    if err
      callback && callback(new Error("Error getting kraken"))
      
    else if !kraken
      console.log "[UNLEASH] %s : the kraken does not exist", instanceId    
      callback && callback(new Error("the kraken does not exist"))
    
    else if kraken
      switch kraken.State.Code
        when 16 # when is awake
          if listName && eventName
            command = __dirname + "/../shell_scripts/start_slave.sh "+ kraken.PublicDnsName +
              " " + listName + " " + eventName
            
            console.log "[UNLEASH] %s : executing shell command" + 
              "\n\t\t%s", instanceId, command
            
            exec command, (err, stdout, stderr)=>
              if err
                console.log "[UNLEASH] Error executing ssh command" + 
                  "\n\t\tMSG : %s", err
                unleashTheKraken awsRegion, instanceId, listName, eventName, callback
              
              else
                console.log stdout
                console.log "[UNLEASH] %s : the kraken has been unleashed", instanceId
                callback && callback()
              
        when 0
          unleashTheKraken instanceId, listName, eventName, callback
        
        else
          console.log "[UNLEASH] %s : Cannot unleash inactive kraken", instanceId
          callback && callback( new Error("kraken is no longer active") )



module.exports = unleashTheKraken

