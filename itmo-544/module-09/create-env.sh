#!/bin/bash

# Finding subnets
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-subnets.html

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


# Create launch template
# https://docs.aws.amazon.com/cli/latest/reference/ec2/create-launch-template.html

echo "*********************************************************************************************"
echo "Creating launch-template now..."

aws ec2 create-launch-template \
    --launch-template-name ${15} \
    --version-description version1 \
    --launch-template-data file://config.json


# https://docs.aws.amazon.com/cli/latest/reference/elbv2/create-load-balancer.html

echo "*********************************************************************************************"
echo "Creating load-balancer now..."

# Need to remove sg here

aws elbv2 create-load-balancer \
    --name ${8} \
    --subnets $SUBNET2A $SUBNET2B $SUBNET2C \
    --tags Key=name,Value=${13} \
    --security-groups ${4} \
    --output table

#    --security-groups ${20}\
#     --scheme internal \  -> to make it internal LB

# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-listeners.html

echo "*********************************************************************************************"
echo "Finding and storing the ELB ARN for default region"

ELBARN=$(aws elbv2 describe-load-balancers --output=text --query='LoadBalancers[*].LoadBalancerArn')

echo "*********************************************************************************************"
echo "Printing ELBARN: $ELBARN"
echo "*********************************************************************************************"


# https://docs.aws.amazon.com/cli/latest/reference/elbv2/wait/
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/wait/load-balancer-available.html

echo "*********************************************************************************************"
echo "Waiting for ELB to become available..."
aws elbv2 wait load-balancer-available --load-balancer-arns $ELBARN
echo "ELB is available..."


echo "*********************************************************************************************"
echo "Creating target groups now..."

# Find the VPC
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-vpcs.html

MYVPCID=$(aws ec2 describe-vpcs --output=text --query='Vpcs[*].VpcId')

# Create the target group - this is application load balancer type
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/create-target-group.html

aws elbv2 create-target-group \
    --name ${9} \
    --protocol HTTP \
    --port 80 \
    --target-type instance \
    --vpc-id $MYVPCID

# Describe the target groups and get target ARNs
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-target-groups.html

echo "*********************************************************************************************"
echo "Finding and storing target group ARN"

TGARN=$(aws elbv2 describe-target-groups --output=text --query='TargetGroups[*].TargetGroupArn' --names ${9})

echo "*********************************************************************************************"
echo "Target group ARN: $TGARN"
echo "*********************************************************************************************"


echo "*********************************************************************************************"
echo "Creating listeners now..."

# Creating listener
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/create-listener.html

aws elbv2 create-listener \
    --load-balancer-arn $ELBARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TGARN

echo "*********************************************************************************************"
echo "Listeners are up!"


echo "*********************************************************************************************"
echo "Creating AutoScaling Group now..."

# Create auto-scaling groups
# https://docs.aws.amazon.com/cli/latest/reference/autoscaling/create-auto-scaling-group.html
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name ${14} \
    --launch-template LaunchTemplateName=${15} \
    --target-group-arns $TGARN \
    --health-check-type ELB \
    --health-check-grace-period 120 \
    --min-size ${16} \
    --max-size ${17} \
    --desired-capacity ${18}

sleep 5

EC2IDS=$(aws ec2 describe-instances \
    --output=text \
    --query='Reservations[*].Instances[*].InstanceId' --filter Name=instance-state-name,Values=pending,running)

echo "*********************************************************************************************"
echo "Finding and storing the Instance IDs"
echo "*********************************************************************************************"
echo $EC2IDS
echo "*********************************************************************************************"

#https://docs.aws.amazon.com/cli/latest/reference/ec2/wait/
#https://docs.aws.amazon.com/cli/latest/reference/ec2/wait/instance-running.html

echo "*********************************************************************************************"
echo "Waiting for instances..."
aws ec2 wait instance-running --instance-ids $EC2IDS
echo "Instances are up!"

echo "*********************************************************************************************"
DNSNAME=$(aws elbv2 describe-load-balancers --output=text --query='LoadBalancers[*].DNSName')
DNSNAME="http://$DNSNAME"

echo "Kindly curl using the below link"
echo $DNSNAME

echo "*********************************************************************************************"
echo "Making curl request now..."
sleep 5
echo "Response is as belows "

curl $DNSNAME

echo "*********************************************************************************************"



# New scripts add below



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


# echo "*********************************************************************************************"
# echo "Finding and storing the subnet IDs for availability zones defined in arguments"

# SUBNET2A=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${10}")
# SUBNET2B=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${11}")
# SUBNET2C=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${12}")

# echo "*********************************************************************************************"
# echo $SUBNET2A
# echo $SUBNET2B
# echo $SUBNET2C
# echo "*********************************************************************************************"


# echo "Creating db subnet groups now..."

# aws rds create-db-subnet-group \
#     --db-subnet-group-name "${19}-subnet-group" \
#     --db-subnet-group-description "My DB Subnet Group" \
#     --subnet-ids $SUBNET2A $SUBNET2B $SUBNET2C

# echo "*********************************************************************************************"
# echo "Pulling db security groups now..."

# RDS_SG=$(aws ec2 describe-security-groups \
#     --filters "Name=group-name,Values=sql-security-group" \
#     --query "SecurityGroups[0].GroupId" \
#     --output text)

# echo "*********************************************************************************************"
# echo "RDS_SG: $RDS_SG"
# echo "*********************************************************************************************"

# echo "*********************************************************************************************"
# echo "Creating db instances now..."

# aws rds create-db-instance \
#     --db-instance-identifier ${19} \
#     --db-instance-class db.t3.micro \
#     --engine mysql \
#     --allocated-storage 10 \
#     --tags Key=Name,Value=module-06 \
#     --vpc-security-group-ids $RDS_SG \
#     --db-subnet-group "${19}-subnet-group" \
#     --master-username controller \
#     --manage-master-user-password


# echo "*********************************************************************************************"
# echo "Waiting for db instances to be available"

# aws rds wait db-instance-available \
#     --db-instance-identifier ${19}
 
# # aws rds wait db-instance-available \
# #     --db-instance-identifier rndbinstance


# echo "DB Instance is now running..."
# echo "*********************************************************************************************"


#     # --port 3306 \
#     # --backup-retention-period 7 \
#     # --no-multi-az \
#     # --availability-zone us-east-2a \
#     # --master-username admin \
#     # --master-user-password admin \


# Added new script for creating RDS from snapshot

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



echo "*********************************************************************************************"
echo "Pulling snapshots now..."

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

# aws rds create-db-instance \
#     --db-instance-identifier $DB_INSTANCE_ID \
#     --db-instance-class db.t3.micro \
#     --engine mysql \
#     --db-snapshot-identifier $SNAPSHOT_ID \
#     --allocated-storage 10 \
#     --tags Key=Name,Value=module-07 \
#     --vpc-security-group-ids $RDS_SG \
#     --db-subnet-group "${19}-subnet-group" \
#     --master-username controller \
#     --manage-master-user-password

aws rds restore-db-instance-from-db-snapshot \
    --db-instance-identifier $DB_INSTANCE_ID \
    --db-snapshot-identifier $SNAPSHOT_ID \
    --db-instance-class db.t3.micro \
    --tags Key=Name,Value=module-09 \
    --vpc-security-group-ids $RDS_SG \
    --db-subnet-group "${19}-subnet-group"

echo "*********************************************************************************************"
echo "Waiting for the DB instance to be available..."

# Wait for the DB instance to be available
aws rds wait db-instance-available \
    --db-instance-identifier $DB_INSTANCE_ID

echo "*********************************************************************************************"
aws rds modify-db-instance \
    --db-instance-identifier $DB_INSTANCE_ID \
    --manage-master-user-password


echo "*********************************************************************************************"
echo "DB Instance is now running and created from snapshot!"
echo "*********************************************************************************************"



# S3 Script

# https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html
# https://docs.aws.amazon.com/cli/latest/reference/s3api/head-bucket.html

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


# https://docs.aws.amazon.com/cli/latest/reference/s3api/list-buckets.html

echo "*********************************************************************************************"
# Verify buckets were created
echo "Listing all S3 buckets..."
aws s3api list-buckets --query "Buckets[].Name"


# https://docs.aws.amazon.com/cli/latest/reference/s3api/put-bucket-policy.html
# https://docs.aws.amazon.com/cli/latest/reference/s3api/put-public-access-block.html

aws s3api put-public-access-block --bucket ${21} \
    --public-access-block-configuration "BlockPublicPolicy=false"
    
aws s3api put-bucket-policy --bucket ${21} \
    --policy file://raw-bucket-policy.json


# https://docs.aws.amazon.com/cli/latest/reference/sns/create-topic.html

echo "*********************************************************************************************"
echo "Creating SNS topic now..."
aws sns create-topic \
    --name ${23}

echo "*********************************************************************************************"
