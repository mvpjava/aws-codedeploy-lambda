#!/bin/sh

APPSPEC_FILE="./appspec.yml"

if [ "$#" -ne 1 ]; then
  echo "Usage: Must specify name of lambda function"
  exit 1
fi

echo "Starting $0"

REGION=eu-west-2
LAMBDA_FUNCTION_NAME=$1
ALIAS_NAME="nosuch-alias"
echo $ALIAS_NAME

currentAliasVersion=$(aws lambda get-alias     \
    --region=$REGION                      \
    --function-name $LAMBDA_FUNCTION_NAME \
    --name $ALIAS_NAME                    \
    --query FunctionVersion               \
    --output text 2> /dev/null )

# Check if the alias exists
if [ -z "$currentAliasVersion" ]; then
    echo "Alias '$ALIAS_NAME' does not exist for function '$LAMBDA_FUNCTION_NAME'. Exiting $0"
    exit 1
fi

echo "Alias $ALIAS_NAME current pointing to version $currentAliasVersion"

#TODO: Get new version and massage appspec.yml file
#Still work in progress

echo "Exiting $0"
