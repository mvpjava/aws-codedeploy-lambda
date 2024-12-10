#!/bin/sh

# Usage message
usage() {
    echo "Usage: $0 <Lambda Function Name> <S3 URI> "
    echo
    echo "Updates a Lambda function’s code. Replaces the code of the unpublished (\$LATEST) version with code already pre-uploaded to S3 as per URI location specified."
    echo "  <Lambda Function Name>  : The name of the Lambda function"
    echo "  <S3 URI> : S3 URI where to upload zip file to (i.e: s3://codedeploy-lambda/folder1/)"
    exit 1
}

# Check required parameters
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Missing required parameters."
    usage
fi

# Assign parameters to variables
LAMBDA_FUNCTION_NAME="$1"
# Convention is to look for a zip file in current directory which has same name as lambda function past in
ZIP_FILENAME="${LAMBDA_FUNCTION_NAME}.zip"
S3_URI="$2"

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

# Create zip file automatically to include the update
# Check if the helper script exists
if [ ! -x "./upload_codezip_to_s3.sh" ]; then
    echo "Error: 'upload_codezip_to_s3.sh' script not found or not executable in the current directory."
    exit 1
fi

# Run the helper script to create the ZIP file and upload to S3
./upload_codezip_to_s3.sh "$ZIP_FILENAME" "$S3_URI"

# Validate that the ZIP file has been uploaded
if [ $? -ne 0 ]; then
    echo "Error: Failed to create and upload ZIP file."
    exit 1
fi

S3_KEY="$S3_KEY${ZIP_FILENAME}"

OUTPUT=$(aws lambda update-function-code \
    --function-name  $LAMBDA_FUNCTION_NAME \
    --s3-bucket $S3_BUCKET \
    --s3-key $S3_KEY  2>&1)

# Check if the creation failed due to the function already existing
if [[ $? -eq 0 ]]; then
    echo "Updated function '$LAMBDA_FUNCTION_NAME' in \$LATEST unpublised version" >&2
else
    echo "Error occurred. $OUTPUT"
    exit 1 
fi

exit 0
