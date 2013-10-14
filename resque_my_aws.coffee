if !process.env['AWS_ACCESS_KEY'] || !process.env['AWS_SECRET_KEY'] || !process.env['AWS_REGION']
  console.log 'Usage : include the following in your ~/.bashrc ' + 
    '\n\tAWS_ACCESS_KEY' +
    '\n\tAWS_SECRET_KEY' +
    '\n\tAWS_REGION'
  process.exit(1)


redisHost = process.env['REDIS_HOST'] || "localhost"
redisPort = process.env['REDIS_PORT'] || "6379"
unleashTheKraken = require './jobs/unleash'

channelName = process.env['AWS_REGION'] || 'aws_handling'

myJobs =
  unleash: unleashTheKraken

# setup a worker
worker = require('coffee-resque').connect({
  host: redisHost,
  port: redisPort
}).worker(channelName, myJobs)


worker.on 'poll', (worker, queue)->

worker.on 'job', (worker, queue, job)->
  console.log 'got a job'  

worker.on 'error', (err, worker, queue, job)->
  console.log 'got an error, %s', err

worker.on 'success', (worker, queue, job, result)->
  console.log 'success' 

worker.start()