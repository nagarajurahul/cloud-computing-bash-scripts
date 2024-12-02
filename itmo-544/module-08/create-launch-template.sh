#!/bin/bash

echo "*********************************************************************************************"
echo "Creating launch-template now..."

aws ec2 create-launch-template-version \
    --launch-template-name ${15} \
    --version-description version1 \
    --launch-template-data file://config.json

echo "*********************************************************************************************"
echo "Modifying launch template version to default now..."


aws ec2 modify-launch-template \
    --launch-template-name ${15} \
    --default-version 4

echo "*********************************************************************************************"
echo "Pulling launch-template now..."

aws ec2 describe-launch-template-versions \
    --launch-template-name ${15}

echo "*********************************************************************************************"