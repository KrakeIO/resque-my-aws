redisHost = process.env['REDIS_HOST'] || "localhost"
redisPort = process.env['REDIS_PORT'] || "6379"
unleashTheKraken = require './jobs/unleash'

myJobs =
  unleash: unleashTheKraken

# setup a worker
worker = require('coffee-resque').connect({
  host: redisHost,
  port: redisPort
}).worker('aws_handling', myJobs)


worker.on 'poll', (worker, queue)->

worker.on 'job', (worker, queue, job)->
  console.log 'got a job'  

worker.on 'error', (err, worker, queue, job)->
  console.log 'got an error, %s', err

worker.on 'success', (worker, queue, job, result)->
  console.log 'success' 

worker.start()