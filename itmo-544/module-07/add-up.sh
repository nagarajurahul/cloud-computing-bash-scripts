#!/bin/bash

echo "Fetching the RDS snapshots..."

RDS_SNAPSHOT=$(aws rds describe-db-snapshots \
    --query "DBSnapshots[?Status=='available'] | [-1].DBSnapshotIdentifier" \
    --output text)

if [ "$RDS_SNAPSHOT" == "None" ]; then
    echo "No available RDS snapshots found. Exiting..."
    exit 1
fi

echo "Found RDS Snapshot: $RDS_SNAPSHOT"


echo "Creating a new RDS instance from snapshot: $RDS_SNAPSHOT"

aws rds restore-db-instance-from-db-snapshot \
    --db-instance-identifier ${19} \
    --db-snapshot-identifier $RDS_SNAPSHOT \
    --db-instance-class db.t3.micro \
    --availability-zone us-east-1a

echo "Waiting for the new RDS instance to be available..."
aws rds wait db-instance-available \
    --db-instance-identifier ${19}

echo "RDS instance ${19} created successfully from snapshot $RDS_SNAPSHOT."


REGION=$("us-east-1")

if aws s3api head-bucket --bucket "${21}"; then
    echo "Bucket ${21} exists."
else
    echo "Bucket ${21} does not exist."
    echo "Creating Bucket ${21} in Region $REGION"
    aws s3api create-bucket --bucket "${21}" --region "$REGION" \
            --create-bucket-configuration LocationConstraint="$REGION"
        if [ $? -eq 0 ]; then
            echo "Bucket ${21} created successfully."
        else
            echo "Failed to create bucket ${21}."
        fi
fi



# Verify buckets were created
echo "Listing all S3 buckets..."
aws s3api list-buckets --query "Buckets[].Name"