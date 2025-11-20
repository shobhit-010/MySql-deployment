#!/bin/bash

BUCKET="shobhit-mysql-tf-state"
TABLE="shobhit-mysql-tf-lock"
REGION="ap-south-1"

echo "Checking S3 bucket..."
if aws s3api head-bucket --bucket $BUCKET 2>/dev/null; then
    echo "✔ Bucket exists"
else
    echo "Creating S3 bucket..."
    aws s3api create-bucket \
        --bucket $BUCKET \
        --region $REGION \
        --create-bucket-configuration LocationConstraint=$REGION
fi

echo "Checking DynamoDB table..."
if aws dynamodb describe-table --table-name $TABLE --region $REGION 2>/dev/null; then
    echo "✔ Table exists"
else
    echo "Creating DynamoDB table..."
    aws dynamodb create-table \
        --table-name $TABLE \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region $REGION
fi

aws dynamodb wait table-exists --table-name $TABLE --region $REGION
