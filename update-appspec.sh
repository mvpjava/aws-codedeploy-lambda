#!/bin/sh

####################### Start of Function Section ######################

# Function to print an error message and exit
error_exit() {
    echo "Error: $1" >&2
    usage
}

# Usage function for help
usage() {
    echo "Usage: $0 <lambda-function-name> <lambda-alias> <current-version> <target-version>"
    echo
    echo "Arguments:"
    echo "  <lambda-function-name>   Name of the Lambda function. Required."
    echo "  <lambda-alias>           Alias for the Lambda function. Required."
    echo "                           Must not exceed 30 characters."
    echo "  <current-version>        Current version of the Lambda function. Required."
    echo "                           Must be a positive integer > 1"
    echo "  <target-version>         Target version to update the alias to. Required."
    echo "                           Must be a positive integer > 1"
    echo "                           and not the same as the current version."
    echo
    echo "Example:"
    echo "  $0 my-function my-alias 1 2"
    echo
    exit 1
}
# Helper function to check valid version numbers
is_valid_version() {
    local version="$1"
    # Version must be a number, not 0, and cannot have leading zero
    [[ "$version" =~ ^[1-9][0-9]*$ ]]
}

####################### End of Function Section ######################

# Assign parameters to variables
LAMBDA_FUNCTION_NAME="$1"
LAMBDA_ALIAS="$2"
CURRENT_LAMBDA_VERSION="$3"
TARGET_LAMBDA_VERSION="$4"
APPSPEC_FILE="./appspec.yml"

# Check if --help or -h is passed or if arguments are missing
if [[ "$1" == "--help" || "$1" == "-h" || $# -lt 4 ]]; then
    usage
fi

# Validate parameters
# Validate Lambda function name
if [ -z "$LAMBDA_FUNCTION_NAME" ]; then
    error_exit "Lambda function name is required."
fi

# Validate Lambda alias
if [ -z "$LAMBDA_ALIAS" ]; then
    error_exit "Lambda function alias is required."
elif [ ${#LAMBDA_ALIAS} -gt 30 ]; then
    error_exit "Lambda function alias must not exceed 30 characters."
fi

# Validate current Lambda version
if [ -z "$CURRENT_LAMBDA_VERSION" ]; then
    error_exit "Current Lambda function version is required."
elif ! is_valid_version "$CURRENT_LAMBDA_VERSION"; then
    error_exit "Invalid current lambda version number. Must be > 1"
fi

# Validate target Lambda version
if [ -z "$TARGET_LAMBDA_VERSION" ]; then
    error_exit "Target Lambda function version is required."
elif ! is_valid_version "$TARGET_LAMBDA_VERSION"; then
    error_exit "Invalid target lambda version number. Must be > 1"
elif [ "$TARGET_LAMBDA_VERSION" -eq "$CURRENT_LAMBDA_VERSION" ]; then
    error_exit "Target Lambda function version cannot be == to current version."
fi

# Display parameter values for confirmation
echo "Lambda function name: $LAMBDA_FUNCTION_NAME"
echo "Lambda function alias: $LAMBDA_ALIAS"
echo "Current Lambda function version: $CURRENT_LAMBDA_VERSION"
echo "Target Lambda function version: $TARGET_LAMBDA_VERSION"

# Verify if alias past in, exists.
aws lambda get-alias --function-name $LAMBDA_FUNCTION_NAME --name $LAMBDA_ALIAS  > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Error: Alias '$LAMBDA_ALIAS does not exist for Lambda function '$LAMBDA_FUNCTION_NAME'."
    exit 1
fi



currentAliasVersion=$(aws lambda get-alias     \
    --function-name $LAMBDA_FUNCTION_NAME \
    --name $LAMBDA_ALIAS                   \
    --query FunctionVersion               \
    --output text 2>&1 )

# Check if the alias exists
if [ -z "$currentAliasVersion" ]; then
    echo "Alias '$ALIAS_NAME' does not exist for function '$LAMBDA_FUNCTION_NAME'. Exiting $0"
    exit 1
fi

echo "Alias $ALIAS_NAME current pointing to version: '$currentAliasVersion'"

#TODO: Get new version and massage appspec.yml file
#Still work in progress

echo "Exiting $0"
