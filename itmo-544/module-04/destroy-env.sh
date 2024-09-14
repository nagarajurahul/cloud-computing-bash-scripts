#!/bin/bash

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/run-instances.html

aws ec2 terminate-instances --instance-ids ${1}