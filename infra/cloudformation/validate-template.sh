#!/bin/sh

# Check if the required number of parameters is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <Cloudformation template name>"
  exit 1
fi

CFN_TEMPLATE_NAME=$1

aws cloudformation validate-template --template-body file://$1
