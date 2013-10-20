redisHost = process.env["REDIS_HOST"] || "localhost"
redisPort = "6379"
ec2Region = "ap-southeast-1"
ec2InstanceId = "i-6d67203b"
queueName = "queueName"
eventName = "eventName"
shellScriptParams = [queueName, eventName]

describe "testing to ensure resque process can ssh EC2", ()->
  it "should respond with something", (done)->
    resque = require("coffee-resque").connect({ 
      host: redisHost, 
      port: redisPort 
    })
    resque.enqueue( "aws", "unleash", [ ec2Region, ec2InstanceId, shellScriptParams ] )
    done()