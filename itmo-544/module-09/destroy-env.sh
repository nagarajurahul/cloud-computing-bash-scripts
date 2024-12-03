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


# Using a for loop as a timer
echo "*********************************************************************************************"
echo "Waiting for 10 seconds..."
for i in {10..1}; do
    echo "Waiting... $i seconds remaining"
    sleep 1
done
echo "*********************************************************************************************"


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



# Finding target group ARN
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


# Using a for loop as a timer
echo "*********************************************************************************************"
echo "Waiting for 10 seconds..."
for i in {10..1}; do
    echo "Waiting... $i seconds remaining"
    sleep 1
done
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


# Using a for loop as a timer
echo "*********************************************************************************************"
echo "Waiting for 10 seconds..."
for i in {10..1}; do
    echo "Waiting... $i seconds remaining"
    sleep 1
done
echo "*********************************************************************************************"



echo "*********************************************************************************************"
echo "Deleting $ASGNAME auto scaling group now"

# https://docs.aws.amazon.com/cli/latest/reference/autoscaling/suspend-processes.html

aws autoscaling suspend-processes \
    --auto-scaling-group-name $ASGNAME

echo "Suspend processes in progress..."

# Using a for loop as a timer
echo "*********************************************************************************************"
echo "Waiting for 10 seconds..."
for i in {10..1}; do
    echo "Waiting... $i seconds remaining"
    sleep 1
done
echo "*********************************************************************************************"

# https://docs.aws.amazon.com/cli/latest/reference/autoscaling/delete-auto-scaling-group.html

aws autoscaling delete-auto-scaling-group \
    --auto-scaling-group-name $ASGNAME
echo "$ASGNAME autoscaling group was deleted!"



# Find the launch configuration template
# https://docs.aws.amazon.com/cli/latest/reference/autoscaling/describe-launch-configurations.html
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-launch-templates.html

echo "*********************************************************************************************"
echo "Retrieving launch template name..."

LTNAME=$(aws ec2 describe-launch-templates --output=text --query='LaunchTemplates[*].LaunchTemplateName')

echo "*********************************************************************************************"
echo "Launch template name: $LTNAME"
echo "*********************************************************************************************"

# Delete the launch configuration template file

# https://docs.aws.amazon.com/cli/latest/reference/autoscaling/delete-launch-configuration.html
# https://docs.aws.amazon.com/cli/latest/reference/ec2/delete-launch-template.html

echo "Deleting $LTNAME launch template..."

aws ec2 delete-launch-template \
    --launch-template-name $LTNAME

echo "$LTNAME launch configuration was deleted!"




echo "*********************************************************************************************"
echo "Fetching DB subnet groups..."

# https://docs.aws.amazon.com/cli/latest/reference/rds/describe-db-subnet-groups.html

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

# https://docs.aws.amazon.com/cli/latest/reference/rds/describe-db-instances.html

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

# https://docs.aws.amazon.com/cli/latest/reference/rds/delete-db-instance.html

aws rds delete-db-instance \
    --db-instance-identifier $DB_INSTANCE_ID \
    --skip-final-snapshot

echo "*********************************************************************************************"
echo "Waiting for db-instances to be deleted..."

# https://docs.aws.amazon.com/cli/latest/reference/rds/wait/db-instance-deleted.html

aws rds wait db-instance-deleted \
    --db-instance-identifier $DB_INSTANCE_ID


echo "DB-Instances are deleted!!"


echo "*********************************************************************************************"
echo "Deleting DB subnet groups now..."

# https://docs.aws.amazon.com/cli/latest/reference/rds/delete-db-subnet-group.html


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
# https://docs.aws.amazon.com/cli/latest/reference/s3api/head-bucket.html
# https://docs.aws.amazon.com/cli/latest/reference/s3api/delete-bucket.html

delete_bucket() {
    
    local BUCKET_NAME=$1

    echo "*********************************************************************************************"
    echo "Checking if bucket $BUCKET_NAME STILL exists..."
    if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
        echo "Bucket $BUCKET_NAME exists. Deleting all objects..."
        echo "*********************************************************************************************"

        # # Delete all objects in the bucket
        # aws s3 rm "s3://$BUCKET_NAME" --recursive
        # if [ $? -eq 0 ]; then
        #     echo "All objects in $BUCKET_NAME deleted successfully."
        # else
        #     echo "Failed to delete objects in $BUCKET_NAME."
        #     return 1
        # fi
        
        MYKEYS=$(aws s3api list-objects --bucket $BUCKET_NAME --query 'Contents[*].Key')
        MYKEYS_ARRAY=($MYKEYS)
        for k in "${MYKEYS_ARRAY[@]}"
        do
        aws s3api delete-object --bucket $BUCKET_NAME --key $k --no-cli-pager
        aws s3api wait object-not-exists --bucket $BUCKET_NAME --key $k --no-cli-pager
        done
        echo "S3 Bucket Keys deleted"


        echo "*********************************************************************************************"

        # Delete the bucket
        echo "Deleting bucket $BUCKET_NAME..."
        aws s3api delete-bucket --bucket "$BUCKET_NAME"
        aws s3api wait bucket-not-exists --bucket "$BUCKET_NAME"
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

echo "*********************************************************************************************"
echo "Fecthing buckets...."

# https://docs.aws.amazon.com/cli/latest/reference/s3api/list-buckets.html

# Retrieve a list of all bucket names
BUCKETS=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

# Iterate over the list of bucket names and delete each one
for BUCKET_NAME in $BUCKETS; do
    echo "Found Bucket - $BUCKET_NAME"
    delete_bucket "$BUCKET_NAME"
done


echo "*********************************************************************************************"
# Verify buckets were deleted
echo "Listing remaining S3 buckets..."
aws s3api list-buckets --query "Buckets[].Name"


echo "*********************************************************************************************"
echo "Retrieving all SNS topics..."

# https://docs.aws.amazon.com/cli/latest/reference/sns/list-topics.html

# List all SNS topics
TOPICS=$(aws sns list-topics --query "Topics[].TopicArn" --output text)

echo "*********************************************************************************************"
echo "Found the following SNS topics:"
echo "*********************************************************************************************"
echo "$TOPICS"
echo "*********************************************************************************************"

echo "*********************************************************************************************"
echo "Deleting SNS topic now..."

# https://docs.aws.amazon.com/cli/latest/reference/sns/delete-topic.html

# Iterate over each topic and delete it
for TOPIC in $TOPICS; do
    echo "Deleting SNS topic: $TOPIC"
    aws sns delete-topic --topic-arn "$TOPIC"

    if [ $? -eq 0 ]; then
        echo "Successfully deleted SNS topic: $TOPIC"
    else
        echo "Failed to delete SNS topic: $TOPIC"
    fi
done

echo "*********************************************************************************************"


# https://docs.aws.amazon.com/cli/latest/reference/sqs/get-queue-url.html

echo "*********************************************************************************************"
echo "Querying SQS URL now..." 
QUEUE_URL=$(aws sqs get-queue-url \
    --queue-name ${24} \
    --query 'QueueUrl' --output text)
echo "Queue URL: $QUEUE_URL"

echo "*********************************************************************************************"
echo "Deleting SQS Queue: $QUEUE_URL"
aws sqs delete-queue --queue-url "$QUEUE_URL"
echo "SQS Queue deleted successfully."

echo "*********************************************************************************************"

# https://docs.aws.amazon.com/cli/latest/reference/sqs/delete-queue.html