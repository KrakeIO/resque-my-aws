# dependencies
AWS = require('aws-sdk')
exec = require('child_process').exec

if !process.env['AWS_ACCESS_KEY'] || !process.env['AWS_SECRET_KEY']
  console.log 'Usage : include the following in your ~/.bashrc ' + 
    '\n\tAWS_ACCESS_KEY' +
    '\n\tAWS_SECRET_KEY' +
    '\n\tAWS_REGION'
  process.exit(1)

AWS.config.update { 
  accessKeyId : process.env['AWS_ACCESS_KEY'], 
  secretAccessKey : process.env['AWS_SECRET_KEY'],
  region : process.env['AWS_REGION']
}

ec2Client = new AWS.EC2().client

module.exports = ec2Client