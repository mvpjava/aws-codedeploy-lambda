#!/bin/sh

#Used in class demo with AWS CodeDeploy. This is why some of it is hardcoded.
echo "Starting $0"

# Usage message
usage() {
    echo "Usage: $0 <Lambda Function Name>"
    echo
    echo "Creates a Lambda function but does not publish a version"
    echo "  <Lambda Function Name>  : The name of the Lambda function (required)"
    exit 1
}

# Check required parameters
if [ -z "$1" ] ; then
    echo "Error: Missing required parameters."
    usage
fi

LAMBDA_FUNCTION_NAME=$1

OUTPUT=$(aws lambda create-function \
	--function-name $LAMBDA_FUNCTION_NAME \
	--runtime python3.12 \
	--handler myHelloWorldLambda.lambda_handler \
	--role arn:aws:iam::403177882230:role/myLambdaAdminRoleForAllDemos \
        --code S3Bucket=codedeploy-lambda,S3Key=myHelloWorldLambda-cli/myHelloWorldLambda.zip 2>&1)

# Check if the creation failed due to the function already existing
if [[ $? -ne 0 ]]; then
    if echo "$OUTPUT" | grep -q "ResourceConflictException"; then
        echo "Error: A Lambda function with the name '$LAMBDA_FUNCTION_NAME' already exists."
	exit 1
    else
        echo "An unexpected error occurred: $OUTPUT"
        exit 1
    fi
else
    echo "Function $LAMBDA_FUNCTION_NAME created successfully."
fi 

echo "Exiting $0"
