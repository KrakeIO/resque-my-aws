redisHost = process.env["REDIS_HOST"] || "localhost"
redisPort = "6379"
ec2Region = "ap-southeast-1"
ec2Image = "ami-b0eaa1e2"
ec2SecurityGroup = "Krake Instance"
ec2Type = "t1.micro"
queueName = "queueName"
eventName = "eventName"
shellScriptParams = [queueName, eventName]

describe "testing to ensure resque process can bootup EC2", ()->
  it "should respond with something", (done)->
    resque = require("coffee-resque").connect({ 
      host: redisHost, 
      port: redisPort 
    })
    resque.enqueue( "aws", "summon", [ ec2Region, ec2Image, ec2SecurityGroup, ec2Type, shellScriptParams ] )
    done()