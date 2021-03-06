if !process.env["AWS_ACCESS_KEY"] || 
  !process.env["AWS_SECRET_KEY"]
  
      console.log "Usage : include the following in your ~/.bashrc " + 
        "\n\tAWS_ACCESS_KEY" +
        "\n\tAWS_SECRET_KEY"
        
      process.exit(1)

# Environment configuration
global.REDIS_HOST = process.env["REDIS_HOST"] || "localhost"
global.REDIS_PORT = process.env["REDIS_PORT"] || "6379"
global.AWS_ACCESS_KEY_ID = process.env['AWS_ACCESS_KEY']
global.SECRET_ACCESS_KEY = process.env['AWS_SECRET_KEY']

# dependencies
unleashTheKraken = require "./jobs/unleash"
Summoner = require("./jobs/summoner")
reincarnateTheKraken = require "./jobs/reincarnate"
massacreTheKraken = require "./jobs/massacre"

summoner = new Summoner(REDIS_HOST, REDIS_PORT)

# setup a worker
worker = require("coffee-resque").connect({
  host: REDIS_HOST,
  port: REDIS_PORT
  
}).worker( "aws", { 
  summon: ->   summoner.summonTheKraken.apply summoner, arguments
  unleash:      unleashTheKraken
  reincarnate : reincarnateTheKraken
  massacre :    massacreTheKraken
  
})

worker.on "poll", (worker, queue)->

worker.on "job", (worker, queue, job)->
  console.log  new Date() + " [AWS-RESQUE] : job received"  

worker.on "error", (err, worker, queue, job)->
  console.log  new Date() + " [AWS-RESQUE] : job error, %s", err

worker.on "success", (worker, queue, job, result)->
  console.log  new Date() + " [AWS-RESQUE] : success" 

worker.start()



console.log "started service on : " + 
  "\n\tAWS_ACCESS_KEY : %s" +
  "\n\tAWS_SECRET_KEY : %s" +
  "\n\tREDIS_SERVER : %s" + 
  "\n\tREDIS_SERVER : %s",
  process.env["AWS_ACCESS_KEY"], 
  process.env["AWS_SECRET_KEY"], 
  REDIS_HOST,
  REDIS_PORT