#!/bin/sh

echo "Starting $0"

# Usage message
usage() {
    echo "Usage: $0 <AWS CodeDeploy Application Name> <AWS CodeDeploy Deployment Group Name> <S3 URI>"
    echo
    echo "Creates an AWS CodeDeploy Deployment for Lambda function."
    echo "  <AWS CodeDeploy Application Name>  : Must already exist (required) (i.e: myHelloWorldDeployment)"
    echo "  <AWS CodeDeploy Group Name>  : Must already exist (required) (i.e:hello-world-deployment-group)"
    echo "  <S3 URI> : S3 URI where zip file with appspec.yml and all lambda artifacts are located (required) (i.e: s3://codedeploy-lambda/myHelloWorldLambda-cli/myHelloWorldLambda.zip)"
    exit 1
}

# Check required parameters
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Error: Missing required parameters."
    usage
fi

APP_NAME=$1
DEPLOYMENT_GROUP_NAME=$2
S3_URI=$3

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

# s#.*/##: Matches everything up to the last / and removes it, leaving only the filename.
#Everything after the second # is the replacement text. Here, its empty, meaning the matched part (.*/) is removed
ZIP_FILENAME=$(echo "$S3_URI" | sed 's#.*/##')


# Validate parsing
if [ -z "$S3_BUCKET" ] || [ -z "$S3_KEY" ]; then
     echo "Error: Failed to parse S3 bucket or key from S3 URI."
     exit 1
fi

echo "ZIP_FILENAME = '$ZIP_FILENAME'"

# upload latest artifacts to S3
# Run the helper script to create the ZIP file and upload to S3
./upload_codezip_to_s3.sh "$ZIP_FILENAME" "$S3_URI"

# Validate that the ZIP file has been uploaded
if [ $? -ne 0 ]; then
    echo "Error: Failed to create and upload ZIP file."
    exit 1
fi

OUTPUT=$(aws deploy create-deployment \
    --application-name $APP_NAME \
    --deployment-group-name $DEPLOYMENT_GROUP_NAME \
    --description "My demo deployment from AWS CLI command in script '$0' from GitHub repo." \
    --s3-location bucket=$S3_BUCKET,bundleType=zip,key=$S3_KEY 2>&1)

# Check if the deployment comamnd failed
if [[ $? -ne 0 ]]; then
#    if echo "$OUTPUT" | grep -q "ResourceConflictException"; then
#        echo "Error: A Lambda function with the name '$LAMBDA_FUNCTION_NAME' already exists."
#	exit 1
#    else
        echo "An unexpected error occurred: $OUTPUT"
        exit 1
#    fi
else
    echo "Deployment kicked off successfully."
fi 

echo "Exiting $0"
