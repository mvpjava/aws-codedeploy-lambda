#!/bin/sh -xe

echo "Starting $0"

REGION=eu-west-2

zip myHelloWorldLambda.zip myHelloWorldLambda.py 
aws s3 cp myHelloWorldLambda.zip s3://codedeploy-lambda/myHelloWorldLambda-cli/ --region $REGION

echo "Exiting $0"
