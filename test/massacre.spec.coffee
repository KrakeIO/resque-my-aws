redisHost = process.env["REDIS_HOST"] || "localhost"
redisPort = "6379"
global.AWS_ACCESS_KEY_ID = process.env['AWS_ACCESS_KEY']
global.SECRET_ACCESS_KEY = process.env['AWS_SECRET_KEY']
ec2Region = "ap-southeast-1"
queueName = "queueName"
eventName = "eventName"
shellScriptParams = [queueName, eventName]

massacreTheKraken = require "../jobs/massacre"
      
describe "testing massacre via network", ()->
  it "should respond with something", (done)->
    resque = require("coffee-resque").connect({ 
      host: redisHost, 
      port: redisPort 
    })  
    resque.enqueue( "aws", "massacre", [ ec2Region, shellScriptParams ] )
    done()
    
describe "testing massacre locally", ()->
  it "should respond with something", (done)->
    # massacreTheKraken ec2Region, shellScriptParams, ()->
    done()
