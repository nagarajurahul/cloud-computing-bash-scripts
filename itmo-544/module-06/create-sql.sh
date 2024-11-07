#!/bin/bash

# Create DB Instance for MySQL using AWS RDS

# References

# https://docs.aws.amazon.com/cli/latest/reference/rds/#cli-aws-rds
# https://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html

# First 3 options are mandatory
# db-instance-identifier - should be unique
# db.t3.micro, no-multi-az and 20 for storage - free-tier
# Please make sure, these are the same values for free-tier
# By default, MySQL listens on port 3306
# Feel free to add tags if required

aws rds create-db-instance \
    --db-instance-identifier ${19} \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --allocated-storage 20 \
    --port 3306 \
    --tags Key=class,Value=class-code \
    --no-multi-az \
    --availability-zone us-east-2a \
    --vpc-security-group-ids sg-0d0101b597cd9ec5e

    # --backup-retention-period 7 \
    # --master-username admin \
    # --master-user-password admin \