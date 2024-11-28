#!/bin/sh

# Usage message
usage() {
    echo "Usage: $0 <Lambda Function Name> "
    echo
    echo "Creates a version from the current code and configuration of a function."
    echo "  <Lambda Function Name>  : The name of the Lambda function (required)"
    exit 1
}

# Check required parameters
if [ -z "$1" ]; then
    echo "Error: Missing required parameters."
    usage
fi

# Assign parameters to variables
LAMBDA_FUNCTION_NAME="$1"

NEW_VERSION=$(aws lambda publish-version \
    --function-name $LAMBDA_FUNCTION_NAME \
    --query Version --output text 2>&1 )

# Check if the creation failed due to the function already existing
if echo "$NEW_VERSION" | grep -q "ResourceNotFoundException"; then
        echo "Error: Lambda function with the name '$LAMBDA_FUNCTION_NAME' does not exists."
        exit 1
fi

echo "Published '$LAMBDA_FUNCTION_NAME' with new version #: '$NEW_VERSION'."

exit 0
