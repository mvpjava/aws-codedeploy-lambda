#!/bin/sh

# Wrapper script to kick off creating lambda infra via CloudFormation (cfn)
# with expected input parameter for my demo env. Unless you copy me here, you will be passing different S3 Bucket/Key

./create-stack.sh codedeploy-lambda myHelloWorldLambda-cli/myHelloWorldLambda.zip

