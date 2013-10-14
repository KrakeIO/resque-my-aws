# Resque AWS

This service listens to a queue on Redis for jobs. When it gets a job, 
executes shell script on an already initialized AWS instance with the parameters indicated in the job

# Pre-requisities
- NODEJS
- CoffeeScript
- Redis