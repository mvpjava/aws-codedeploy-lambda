#!/bin/sh

# Usage message
usage() {
    echo "Usage: $0 <Lambda Function Name> <Zip filename> "
    echo
    echo "Updates a Lambda function’s code. Replaces the code of the unpublished (\$LATEST) version with contents of the specified zip file."
    echo "  <Lambda Function Name>  : The name of the Lambda function"
    echo "  <Zip filename with lambda code> : Zip filename (i.e: myHelloWorldLambda.zip)"
    exit 1
}

# Check required parameters
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Missing required parameters."
    usage
fi

# Assign parameters to variables
LAMBDA_FUNCTION_NAME="$1"
ZIP_FILENAME="$2"

OUTPUT=$(aws lambda update-function-code \
    --function-name  $LAMBDA_FUNCTION_NAME \
    --zip-file "fileb://$ZIP_FILENAME" 2>&1)

# Check if the creation failed due to the function already existing
if [[ $? -eq 0 ]]; then
    echo "Updated function '$LAMBDA_FUNCTION_NAME' in \$LATEST unpublised version"
else
    echo "Error occurred. $OUTPUT"
    exit 1 
fi

exit 0
