#!/bin/bash


# Set the DB instance identifier and snapshot name
DB_INSTANCE_ID=${19}
SNAPSHOT_NAME="${19}-snapshot"

echo "*********************************************************************************************"
echo "Creating snapshot now..."
# https://awscli.amazonaws.com/v2/documentation/api/2.0.34/reference/rds/create-db-snapshot.html
# Create a snapshot

aws rds create-db-snapshot \
    --db-instance-identifier $DB_INSTANCE_ID \
    --db-snapshot-identifier $SNAPSHOT_NAME

# Check the snapshot status
STATUS=$(aws rds describe-db-snapshots \
    --db-snapshot-identifier $SNAPSHOT_NAME \
    --query "DBSnapshots[0].Status" --output text)

echo "*********************************************************************************************"
echo "Snapshot status: $STATUS"

# Wait for the snapshot to be available (completed)
echo "*********************************************************************************************"
echo "Waiting for the snapshot to be available..."
aws rds wait db-snapshot-completed \
    --db-snapshot-identifier $SNAPSHOT_NAME

# Check the snapshot status
STATUS=$(aws rds describe-db-snapshots \
    --db-snapshot-identifier $SNAPSHOT_NAME \
    --query "DBSnapshots[0].Status" --output text)

echo "*********************************************************************************************"
echo "Snapshot status: $STATUS"


# Optional: Delete old snapshots to avoid Free Tier storage costs
# aws rds delete-db-snapshot --db-snapshot-identifier <old-snapshot-name>
