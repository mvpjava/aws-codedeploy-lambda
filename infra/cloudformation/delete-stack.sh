#!/bin/sh

STACK_NAME=all-myHelloWorld-lambdas-codedeploy-demo

aws cloudformation delete-stack --stack-name $STACK_NAME

echo "Waiting for stack to be deleted ..."

aws cloudformation wait stack-delete-complete --stack-name  $STACK_NAME