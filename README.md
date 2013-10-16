# Resque AWS

This service listens to a queue on Redis for jobs. When it gets a job, 
perform some AWS operations based on the provided parameters indicated in the job

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

# Current Jobs handled
- Spins up an EC2 instance
- Executes an arbiturary shell script on an EC2 instance