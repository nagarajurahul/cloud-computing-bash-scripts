#!/bin/bash

echo "Fetching DB instance identifier..."

# Fetch the DB instance identifier dynamically
DB_INSTANCE_ID=$(aws rds describe-db-instances \
    --query "DBInstances[0].DBInstanceIdentifier" \
    --output text)

if [ "$DB_INSTANCE_ID" == "None" ]; then
    echo "No DB instances found. Exiting."
    exit 1
fi

echo "Found DB instance: $DB_INSTANCE_ID"


echo "Deleting db-instances now..."

aws rds delete-db-instance \
    --db-instance-identifier $DB_INSTANCE_ID \
    --skip-final-snapshot


echo "Waiting for db-instances to be deleted..."

aws rds wait db-instance-deleted \
    --db-instance-identifier $DB_INSTANCE_ID


echo "DB-Instances are deleted!!"