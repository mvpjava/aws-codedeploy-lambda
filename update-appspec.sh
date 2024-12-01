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

# Verify if lambda function past in exists.
aws lambda get-function --function-name $LAMBDA_FUNCTION_NAME  > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Error: Function '$LAMBDA_FUNCTION_NAME does not exist."
    exit 1
fi

# Verify if alias past in exists.
aws lambda get-alias --function-name $LAMBDA_FUNCTION_NAME --name $LAMBDA_ALIAS  > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Error: Alias '$LAMBDA_ALIAS does not exist for Lambda function '$LAMBDA_FUNCTION_NAME'."
    exit 1
fi

# Verify if current version of lambda function exists.
ALL_VERSIONS=$(aws lambda list-versions-by-function --no-paginate --function-name $LAMBDA_FUNCTION_NAME --query 'Versions[*].[Version]'  --output text)

if ! echo "$ALL_VERSIONS" | grep -q "$CURRENT_LAMBDA_VERSION"; then
    echo "Function $LAMBDA_FUNCTION_NAME does NOT have a current version number: '$CURRENT_LAMBDA_VERSION'"
    exit 1
fi

# Verify if target version of lambda function exists.
if ! echo "$ALL_VERSIONS" | grep -q "$TARGET_LAMBDA_VERSION"; then
    echo "Function $LAMBDA_FUNCTION_NAME does NOT have a target version number: '$TARGET_LAMBDA_VERSION'"
    exit 1
fi

# Perform text substitutions in appspec.yml
# Perform in place (-i) substitutions
sed -i "s/{{LAMBDA_FUNCTION_NAME}}/$LAMBDA_FUNCTION_NAME/g" "$APPSPEC_FILE"
sed -i "s/{{LAMBDA_ALIAS}}/$LAMBDA_ALIAS/g" "$APPSPEC_FILE"
sed -i "s/{{CURRENT_LAMBDA_VERSION}}/$CURRENT_LAMBDA_VERSION/g" "$APPSPEC_FILE"
sed -i "s/{{TARGET_LAMBDA_VERSION}}/$TARGET_LAMBDA_VERSION/g" "$APPSPEC_FILE"

echo "Substitutions completed in $APPSPEC_FILE."


echo "Exiting $0"
