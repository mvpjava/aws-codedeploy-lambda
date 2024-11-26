#!/bin/sh


if [ "$#" -ne 1 ]; then
  echo "Usage: Must specify name of lambda function"
  exit 1
fi

echo "Starting $0"
LAMBDA_FUNCTION_NAME=$1

# List all versions which are returned as a list (1 version per line). Last line is the latest/greatest versiona number.
# No pagination or else will only return upto 50 items on 1st page.
# Retrieve last line via "tail -n 1" and then extract version number reported in first field via "cut -f1"
# Sample output ...
#   $LATEST
#   12
#   13
#
# Therefore, this command would extract the version number "13"
LATEST_VERSION=$(aws lambda list-versions-by-function --no-paginate --function-name $LAMBDA_FUNCTION_NAME --query 'Versions[*].[Version]'  --output text | tail -n 1 | cut -f1)

# Check if LATEST_VERSION is valid
if [[ -z "$LATEST_VERSION" || "$LATEST_VERSION" == "\$LATEST" || "$LATEST_VERSION" -le 1 ]]; then
    # Invalid value, return -1
    echo -1
    exit 1
fi

# Return valid version
echo "$LATEST_VERSION"
