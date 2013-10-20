# Resque AWS
This service performs the task of rotating EC2 instances to get new IP addresses from AWS.
It executes a shell script via SSH on newly spin up EC2 instances once they are ready

# Pre-requisities

## Dependency libraries
- NODEJS
- CoffeeScript
- Redis
- AWS account

## Setup configuration
Set the following values in your ~/.bashrc file before running
- AWS_ACCESS_KEY
- AWS_SECRET_KEY
- REDIS_HOST

