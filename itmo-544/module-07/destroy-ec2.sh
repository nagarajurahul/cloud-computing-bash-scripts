#!/bin/bash

# Dynamically detect your infrastructure and destroy it/terminate it

echo "Finding and storing the instance IDs for default region"

# First Describe EC2 instances
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html

EC2IDS=$(aws ec2 describe-instances \
    --output=text \
    --query='Reservations[*].Instances[*].InstanceId' \
    --filter Name=instance-state-name,Values=pending,running)

echo "*********************************************************************************************"
echo ${EC2IDS}
echo "*********************************************************************************************"



# Now Terminate all EC2 instances
# https://docs.aws.amazon.com/cli/latest/reference/ec2/terminate-instances.html

echo "Terminating instances now..."

aws ec2 terminate-instances --instance-ids $EC2IDS

echo "Waiting for instances to be terminated..." 
aws ec2 wait instance-terminated --instance-ids $EC2IDS
echo "Instances are terminated!"

echo "*********************************************************************************************"