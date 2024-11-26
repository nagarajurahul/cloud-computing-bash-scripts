#!/bin/bash
echo "*********************************************************************************************"
echo "Fetching DB subnet groups..."

# Fetch associated DB Subnet Group dynamically
DB_SUBNET_GROUP=$(aws rds describe-db-subnet-groups \
    --query "DBSubnetGroups[?DBSubnetGroupName!=''].DBSubnetGroupName" \
    --output text)

if [ -z "$DB_SUBNET_GROUP" ]; then
    echo "No DB subnet groups found. Exiting."
    exit 1
fi

echo "Found DB subnet group(s): $DB_SUBNET_GROUP"




echo "*********************************************************************************************"
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



echo "*********************************************************************************************"
echo "Deleting db-instances now..."

aws rds delete-db-instance \
    --db-instance-identifier $DB_INSTANCE_ID \
    --skip-final-snapshot

echo "*********************************************************************************************"
echo "Waiting for db-instances to be deleted..."

aws rds wait db-instance-deleted \
    --db-instance-identifier $DB_INSTANCE_ID


echo "DB-Instances are deleted!!"


echo "*********************************************************************************************"
echo "Deleting DB subnet groups now..."

# Loop through and delete each DB subnet group
for SUBNET_GROUP in $DB_SUBNET_GROUP; do
    echo "Deleting DB subnet group: $SUBNET_GROUP..."
    aws rds delete-db-subnet-group \
        --db-subnet-group-name $SUBNET_GROUP
    echo "DB subnet group '$SUBNET_GROUP' has been deleted!"
done

echo "*********************************************************************************************"
echo "All DB subnet groups have been deleted!"
echo "*********************************************************************************************"