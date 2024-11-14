#!/bin/bash

# Use this script to first create instance

# aws ec2 run-instances \
#     --image-id ${1} \
#     --instance-type ${2} \
#     --key-name ${3} \
#     --security-group-ids ${4} \
#     --count 1 \
#     --tag-specifications 'ResourceType=instance,Tags=[{Key=course,Value=itmo-544}, {Key=name,Value=module-07}]' \
#     --placement "AvailabilityZone=${7}"


# Now SSH using the ssh -i <key> ubuntu@<IPv4>
# Create key-pair
# Put public key as a deploy key to the GitHub repo in the Settings->Deploy Keys


aws ec2 create-image \
    --instance-id i-0ce973a5a2201b833 \
    --name "My EC2 Server" \
    --description "An AMI for my server"


aws ec2 run-instances \
    --image-id ${1} \
    --instance-type ${2} \
    --key-name ${3} \
    --security-group-ids ${4} \
    --count ${5} \
    --user-data file://${6} \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=course,Value=itmo-544}, {Key=name,Value=module-07}]' \
    --placement "AvailabilityZone=${7}"



