#!/bin/bash

# Dynamically detect your infrastrcuture and destroy it/terminate it
# SUBNET2B=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${12}")

# First Query to get the ELB name using the --query and --filters
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-listeners.html

echo "Finding and storing the EL ARNS for default region"

ELBARNS=$(aws elbv2 describe-load-balancers --output=jspn --query='LoadBalancers[*].LoadBalancerARN')

# Delete loadbalancer
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/delete-load-balancer.html

# Can we delete multiple load-balancers using this command?


for ELBARN in $(ELBARNS);
do
    aws elbv2 delete-load-balancer --load-balancer-arn $ELBARN
done



echo "Finding and storing the instance IDs for default region"

# First Describe EC2 instances
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html

INSTANCES=$(aws ec2 describe-instances \
    --output=text \
    --query='Reservations[*].Instances[*].InstanceId')

echo ${INSTANCES}

# Now Terminate all EC2 instances
# https://docs.aws.amazon.com/cli/latest/reference/ec2/terminate-instances.html

aws ec2 terminate-instances --instance-ids $INSTANCES