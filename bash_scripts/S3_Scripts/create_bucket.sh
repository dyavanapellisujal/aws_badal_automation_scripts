#!/bin/bash

bucket_name="$1"

if [ -z $bucket_name ];
then
	echo "Please provide the bucket name to run the script"
else

	aws s3api create-bucket --bucket $bucket_name --create-bucket-configuration LocationConstraint=ap-south-1 
fi
