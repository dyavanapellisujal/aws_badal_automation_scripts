#!/bin/bash

echo "creating the resources using the template"

aws cloudformation deploy --template-file template.yaml --region ap-south-1 --stack-name cfn-prac-stack
