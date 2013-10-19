if !process.env["AWS_ACCESS_KEY"] || 
  !process.env["AWS_SECRET_KEY"] || 
  !process.env['AWS_IMAGE_ID'] || 
  !process.env['AWS_SECURITY_GROUP'] || 
  !process.env['AWS_INSTANCE_TYPE']
  
      console.log "Usage : include the following in your ~/.bashrc " + 
        "\n\tAWS_ACCESS_KEY" +
        "\n\tAWS_SECRET_KEY" + 
        "\n\tAWS_IMAGE_ID" + 
        "\n\tAWS_SECURITY_GROUP" + 
        "\n\tAWS_INSTANCE_TYPE"
        
      process.exit(1)

# Environment configuration
global.REDIS_HOST = process.env["REDIS_HOST"] || "localhost"
global.REDIS_PORT = process.env["REDIS_PORT"] || "6379"
global.AWS_ACCESS_KEY_ID = process.env['AWS_ACCESS_KEY']
global.SECRET_ACCESS_KEY = process.env['AWS_SECRET_KEY']
global.AWS_IMAGE_ID = process.env['AWS_IMAGE_ID']
global.AWS_SECURITY_GROUP = process.env['AWS_SECURITY_GROUP']
global.AWS_INSTANCE_TYPE = process.env['AWS_INSTANCE_TYPE']

# dependencies
unleashTheKraken = require "./jobs/unleash"
summonTheKraken = require "./jobs/summon"
reincarnateTheKraken = require "./jobs/reincarnate"

# setup a worker
worker = require("coffee-resque").connect({
  host: REDIS_HOST,
  port: REDIS_PORT
}).worker( "aws", { 
  unleash: unleashTheKraken 
  summon: summonTheKraken 
  reincarnate : reincarnateTheKraken
})


worker.on "poll", (worker, queue)->

worker.on "job", (worker, queue, job)->
  console.log "[AWS-RESQUE] : job received"  

worker.on "error", (err, worker, queue, job)->
  console.log "[AWS-RESQUE] : job error, %s", err

worker.on "success", (worker, queue, job, result)->
  console.log "[AWS-RESQUE] : success" 

worker.start()



console.log "started service on : " + 
  "\n\tAWS_ACCESS_KEY : %s" +
  "\n\tAWS_SECRET_KEY : %s" +
  "\n\tAWS_REGION : %s" + 
  "\n\tREDIS_SERVER : %s" + 
  "\n\tREDIS_SERVER : %s",
  process.env["AWS_ACCESS_KEY"], 
  process.env["AWS_SECRET_KEY"], 
  process.env["AWS_REGION"],
  REDIS_HOST,
  REDIS_PORT