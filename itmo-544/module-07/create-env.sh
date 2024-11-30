#!/bin/bash

# Use this script to first create instance

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/run-instances.html

# Creating instances and running them

echo "*********************************************************************************************"
echo "Creating EC2 instances now with old AMI..."

aws ec2 run-instances \
    --image-id ${1} \
    --instance-type ${2} \
    --key-name ${3} \
    --security-group-ids ${4} \
    --count 1 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=name,Value=module-07}]' \
    --placement "AvailabilityZone=${7}"


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


# Fetch the public IP address of the first instance
FIRST_INSTANCE_PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $(echo $EC2IDS | awk '{print $1}') \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "*********************************************************************************************"
echo "The public IP address of the first instance is: $FIRST_INSTANCE_PUBLIC_IP"
echo "*********************************************************************************************"



# Now SSH using the ssh -i <key> ubuntu@<IPv4>
# Create key-pair - ssh-keygen -t ed25519 -C "your_email@example.com"
# Put public key as a deploy key to the GitHub repo in the Settings->Deploy Keys
# Run to touch once ssh git@github.com
# Then create image




# echo "*********************************************************************************************"
# echo "Creating EC2 instances now with our custom AMI..."

# aws ec2 run-instances \
#     --image-id ${1} \
#     --instance-type ${2} \
#     --key-name ${3} \
#     --security-group-ids ${4} \
#     --count ${5} \
#     --user-data file://${6} \
#     --tag-specifications 'ResourceType=instance,Tags=[{Key=course,Value=itmo-544}, {Key=name,Value=module-07}]' \
#     --placement "AvailabilityZone=${7}"



