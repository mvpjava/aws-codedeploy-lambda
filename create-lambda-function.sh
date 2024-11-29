#!/bin/sh

#Used in class demo with AWS CodeDeploy. This is why some of it is hardcoded.
echo "Starting $0"

# Usage message
usage() {
    echo "Usage: $0 <Lambda Function Name> <S3 URI>"
    echo
    echo "Creates a Lambda function but does not publish a version (only $LATEST) to the S3 location specified via S3 URI"
    echo "  <Lambda Function Name>  : The name of the Lambda function (required)"
    echo "  <S3 URI> : S3 URI where to upload zip file to (i.e: s3://codedeploy-lambda/folder1/)"
    exit 1
}

# Check required parameters
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Missing required parameters."
    usage
fi

LAMBDA_FUNCTION_NAME=$1
S3_URI="$2"

#Will need to change this if using my code since I am making this easier for my demos
LAMBDA_IAM_ROLE="arn:aws:iam::403177882230:role/myLambdaRoleForDemos"
LAMBDA_RUNTIME="python3.12"

# Validate S3 URI format
 if ! echo "$S3_URI" | grep -Eq '^s3://'; then
     echo "Error: Invalid S3 URI. Must start with 's3://'."
     usage
fi

# Parse S3 bucket and key from S3 URI
# The pattern s|^s3://\([^/]*\).*|\1| captures everything after s3:// up to the first /.
S3_BUCKET=$(echo "$S3_URI" | sed -e 's|^s3://\([^/]*\).*|\1|')

# Extract the key (path after the bucket name) using sed. The pattern s|^s3://[^/]*/|| removes s3:// and the bucket name
S3_KEY=$(echo "$S3_URI" | sed -e 's|^s3://[^/]*/||')

# Validate parsing
if [ -z "$S3_BUCKET" ] || [ -z "$S3_KEY" ]; then
     echo "Error: Failed to parse S3 bucket or key from S3 URI."
     exit 1
fi

OUTPUT=$(aws lambda create-function \
	--function-name $LAMBDA_FUNCTION_NAME \
	--runtime $LAMBDA_RUNTIME \
	--handler "${LAMBDA_FUNCTION_NAME}.lambda_handler" \
	--role $LAMBDA_IAM_ROLE \
    --code S3Bucket=$S3_BUCKET,S3Key=$S3_KEY 2>&1)

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
