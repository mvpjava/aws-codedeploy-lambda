#!/bin/sh 

# Usage message
usage() {
    echo "Usage: $0 <S3 Bucket Name> <S3 Bucket Key>"
    echo
    echo "Validates the required parameters for deploying a CloudFormation template."
    echo
    echo "  <S3 Bucket Name>               : The name of the S3 bucket (required)."
    echo "  <S3 Bucket Key>                : The key (path) in the S3 bucket for the CloudFormation template (required)."
    echo
    echo "Example: $0 codedeploy-lambda  myHelloWorldLambda-cli/myHelloWorldLambda.zip"
    exit 1
}

# Validate input parameters
if [ $# -ne 2 ]; then
    echo "Error: Missing required parameters."
    usage
fi

# Assign parameters to variables
S3_BUCKET="$1"
S3_KEY="$2"

echo "S3_BUCKET = $S3_BUCKET"
echo "S3_KEY = $S3_KEY"

# Validate S3 bucket name
if [[ ! "$S3_BUCKET" =~ ^[a-z0-9.-]{3,63}$ ]]; then
    echo "Error: Invalid S3 bucket name $S3_BUCKET. Bucket names must be 3-63 characters long, "
    echo "consist of lowercase letters, numbers, dots, or hyphens, and cannot start or end with a hyphen or dot."
    exit 1
fi

# Validate S3 key
# (/[^/]+): Matches a slash (/) followed by one or more characters that are not slashes.\
# *: Matches zero or more occurrences of the preceding group.
# This allows for paths with multiple segments, like folder/subfolder/file.
# $ represents end of line
if [[ ! "$S3_KEY" =~ ^[^/]+(/[^/]+)*$ ]]; then
    echo "Error: Invalid S3 key '$S3_KEY'. S3 keys must be a valid path without leading slashes."
    exit 1
fi

STACK_NAME=all-myHelloWorld-lambdas-codedeploy-demo
CFN_TEMPLATE_FILENAME=create-all-lambdas-template.json

# Validate CloudFormation template file existence
if [ ! -f "$CFN_TEMPLATE_FILENAME" ]; then
    echo "Error: CloudFormation template file '$CFN_TEMPLATE_FILENAMEf' does not exist."
    exit 1
fi

echo "Creating Stack"

./validate-template.sh "$CFN_TEMPLATE_FILENAME" || { echo "CloudFormation template Validation failed"; exit 1; }

# Adding the --capabilities CAPABILITY_NAMED_IAM option tells CloudFormation that youre aware the stack will create or modify IAM resources. 
# This is a security precaution to prevent accidental modifications to IAM roles and permissions.

aws cloudformation create-stack \
  --stack-name $STACK_NAME  \
  --template-body file://$CFN_TEMPLATE_FILENAME \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters \
    ParameterKey=S3Bucket,ParameterValue="$S3_BUCKET" \
    ParameterKey=S3Key,ParameterValue="$S3_KEY"

# Check if the last command was successful
if [ $? -ne 0 ]; then
  echo "Previous command failed, exiting $0"
  exit 1
fi

echo "Waiting for Stack to be complete ..."

aws cloudformation wait stack-create-complete \
	    --stack-name $STACK_NAME

echo "Complete."