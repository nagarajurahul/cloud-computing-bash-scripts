#!/bin/bash

# Dynamically detect your infrastructure and destroy it/terminate it

# Find auto scaling group
# https://docs.aws.amazon.com/cli/latest/reference/autoscaling/describe-auto-scaling-groups.html

echo "Finding autoscaling group name..."

ASGNAME=$(aws autoscaling describe-auto-scaling-groups --output=text --query='AutoScalingGroups[*].AutoScalingGroupName')

echo "*********************************************************************************************"
echo "Autoscaling group name: $ASGNAME"
echo "*********************************************************************************************"

# Update the auto scaling group to remove the min and max values to zero
# https://docs.aws.amazon.com/cli/latest/reference/autoscaling/update-auto-scaling-group.html

echo "Updating $ASGNAME autoscaling group to set minimum and desired capacity to 0..."

aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name $ASGNAME \
    --health-check-type ELB \
    --min-size 0 \
    --desired-capacity 0

echo "$ASGNAME autoscaling group was updated!"

# Retrieve instance IDs of EC2
# Describe EC2 instances
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html

EC2IDS=$(aws ec2 describe-instances \
    --output=text \
    --query='Reservations[*].Instances[*].InstanceId' --filter Name=instance-state-name,Values=pending,running )

echo "*********************************************************************************************"

echo "Waiting for instances to be terminated..." 
aws ec2 wait instance-terminated --instance-ids $EC2IDS
echo "Instances are terminated!"

echo "*********************************************************************************************"



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
echo "ELBARN: $ELBARN"
echo "*********************************************************************************************"

# First Query to get the ELB name using the --query and --filters
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-listeners.html

echo "Finding and storing the Listener ARN for default region"

LISTARN=$(aws elbv2 describe-listeners --load-balancer-arn $ELBARN --output=text --query='Listeners[*].ListenerArn' )

echo "*********************************************************************************************"
echo "LISTARN: $LISTARN"
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
aws elbv2 wait target-deregistered --target-group-arn $TGARN

echo "Target groups deleted!"
echo "*********************************************************************************************"


# Delete loadbalancer
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/delete-load-balancer.html

echo "Deleting load-balancers now..."

aws elbv2 delete-load-balancer --load-balancer-arn $ELBARN

echo "Waiting for load-balancer to be deleted..."
aws elbv2 wait load-balancers-deleted --load-balancer-arns $ELBARN
echo "Load balancers deleted!"

echo "*********************************************************************************************"
echo "Deleting $ASGNAME auto scaling group now"


aws autoscaling suspend-processes \
    --auto-scaling-group-name $ASGNAME

aws autoscaling delete-auto-scaling-group \
    --auto-scaling-group-name $ASGNAME
echo "$ASGNAME autoscaling group was deleted!"


# Find the launch configuration template
# https://docs.aws.amazon.com/cli/latest/reference/autoscaling/describe-launch-configurations.html

echo "Retrieving launch configuration name..."

LTNAME=$(aws ec2 describe-launch-templates --output=text --query='LaunchTemplates[*].LaunchTemplateName')

echo "*********************************************************************************************"
echo "Launch template name: $LTNAME"
echo "*********************************************************************************************"

# Delete the launch configuration template file

# https://docs.aws.amazon.com/cli/latest/reference/autoscaling/delete-launch-configuration.html

echo "Deleting $LTNAME launch template..."

aws ec2 delete-launch-template \
    --launch-template-name $LTNAME

echo "$LTNAME launch configuration was deleted!"
