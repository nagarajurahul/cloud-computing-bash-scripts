#!/bin/bash

# Finding subnets
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-subnets.html

echo "Finding and storing the subnet IDs for availability zones defined in arguments"

SUBNET2A=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${10}")
SUBNET2B=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${11}")
SUBNET2C=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=${12}")

echo "*********************************************************************************************"
echo $SUBNET2A
echo $SUBNET2B
echo $SUBNET2C
echo "*********************************************************************************************"


# https://docs.aws.amazon.com/cli/latest/reference/elbv2/create-load-balancer.html

echo "*********************************************************************************************"
echo "Creating load-balancer now..."

# Need to change sg here

aws elbv2 create-load-balancer \
    --name ${8} \
    --subnets $SUBNET2A $SUBNET2B $SUBNET2C \
    --tags Key='name',Value=${13} \
    --security-groups ${4} \
    --output table

#    --security-groups ${20} \
#     --scheme internal \  -> to make it internal LB

echo "*********************************************************************************************"
echo "Finding and storing the ELB ARN for default region"

# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-load-balancers.html

ELBARN=$(aws elbv2 describe-load-balancers --output=text --query='LoadBalancers[*].LoadBalancerArn')

echo "*********************************************************************************************"
echo  "Printing ELBARN: $ELBARN"
echo "*********************************************************************************************"


# https://docs.aws.amazon.com/cli/latest/reference/elbv2/wait/
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/wait/load-balancer-available.html

echo "*********************************************************************************************"
echo "Waiting for ELB to become available..."
aws elbv2 wait load-balancer-available --load-balancer-arns $ELBARN
echo "ELB is available..."


echo "*********************************************************************************************"
echo "Creating EC2 instances now..."

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
    --output table

# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html

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
echo "Target group ARN: $TGARN"
echo "*********************************************************************************************"


echo "*********************************************************************************************"
echo "Creating elbv2 listeners now..."

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