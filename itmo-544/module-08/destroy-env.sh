#!/bin/bash

# Dynamically detect your infrastructure and destroy it/terminate it

# Find auto scaling group
# https://docs.aws.amazon.com/cli/latest/reference/autoscaling/describe-auto-scaling-groups.html

echo "*********************************************************************************************"
echo "Finding autoscaling group name..."

ASGNAME=$(aws autoscaling describe-auto-scaling-groups --output=text --query='AutoScalingGroups[*].AutoScalingGroupName')

echo "*********************************************************************************************"
echo "Autoscaling group name: $ASGNAME"
echo "*********************************************************************************************"

# Update the auto scaling group to remove the min and max values to zero
# https://docs.aws.amazon.com/cli/latest/reference/autoscaling/update-auto-scaling-group.html

echo "Updating $ASGNAME autoscaling group to set minimum and desired capacity to 0..."

aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name $ASGNAME \
    --health-check-type ELB \
    --min-size 0 \
    --desired-capacity 0

sleep 5
echo "$ASGNAME autoscaling group was updated!"

# Retrieve instance IDs of EC2
# Describe EC2 instances
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html

EC2IDS=$(aws ec2 describe-instances \
    --output=text \
    --query='Reservations[*].Instances[*].InstanceId' --filter Name=instance-state-name,Values=pending,running )

echo "*********************************************************************************************"

echo "Waiting for instances to be terminated..." 
aws ec2 wait instance-terminated --instance-ids $EC2IDS
echo "Instances are terminated!"

echo "*********************************************************************************************"



# Finding taget group ARN
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-target-groups.html

echo "Finding and storing the target group ARN for default region"

TGARN=$(aws elbv2 describe-target-groups --output=text --query='TargetGroups[*].TargetGroupArn' --names ${9})

echo "*********************************************************************************************"
echo "TGARN: $TGARN"
echo "*********************************************************************************************"



echo "Finding and storing the ELB ARNS for default region"

ELBARN=$(aws elbv2 describe-load-balancers --output=text --query='LoadBalancers[*].LoadBalancerArn')

echo "*********************************************************************************************"
echo "ELBARN: $ELBARN"
echo "*********************************************************************************************"

# First Query to get the ELB name using the --query and --filters
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-listeners.html

echo "Finding and storing the Listener ARN for default region"

LISTARN=$(aws elbv2 describe-listeners --load-balancer-arn $ELBARN --output=text --query='Listeners[*].ListenerArn' )

echo "*********************************************************************************************"
echo "LISTARN: $LISTARN"
echo "*********************************************************************************************"


echo "Deleting listener now..."
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/delete-listener.html

aws elbv2 delete-listener --listener-arn $LISTARN

echo "Listeners deleted!"
echo "*********************************************************************************************"


# Deleting target group, and wait for it to deregister

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/delete-target-group.html
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/wait/target-deregistered.html
# First Query to get the ELB name using the --query and --filters
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-listeners.html


echo "Deleting Target Group now..."

aws elbv2 delete-target-group --target-group-arn $TGARN
# Error here because it's already deleted!
# aws elbv2 wait target-deregistered --target-group-arn $TGARN

echo "Target groups deleted!"
echo "*********************************************************************************************"


# Delete loadbalancer
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/delete-load-balancer.html

echo "Deleting load-balancers now..."

aws elbv2 delete-load-balancer --load-balancer-arn $ELBARN

echo "Waiting for load-balancer to be deleted..."
aws elbv2 wait load-balancers-deleted --load-balancer-arns $ELBARN
echo "Load balancers deleted!"

echo "*********************************************************************************************"
echo "Deleting $ASGNAME auto scaling group now"


aws autoscaling suspend-processes \
    --auto-scaling-group-name $ASGNAME

aws autoscaling delete-auto-scaling-group \
    --auto-scaling-group-name $ASGNAME
echo "$ASGNAME autoscaling group was deleted!"


# Find the launch configuration template
# https://docs.aws.amazon.com/cli/latest/reference/autoscaling/describe-launch-configurations.html

echo "*********************************************************************************************"
echo "Retrieving launch configuration name..."

LTNAME=$(aws ec2 describe-launch-templates --output=text --query='LaunchTemplates[*].LaunchTemplateName')

echo "*********************************************************************************************"
echo "Launch template name: $LTNAME"
echo "*********************************************************************************************"

# Delete the launch configuration template file

# https://docs.aws.amazon.com/cli/latest/reference/autoscaling/delete-launch-configuration.html

echo "Deleting $LTNAME launch template..."

aws ec2 delete-launch-template \
    --launch-template-name $LTNAME

echo "$LTNAME launch configuration was deleted!"


echo "*********************************************************************************************"
echo "Fetching DB subnet groups..."

# Fetch associated DB Subnet Group dynamically
DB_SUBNET_GROUP=$(aws rds describe-db-subnet-groups \
    --query "DBSubnetGroups[?DBSubnetGroupName!=''].DBSubnetGroupName" \
    --output text)

if [ -z "$DB_SUBNET_GROUP" ]; then
    echo "No DB subnet groups found. Exiting."
    # exit 1
fi

echo "Found DB subnet group(s): $DB_SUBNET_GROUP"


# New script added here

echo "*********************************************************************************************"
echo "Fetching DB instance identifier..."

# Fetch the DB instance identifier dynamically
DB_INSTANCE_ID=$(aws rds describe-db-instances \
    --query "DBInstances[0].DBInstanceIdentifier" \
    --output text)

if [ "$DB_INSTANCE_ID" == "None" ]; then
    echo "No DB instances found. Exiting."
    # exit 1
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
    # echo "Deleting DB subnet group: $SUBNET_GROUP..."
    aws rds delete-db-subnet-group \
        --db-subnet-group-name $SUBNET_GROUP
    echo "DB subnet group '$SUBNET_GROUP' has been deleted!"
done

echo "*********************************************************************************************"


# echo "*********************************************************************************************"
# echo "All DB subnet groups have been deleted!"
# echo "*********************************************************************************************"





# Destroy S3 added here

# Function to delete an S3 bucket and all its contents
delete_bucket() {
    
    local BUCKET_NAME=$1

    echo "*********************************************************************************************"
    echo "Checking if bucket $BUCKET_NAME exists..."
    if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
        echo "Bucket $BUCKET_NAME exists. Deleting all objects..."
        echo "*********************************************************************************************"

        # Delete all objects in the bucket
        aws s3 rm "s3://$BUCKET_NAME" --recursive
        if [ $? -eq 0 ]; then
            echo "All objects in $BUCKET_NAME deleted successfully."
        else
            echo "Failed to delete objects in $BUCKET_NAME."
            return 1
        fi
        
        echo "*********************************************************************************************"

        # Delete the bucket
        echo "Deleting bucket $BUCKET_NAME..."
        aws s3api delete-bucket --bucket "$BUCKET_NAME"
        if [ $? -eq 0 ]; then
            echo "Bucket $BUCKET_NAME deleted successfully."
        else
            echo "Failed to delete bucket $BUCKET_NAME."
        fi

        echo "*********************************************************************************************"

    else
        echo "Bucket $BUCKET_NAME does not exist or cannot be accessed."
    fi
}

# # Bucket names from arguments
# FIRST_BUCKET_NAME=${21}
# SECOND_BUCKET_NAME=${22}

# delete_bucket "$FIRST_BUCKET_NAME"

# delete_bucket "$SECOND_BUCKET_NAME"

echo "*********************************************************************************************"

# Retrieve a list of all bucket names
BUCKETS=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

# Iterate over the list of bucket names and delete each one
for BUCKET_NAME in $BUCKETS; do
    delete_bucket "$BUCKET_NAME"
done


echo "*********************************************************************************************"
# Verify buckets were deleted
echo "Listing remaining S3 buckets..."
aws s3api list-buckets --query "Buckets[].Name"
