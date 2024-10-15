#!/bin/bash

# Finding subnets

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

echo "*********************************************************************************************"
echo "Creating load-balancer now..."

aws elbv2 create-load-balancer \
    --name ${8} \
    --subnets $SUBNET2A $SUBNET2B $SUBNET2C \
    --tags Key=course,Value=${13} \
    --security-groups ${15}\
    --output table

#     --scheme internal \  -> to make it internal LB

# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-listeners.html

echo "Finding and storing the ELB ARN for default region"

ELBARN=$(aws elbv2 describe-load-balancers --output=text --query='LoadBalancers[*].LoadBalancerArn')

echo "*********************************************************************************************"
echo $ELBARN
echo "*********************************************************************************************"


# https://docs.aws.amazon.com/cli/latest/reference/elbv2/wait/
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/wait/load-balancer-available.html

echo "*********************************************************************************************"
echo "Waiting for ELB to become available..."
aws elbv2 wait load-balancer-available --load-balancer-arns $ELBARN
echo "ELB is available..."

echo "*********************************************************************************************"
echo "Creating AutoScaling Group now..."

# Create auto-scalng groups
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

EC2IDS=$(aws ec2 describe-instances \
    --output=text \
    --query='Reservations[*].Instances[*].InstanceId' --filter Name=instance-state-name,Values=pending,running)

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

echo "Finding and storing target group ARN"

TGARN=$(aws elbv2 describe-target-groups --output=text --query='TargetGroups[*].TargetGroupArn' --names ${9})

echo "*********************************************************************************************"
echo $TGARN
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

echo "Listeners are up!"

# Register targets and wait for them to be in service
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/register-targets.html
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/wait/target-in-service.html

# Create a bash Array so we can loop through it and take care of the Id

declare -a IDSARRAY
IDSARRAY=( $EC2IDS )

echo "*********************************************************************************************"

for ID in ${IDSARRAY[@]};
do
  
  echo "Registering Target with Id: $ID"
  aws elbv2 register-targets \
    --target-group-arn $TGARN --targets Id=$ID,Port=80
  aws elbv2 wait target-in-service  --target-group-arn $TGARN --targets Id=$ID,Port=80
  echo "Target $ID is in service!!!"
  
done

echo "*********************************************************************************************"

DNSNAME=$(aws elbv2 describe-load-balancers --output=text --query='LoadBalancers[*].DNSName')
DNSNAME="http://$DNSNAME"

echo "Kindly curl using the below link"
echo $DNSNAME

echo "*********************************************************************************************"
echo "Making curl request now..."
echo "Response is as belows "

curl $DNSNAME

echo "*********************************************************************************************"