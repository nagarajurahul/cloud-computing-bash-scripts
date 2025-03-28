#!/bin/bash

# Function to check if an S3 bucket exists and create it if it does not
create_bucket_if_not_exists() {
    local BUCKET_NAME=$1
    local REGION=$2

    echo "Checking if bucket $BUCKET_NAME exists..."
    if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
        echo "Bucket $BUCKET_NAME exists."
    else
        echo "Bucket $BUCKET_NAME does not exist."

        echo "*********************************************************************************************"

        echo "Creating bucket $BUCKET_NAME in region $REGION..."
        
        # Use LocationConstraint for regions other than us-east-1
        if [ "$REGION" == "us-east-1" ]; then
            aws s3api create-bucket --bucket "$BUCKET_NAME"
        else
            aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" \
                --create-bucket-configuration LocationConstraint="$REGION"
        fi
        
        echo "*********************************************************************************************"
        if [ $? -eq 0 ]; then      
            echo "Bucket $BUCKET_NAME created successfully."
        else
            echo "Failed to create bucket $BUCKET_NAME."
        fi
    fi
}

# Specify region
REGION="us-east-2"

# Use arguments for bucket names
FIRST_BUCKET_NAME=${21}
SECOND_BUCKET_NAME=${22}

echo "*********************************************************************************************"
create_bucket_if_not_exists "$FIRST_BUCKET_NAME" "$REGION"

echo "*********************************************************************************************"
create_bucket_if_not_exists "$SECOND_BUCKET_NAME" "$REGION"

echo "*********************************************************************************************"
# Verify buckets were created
echo "Listing all S3 buckets..."
aws s3api list-buckets --query "Buckets[].Name"
