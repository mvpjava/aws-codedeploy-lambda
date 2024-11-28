#!/bin/sh

# Usage message
usage() {
    echo "Usage: $0 <Zip filename> <S3 URI>"
    echo
    echo "Creates a zip file with filename specified and uploads to S3 URI location specified."
    echo "  <Zip filename>  : The name of the zip filename (required) (i.e: myzip.zip)"
    echo "  <S3 URI>        : S3 URI where to upload zip file to (required) (i.e: s3://codedeploy-lambda/folder1/)"
    exit 1
}

# Check required parameters
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Missing required parameters."
    usage
fi

# Assign parameters to variables
ZIP_FILENAME="$1"
S3_URI="$2"

# Validate that the zip filename ends with .zip
if ! echo "$ZIP_FILENAME" | grep -Eq '\.zip$'; then
    echo "Error: Zip filename must end with '.zip'."
    usage
fi

# Validate that the S3 URI starts with 's3://'
if ! echo "$S3_URI" | grep -Eq '^s3://'; then
    echo "Error: S3 URI must start with 's3://'."
    usage
fi


REGION=eu-west-2

zip myHelloWorldLambda.zip myHelloWorldLambda.py 
aws s3 cp myHelloWorldLambda.zip s3://codedeploy-lambda/myHelloWorldLambda-cli/ --region $REGION
