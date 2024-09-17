#!/bin/bash

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/terminate-instances.html

aws ec2 terminate-instances --instance-ids ${1}

#Dynamically detect your infrastrcuture and destroy it/terminate it
# SUBNET2B=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${12}")
# First Query to get the ELB name using the --query and --filters
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-listeners.html
ELBARN=$(aws elbv2 describe-load-balancers --output=text --query='LoadBalancers[*].LoadBalancerARN' --region=${})

#Delete loadbalancer
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/delete-load-balancer.html
aws elbv2 delete-load-balancers --load-balancer-arn $ELBARN

# First Describe EC2 instances
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html
aws ec2 describe-instances \
    --output=text \
    --query='Reservations[*].Instances[*].InstanceId'

# Now Terminate all EC2 instances
# https://docs.aws.amazon.com/cli/latest/reference/ec2/terminate-instances.html