#!/bin/bash

# Get the DB Snapshot identifier dynamically from AWS CLI
SNAPSHOT_ID=$(aws rds describe-db-snapshots \
    --query "DBSnapshots[?Status=='available'] | [-1].DBSnapshotIdentifier" \
    --output text)

echo "*********************************************************************************************"
echo "Using Snapshot: $SNAPSHOT_ID"
echo "*********************************************************************************************"

# Ensure we are getting a valid snapshot
if [ "$SNAPSHOT_ID" == "None" ]; then
    echo "No available snapshot found!"
    exit 1
fi

# Set the new DB instance identifier
DB_INSTANCE_ID="${19}"

# Create the new DB instance from the snapshot (Free Tier eligible settings)
echo "*********************************************************************************************"
echo "Creating a new DB instance from the snapshot now..."

aws rds create-db-instance \
    --db-instance-identifier $DB_INSTANCE_ID \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --db-snapshot-identifier $SNAPSHOT_ID \
    --allocated-storage 10 \
    --tags Key=Name,Value=module-07 \
    --vpc-security-group-ids $RDS_SG \
    --db-subnet-group "${19}-subnet-group" \
    --master-username controller \
    --manage-master-user-password

echo "*********************************************************************************************"
echo "Waiting for the DB instance to be available..."

# Wait for the DB instance to be available
aws rds wait db-instance-available \
    --db-instance-identifier $DB_INSTANCE_ID

echo "*********************************************************************************************"
echo "DB Instance is now running and created from snapshot!"
echo "*********************************************************************************************"
