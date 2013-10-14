if !process.env['AWS_ACCESS_KEY'] || !process.env['AWS_SECRET_KEY'] || !process.env['AWS_REGION']
  console.log 'Usage : include the following in your ~/.bashrc ' + 
    '\n\tAWS_ACCESS_KEY' +
    '\n\tAWS_SECRET_KEY' +
    '\n\tAWS_REGION'
  process.exit(1)
  
  
  
# dependencies
unleashTheKraken = require './jobs/unleash'

# Environment configuration
redisHost = process.env['REDIS_HOST'] || "localhost"
redisPort = process.env['REDIS_PORT'] || "6379"
channelName = process.argv[2] || process.env['AWS_REGION'] || 'aws_handling'  



# setup a worker
worker = require('coffee-resque').connect({
  host: redisHost,
  port: redisPort
}).worker( channelName, { unleash: unleashTheKraken } )


worker.on 'poll', (worker, queue)->

worker.on 'job', (worker, queue, job)->
  console.log '[AWS-RESQUE] : job received'  

worker.on 'error', (err, worker, queue, job)->
  console.log '[AWS-RESQUE] : job error, %s', err

worker.on 'success', (worker, queue, job, result)->
  console.log '[AWS-RESQUE] : success' 

worker.start()



console.log "started service on : " + 
  '\n\tAWS_ACCESS_KEY : %s' +
  '\n\tAWS_SECRET_KEY : %s' +
  '\n\tAWS_REGION : %s' + 
  '\n\tREDIS_SERVER : %s' + 
  '\n\tREDIS_SERVER : %s',
  process.env['AWS_ACCESS_KEY'], 
  process.env['AWS_SECRET_KEY'], 
  process.env['AWS_REGION'],
  redisHost,
  redisPort