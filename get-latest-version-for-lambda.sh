#!/bin/sh


if [ "$#" -ne 1 ]; then
  echo "Usage: Must specify name of lambda function"
  exit 1
fi

echo "Starting $0"

# List all versions which are returned as a list (1 version per line). Last line is the latest/greatest versiona number.
# No pagination or else will only return upto 50 items on 1st page.
# Retrieve last line via "tail -n 1" and then extract version number reported in first field via "cut -f1"
# Sample output ...
#   $LATEST
#   12
#   13
#
# Therefore, this command would extract the version number "13"
currentVersion=$(aws lambda list-versions-by-function --no-paginate --function-name myHelloWorldLambda --query 'Versions[*].[Version]'  --output text | tail -n 1 | cut -f1)

echo "Current lastest version published is: $currentVersion"

echo "Exiting $0"
