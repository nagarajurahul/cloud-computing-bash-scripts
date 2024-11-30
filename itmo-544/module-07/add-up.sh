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
