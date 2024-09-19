#!/bin/bash

# Dynamically detect your infrastrcuture and destroy it/terminate it

# First Query to get the ELB name using the --query and --filters
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-listeners.html

echo "Finding and storing the EL ARNS for default region"

ELBARNS=$(aws elbv2 describe-load-balancers --output=text --query='LoadBalancers[*].LoadBalancerArn')

echo "*********************************************************************************************"
echo $ELBARNS
echo "*********************************************************************************************"

# Delete loadbalancer
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/delete-load-balancer.html

aws elbv2 delete-load-balancer --load-balancer-arn $ELBARNS

# Can we delete multiple load-balancers using this command?

# for ELBARN in $ELBARNS;
# do
#     echo $ELBARN
#     aws elbv2 delete-load-balancer --load-balancer-arn $ELBARN
# done



echo "Finding and storing the instance IDs for default region"

# First Describe EC2 instances
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html

INSTANCES=$(aws ec2 describe-instances \
    --output=text \
    --query='Reservations[*].Instances[*].InstanceId' \
    --filter Name=instance-state-name,values=pending,running)

echo "*********************************************************************************************"
echo ${INSTANCES}
echo "*********************************************************************************************"

# Now Terminate all EC2 instances
# https://docs.aws.amazon.com/cli/latest/reference/ec2/terminate-instances.html

aws ec2 terminate-instances --instance-ids $INSTANCES