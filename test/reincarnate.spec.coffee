redisHost = process.env["REDIS_HOST"] || "localhost"
redisPort = "6379"
ec2Region = "ap-southeast-1"
ec2InstanceId = "i-b79dd0e1"

describe "testing to ensure resque process can rotate an IP address", ()->
  it "should respond with something", (done)->
    resque = require("coffee-resque").connect({ 
      host: redisHost, 
      port: redisPort 
    })
    resque.enqueue( "aws", "reincarnate", [ ec2Region, ec2InstanceId ] )
    done()