global.AWS_ACCESS_KEY_ID = process.env['AWS_ACCESS_KEY']
global.SECRET_ACCESS_KEY = process.env['AWS_SECRET_KEY']
global.REDIS_HOST = redisHost = process.env["REDIS_HOST"] || "localhost"
global.REDIS_PORT = redisPort = "6379"

ec2Region = "ap-southeast-1"
ec2Image = "ami-e6e9b1b4"
ec2SecurityGroup = "Krake Instance"
ec2Type = "t1.micro"
queueName = "TESTING_JOB"
eventName = "WHATTODO"
shellScriptParams = [queueName, eventName]

Summoner = require("../jobs/summoner")

describe "testing to ensure resque process can bootup EC2", ()->
  it "should respond with something", (done)->
    resque = require("coffee-resque").connect({ 
      host: REDIS_HOST, 
      port: REDIS_PORT
    })
    resque.enqueue( "aws", "summon", [ ec2Region, ec2Image, ec2SecurityGroup, ec2Type, shellScriptParams ] )
    done()

describe "Summoner", ->
  beforeEach ->
    @summoner = new Summoner REDIS_HOST, REDIS_PORT

  afterEach ->
    @summoner.quit()

  describe "#summonTheKraken", ->

    it "should call #spinUpEC2Instance when there are jobs in the queue", (done)->
      spyOn(@summoner, "spinUpEC2Instance").andCallFake (awsRegion, imageId, securityGroup, instanceType, shellScriptParams, retries, callback)->
        callback?()
      
      @summoner.redisClient.lpush queueName, "cool stuff", (error, result)=>
        @summoner.summonTheKraken ec2Region, ec2Image, ec2SecurityGroup, ec2Type, shellScriptParams, ()->
          done()

    it "should call #spinUpEC2Instance when the slaves are still engaged", (done)->
      spyOn(@summoner, "spinUpEC2Instance").andCallFake (awsRegion, imageId, securityGroup, instanceType, shellScriptParams, retries, callback)->
        callback?()
      
      @summoner.redisClient.setex "#{queueName}_BUSY", 10, "BUSY", (error, result)=>
        @summoner.summonTheKraken ec2Region, ec2Image, ec2SecurityGroup, ec2Type, shellScriptParams, ()=>
          done()

    it "should finish with a call back when there are no jobs in the queue and when there are no slaves busy", (done)->
      spyOn(@summoner, "spinUpEC2Instance")      
      @summoner.summonTheKraken ec2Region, ec2Image, ec2SecurityGroup, ec2Type, shellScriptParams, ()=>
        expect(@summoner.spinUpEC2Instance).not.toHaveBeenCalled()
        done()      
