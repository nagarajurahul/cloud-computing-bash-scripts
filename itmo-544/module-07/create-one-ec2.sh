#!/bin/bash

# Create launch template
# https://docs.aws.amazon.com/cli/latest/reference/ec2/create-launch-template.html

echo "*********************************************************************************************"
echo "Creating launch-template now..."

aws ec2 create-launch-template \
    --launch-template-name ${15} \
    --version-description version1 \
    --launch-template-data file://config.json

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