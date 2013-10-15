# dependencies
AWS = require 'aws-sdk'
exec = require("child_process").exec


# @Description: get AWS client
# @param : awsRegion
getAwsClient = (awsRegion)->
  AWS.config.update { 
    accessKeyId : AWS_ACCESS_KEY_ID
    secretAccessKey : SECRET_ACCESS_KEY
    region : awsRegion
  }
  new AWS.EC2().client



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



# @Description: run the shell/start_slave.sh script
#   Will call itself again if there is an error in the shell script call
# @param: awsRegion:String
# @param: instanceId:String
# @param: listName:String
# @param: eventName:String
# @param: callback:function()
unleashTheKraken = (awsRegion, instanceId, listName, eventName, callback)->
  console.log "[NETWORK_SUPERVISOR] %s : Checking state", instanceId
  getKraken awsRegion, instanceId, (err, kraken)->
    if err
      callback && callback(new Error("Error getting kraken"))
      
    else if !kraken
      console.log "[NETWORK_SUPERVISOR] %s : the kraken does not exist", instanceId    
      callback && callback(new Error("the kraken does not exist"))
    
    else if kraken
      switch kraken.State.Code
        when 16 # when is awake
          if listName && eventName
            command = __dirname + "/../shell_scripts/start_slave.sh "+ kraken.PublicDnsName +
              " " + listName + " " + eventName
            
            console.log "[NETWORK_SUPERVISOR] %s : executing shell command" + 
              "\n\t\t%s", instanceId, command
            
            exec command, (err, stdout, stderr)=>
              if err
                console.log "[NETWORK_SUPERVISOR] Error executing ssh command" + 
                  "\n\t\tMSG : %s", err
                unleashTheKraken awsRegion, instanceId, listName, eventName, callback
              
              else
                console.log stdout
                console.log "[NETWORK_SUPERVISOR] %s : the kraken has been unleashed", instanceId
                callback && callback()
              
        when 0
          unleashTheKraken instanceId, listName, eventName, callback
        
        else
          console.log "[NETWORK_SUPERVISOR] %s : Cannot unleash inactive kraken", instanceId
          callback && callback(new Error("kraken is no longer active"))



module.exports = unleashTheKraken

if !module.parent
  unleashTheKraken "i-81e0b8d7", "someQueue", "someEvent", ()->
    console.log "done"