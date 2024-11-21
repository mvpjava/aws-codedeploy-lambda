#!/bin/sh

echo "Starting $0"

REGION=eu-west-2
LAMBDA_FUNCTION_NAME=myHelloWorldLambda

aws lambda create-function \
	--function-name $LAMBDA_FUNCTION_NAME \
	--runtime python3.12 \
	--handler myHelloWorldLambda.lambda_handler \
	--role arn:aws:iam::403177882230:role/myLambdaAdminRoleForAllDemos \
        --code S3Bucket=codedeploy-lambda,S3Key=myHelloWorldLambda-cli/myHelloWorldLambda.zip \
	--region $REGION

echo "Exiting $0"
