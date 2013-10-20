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

Make sure you have an EC2 image setup in EC2 region you want to spin up your instance in with SSH service running at port 2202

# Running
## Starting the AWS IP rotation service
```console
coffee resque_my_aws.coffee
```
## Testing the EC2 spin up sequence
```console
jasmine-node --coffee test/summon.spec.coffee
```

# Customizations
To change the shell script sequence you want to run simply modify the shell script in the following file to your own needs
```console
./shell_scripts/start_slave.sh
```

The first parameter for the shell script is by default set by the engine as the Public DNS address of the EC2 instance
You can easily pass other parameters to the shell script via the engine. 

Refer to [this script on how to do so] (./test/summon.spec.coffee)