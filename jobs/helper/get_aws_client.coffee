# The wrapper class for the AWS sdk

# dependencies
AWS = require 'aws-sdk'

# @Description: get AWS client
# @param : awsRegion
getAwsClient = (awsRegion)->
  AWS.config.update { 
    accessKeyId : AWS_ACCESS_KEY_ID
    secretAccessKey : SECRET_ACCESS_KEY
    region : awsRegion
  }
  new AWS.EC2().client

module.exports = getAwsClient