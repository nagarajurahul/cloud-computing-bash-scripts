#!/bin/bash

# Create DB Instance for MySQL using AWS RDS

# References

# https://docs.aws.amazon.com/cli/latest/reference/rds/#cli-aws-rds
# https://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html

# First 3 options are mandatory
# db-instance-identifier - should be unique
# db.t3.micro, no-multi-az and 20 for storage - free-tier
# Please make sure, these are the same values for free-tier
# By default, MySQL listens on port 3306
# Feel free to add tags if required


echo "*********************************************************************************************"
echo "Finding and storing the subnet IDs for availability zones defined in arguments"

SUBNET2A=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${10}")
SUBNET2B=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${11}")
SUBNET2C=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${12}")

echo "*********************************************************************************************"
echo $SUBNET2A
echo $SUBNET2B
echo $SUBNET2C
echo "*********************************************************************************************"


echo "Creating db subnet groups now..."

aws rds create-db-subnet-group \
    --db-subnet-group-name "${19}-subnet-group" \
    --db-subnet-group-description "My DB Subnet Group" \
    --subnet-ids $SUBNET2A $SUBNET2B $SUBNET2C

echo "*********************************************************************************************"


echo "Pulling db security groups now..."

RDS_SG=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=sql-security-group" \
    --query "SecurityGroups[0].GroupId" \
    --output text)

echo "*********************************************************************************************"
echo "RDS_SG: $RDS_SG"
echo "*********************************************************************************************"

echo "Creating db instances now..."

aws rds create-db-instance \
    --db-instance-identifier ${19} \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --allocated-storage 10 \
    --tags Key=Name,Value=module-06 \
    --vpc-security-group-ids $RDS_SG \
    --db-subnet-group "${19}-subnet-group" \
    --master-username controller \
    --manage-master-user-password

echo "*********************************************************************************************"

echo "Waiting for db instances to be available"

aws rds wait db-instance-available \
    --db-instance-identifier ${19}
 
# aws rds wait db-instance-available \
#     --db-instance-identifier rndbinstance


echo "DB Instance is now running..."
echo "*********************************************************************************************"


aws rds describe-db-instances --query='DBInstances[*].DBInstanceIdentifier'

    # --port 3306 \
    # --backup-retention-period 7 \
    # --no-multi-az \
    # --availability-zone us-east-2a \
    # --master-username admin \
    # --master-user-password admin \