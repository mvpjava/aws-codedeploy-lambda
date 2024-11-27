#!/bin/sh

#Used in class demo with AWS CodeDeploy. This is why some of it is hardcoded.
echo "Starting $0"

REGION=eu-west-2
LAMBDA_FUNCTION_NAME=myHelloWorldLambda

OUTPUT=$(aws lambda create-function \
	--function-name $LAMBDA_FUNCTION_NAME \
	--runtime python3.12 \
	--handler myHelloWorldLambda.lambda_handler \
	--role arn:aws:iam::403177882230:role/myLambdaAdminRoleForAllDemos \
        --code S3Bucket=codedeploy-lambda,S3Key=myHelloWorldLambda-cli/myHelloWorldLambda.zip \
	--region $REGION 2>&1)

# Check if the creation failed due to the function already existing
if [[ $? -ne 0 ]]; then
    if echo "$OUTPUT" | grep -q "ResourceConflictException"; then
        echo "Function $LAMBDA_FUNCTION_NAME already exists. Continuing without exiting..."
    else
        echo "An error occurred: $OUTPUT"
        exit 1
    fi
else
    echo "Function $LAMBDA_FUNCTION_NAME created successfully."
fi 

echo "Exiting $0"
