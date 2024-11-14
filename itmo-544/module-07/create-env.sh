#!/bin/bash

aws ec2 run-instances \
    --image-id ${1} \
    --instance-type ${2} \
    --key-name ${3} \
    --security-group-ids ${4} \
    --count 1 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=course,Value=itmo-544}, {Key=name,Value=module-07}]' \
    --placement "AvailabilityZone=${7}"