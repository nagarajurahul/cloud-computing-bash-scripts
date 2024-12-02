#!/bin/bash

echo "*********************************************************************************************"
echo "Creating launch-template now..."

aws ec2 create-launch-template-version \
    --launch-template-name ${15} \
    --version-description version1 \
    --launch-template-data file://config.json

echo "*********************************************************************************************"
echo "Fetching the latest launch template version number..."

# Fetch the latest version number using AWS CLI and jq to parse the JSON output
LATEST_VERSION=$(aws ec2 describe-launch-template-versions \
    --launch-template-name ${15} \
    --query 'LaunchTemplateVersions[-1].VersionNumber' \
    --output text)

echo "Latest version is: $LATEST_VERSION"

echo "*********************************************************************************************"
echo "Modifying launch template version to default now..."

# Set the latest version as the default
aws ec2 modify-launch-template \
    --launch-template-name ${15} \
    --default-version $LATEST_VERSION

echo "*********************************************************************************************"
echo "Pulling launch-template now..."

aws ec2 describe-launch-template-versions \
    --launch-template-name ${15}

echo "*********************************************************************************************"