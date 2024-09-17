#!/bin/bash

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/run-instances.html

# Creating instances and running them

aws ec2 run-instances --image-id ${1} --instance-type ${2} \
    --key-name ${3} --security-group-ids ${4} \
    --count ${5} --user-data file://${6} \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=course,Value=itmo-544}]' \
    --placement "AvailabilityZone=${7}" \

# Finding subnets

echo "Finding and storing the subnet IDs for defined in arguments.txt Availability Zone 1 and 2..."

SUBNET2A=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${10}")
SUBNET2B=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${11}")
SUBNET2B=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${12}")

echo $SUBNET2A
echo $SUBNET2B
echo $SUBNET2C

aws elbv2 create-load-balancer \
    --name ${8} \
    --subnets $SUBNET2A $SUBNET2B $SUBNET2C \
    --tags Key='name',Value=${13} 
