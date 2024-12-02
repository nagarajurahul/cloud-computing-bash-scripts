#!/bin/bash

aws ec2 create-launch-template-version \
    --launch-template-name ${15} \
    --version-description version1 \
    --launch-template-data file://config.json

aws ec2 modify-launch-template \
    --launch-template-name ${15} \
    --default-version 2

aws ec2 describe-launch-template-versions \
    --launch-template-name ${15}
