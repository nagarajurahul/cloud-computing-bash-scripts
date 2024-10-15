#!/bin/bash

# Dynamically detect your infrastructure and destroy it/terminate it

echo "Deleting auto scaling groups now"

aws autoscaling delete-auto-scaling-group \
    --auto-scaling-group-name ${14} \
    --force-delete


# Finding taget group ARN
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-target-groups.html

echo "Finding and storing the target group ARN for default region"

TGARN=$(aws elbv2 describe-target-groups --output=text --query='TargetGroups[*].TargetGroupArn' --names ${9})

echo "*********************************************************************************************"
echo "TGARN: $TGARN"
echo "*********************************************************************************************"



echo "Finding and storing the ELB ARNS for default region"

ELBARN=$(aws elbv2 describe-load-balancers --output=text --query='LoadBalancers[*].LoadBalancerArn')

echo "*********************************************************************************************"
echo $ELBARN
echo "*********************************************************************************************"

# First Query to get the ELB name using the --query and --filters
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-listeners.html

echo "Finding and storing the Listener ARN for default region"

LISTARN=$(aws elbv2 describe-listeners --load-balancer-arn $ELBARN --output=text --query='Listeners[*].ListenerArn' )

echo "*********************************************************************************************"
echo $LISTARN
echo "*********************************************************************************************"


echo "Deleting listener now..."
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/delete-listener.html

aws elbv2 delete-listener --listener-arn $LISTARN

echo "Listeners deleted!"
echo "*********************************************************************************************"


# Deleting target group, and wait for it to deregister

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/delete-target-group.html
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/wait/target-deregistered.html
# First Query to get the ELB name using the --query and --filters
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-listeners.html


echo "Deleting Target Group now..."

aws elbv2 delete-target-group --target-group-arn $TGARN
# Error here because it's already deleted!
# aws elbv2 wait target-deregistered --target-group-arn $TGARN

echo "Target groups deleted!"
echo "*********************************************************************************************"


# Delete loadbalancer
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/delete-load-balancer.html

echo "Deleting load-balancers now..."

aws elbv2 delete-load-balancer --load-balancer-arn $ELBARN

echo "Waiting for load-balancer to be deleted..."
aws elbv2 wait load-balancers-deleted --load-balancer-arns $ELBARN
echo "Load balancers deleted!"


# Can we delete multiple load-balancers using this command?

# for ELBARN in $ELBARNS;
# do
#     echo $ELBARN
#     aws elbv2 delete-load-balancer --load-balancer-arn $ELBARN
# done
