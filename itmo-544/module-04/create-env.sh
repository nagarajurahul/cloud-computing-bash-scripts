#!/bin/bash

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/run-instances.html

# Creating instances and running them

aws ec2 run-instances \
    --image-id ${1} \
    --instance-type ${2} \
    --key-name ${3} \
    --security-group-ids ${4} \
    --count ${5} \
    --user-data file://${6} \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=course,Value=itmo-544}, {Key=name,Value=cli-instance-launch1}]' \
    --placement "AvailabilityZone=${7}" \

EC2IDS=$(aws ec2 describe-instances \
    --output=text \
    --query='Reservations[*].Instances[*].InstanceId' --filter Name=instance-state-name,Values=pending,running)
echo "Instance IDs"
echo $EC2IDS

#https://docs.aws.amazon.com/cli/latest/reference/ec2/wait/
#https://docs.aws.amazon.com/cli/latest/reference/ec2/wait/instance-running.html

echo "Waiting for instances..."
aws ec2 wait instance-running --instance-ids $EC2IDS
echo "Instances are up!"

# Finding subnets

echo "Finding and storing the subnet IDs for defined in arguments.txt Availability Zone 1 and 2..."

SUBNET2A=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${10}")
SUBNET2B=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${11}")
SUBNET2C=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${12}")

echo $SUBNET2A
echo $SUBNET2B
echo $SUBNET2C

aws elbv2 create-load-balancer \
    --name ${8} \
    --subnets $SUBNET2A $SUBNET2B $SUBNET2C \
    --tags Key=course,Value=${13}

#     --scheme internal \  -> to make it internal LB

# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-listeners.html

echo "Finding and storing the EL ARNS for default region"

ELBARNS=$(aws elbv2 describe-load-balancers --output=text --query='LoadBalancers[*].LoadBalancerArn')

echo "*********************************************************************************************"
echo $ELBARNS
echo "*********************************************************************************************"

# add elv2 wait running reference
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/wait/
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/wait/load-balancer-available.html
echo "Waiting for ELB to become available..."
aws elbv2 wait load-balancer-available --load-balancer-arns $ELBARN
echo "ELB is available..."