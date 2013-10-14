# Resque AWS

This service listens to a queue on Redis for jobs. When it gets a job, 
executes shell script on an already initialized AWS instance with the parameters indicated in the job

# Pre-requisities

## Dependency libraries
- NODEJS
- CoffeeScript
- Redis

## Setup configuration
Set the following values in your ~/.bashrc file before running
- AWS_ACCESS_KEY
- AWS_SECRET_KEY
- AWS_REGION
