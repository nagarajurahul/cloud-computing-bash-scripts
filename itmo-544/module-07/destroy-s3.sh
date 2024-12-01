#!/bin/bash

# Function to delete an S3 bucket and all its contents
delete_bucket() {
    
    local BUCKET_NAME=$1

    echo "*********************************************************************************************"
    echo "Checking if bucket $BUCKET_NAME exists..."
    if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
        echo "Bucket $BUCKET_NAME exists. Deleting all objects..."
        
        # Delete all objects in the bucket
        aws s3 rm "s3://$BUCKET_NAME" --recursive
        if [ $? -eq 0 ]; then
            echo "All objects in $BUCKET_NAME deleted successfully."
        else
            echo "Failed to delete objects in $BUCKET_NAME."
            return 1
        fi
        
        # Delete the bucket
        echo "Deleting bucket $BUCKET_NAME..."
        aws s3api delete-bucket --bucket "$BUCKET_NAME"
        if [ $? -eq 0 ]; then
            echo "Bucket $BUCKET_NAME deleted successfully."
        else
            echo "Failed to delete bucket $BUCKET_NAME."
        fi
    else
        echo "Bucket $BUCKET_NAME does not exist or cannot be accessed."
    fi
}

# Bucket names from arguments
FIRST_BUCKET_NAME=${21}
SECOND_BUCKET_NAME=${22}

echo "*********************************************************************************************"
delete_bucket "$FIRST_BUCKET_NAME"

echo "*********************************************************************************************"
delete_bucket "$SECOND_BUCKET_NAME"

echo "*********************************************************************************************"
# Verify buckets were deleted
echo "Listing remaining S3 buckets..."
aws s3api list-buckets --query "Buckets[].Name"
