#!/bin/sh

# Usage message
usage() {
    echo "Usage: $0 <Lambda Function Name> <Alias Name (Max 30 chars)> [Lambda Version]"
    echo
    echo "Creates a Lambda alias pointing to a published version."
    echo "  <Lambda Function Name>  : The name of the Lambda function (required)"
    echo "  <Alias Name>            : The name of the alias (max 30 characters, required)"
    echo "  [Lambda Version]        : The Lambda version number (optional, defaults to latest published version)"
    exit 1
}

# Check required parameters
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Missing required parameters."
    usage
fi

# Assign parameters to variables
LAMBDA_FUNCTION_NAME="$1"
ALIAS_NAME="$2"
LAMBDA_VERSION="$3"

# Validate alias name length
if [ ${#ALIAS_NAME} -gt 30 ]; then
    echo "Error: Alias name exceeds 30 characters."
    exit 2
fi

# Set default for optional parameter
if [ -z "$LAMBDA_VERSION" ]; then
    echo "No version specified. Using the latest published version."
    LAMBDA_VERSION=$(bash ./get-latest-version-for-lambda.sh $LAMBDA_FUNCTION_NAME)

    if [ "$LAMBDA_VERSION" = "-1" ]; then
        echo "No version yet published or an error occurred. Probably only \$LATEST un-published version exists"
        echo "Listing all versions below for you tpo confirm ..."
        aws lambda list-versions-by-function --no-paginate --function-name $LAMBDA_FUNCTION_NAME --query 'Versions[*].[Version]' --output json
        exit 1
    fi
fi

# Echo for debug (optional)
echo "Lambda Function Name: $LAMBDA_FUNCTION_NAME"
echo "Alias Name          : $ALIAS_NAME"
echo "Lambda Version      : $LAMBDA_VERSION"

# AWS CLI command to create or update a Lambda alias
OUTPUT=$(aws lambda create-alias \
    --function-name $LAMBDA_FUNCTION_NAME \
    --name $ALIAS_NAME \
    --function-version $LAMBDA_VERSION 2>&1)

# Check if the creation failed due to the function already existing
if [[ $? -ne 0 ]]; then
    if echo "$OUTPUT" | grep -q "ResourceConflictException"; then
        echo "Function $LAMBDA_FUNCTION_NAME already has an alias with name $ALIAS_NAME that exists. Will update existing alias with latest published version number '$LAMBDA_VERSION'"

	aws lambda update-alias \
            --function-name $LAMBDA_FUNCTION_NAME \
            --function-version $LAMBDA_VERSION \
            --name $ALIAS_NAME

    elif echo "$OUTPUT" | grep -q "ResourceNotFoundException"; then
        echo "Function $LAMBDA_FUNCTION_NAME does not exist or no such version was published. Unable to create alias"
        exit 1
    elif echo "$OUTPUT" | grep -q "ValidationException"; then
        echo "Version $LAMBDA_VERSION must satisfy regular expression pattern: (\$LATEST|[0-9]+). Unable to create alias"
	exit 1
    else
        echo "An unexpected error occurred: $OUTPUT"
        exit 1
    fi
else
    echo "Alias '$ALIAS_NAME' created for Lambda function '$LAMBDA_FUNCTION_NAME' pointing to version '$LAMBDA_VERSION'."
fi


exit 0
