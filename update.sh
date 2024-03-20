#!/bin/bash

#Zip index.html
zip index.zip index.html

#Upload index.zip to the s3
bucket=$BUCKET_NAME

aws s3 cp index.zip s3://$bucket/index.zip