#!/bin/bash

# Dynamically detect your infrastructure and destroy it/terminate it


echo "Finding and storing the instance IDs for default region"

# First Describe EC2 instances
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html

EC2IDS=$(aws ec2 describe-instances \
    --output=text \
    --query='Reservations[*].Instances[*].InstanceId' \
    --filter Name=instance-state-name,Values=pending,running)

echo "*********************************************************************************************"
echo ${EC2IDS}
echo "*********************************************************************************************"

# Finding taget group ARN
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-target-groups.html

echo "Finding and storing the target group ARN for default region"

TGARN=$(aws elbv2 describe-target-groups --output=text --query='TargetGroups[*].TargetGroupArn' --names ${9})

echo "*********************************************************************************************"
echo "TGARN: $TGARN"
echo "*********************************************************************************************"


# Deregistering attached EC2 IDS before terminating instances

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/deregister-targets.html
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/wait/target-deregistered.html

declare -a IDSARRAY
IDSARRAY=( $EC2IDS )

echo "*********************************************************************************************"
echo "Deregistering Targets now..."

for ID in ${IDSARRAY[@]};
do
  echo "Deregistering Target with Id: $ID"
  aws elbv2 deregister-targets \
    --target-group-arn $TGARN --targets Id=$ID
  aws elbv2 wait target-deregistered  --target-group-arn $TGARN --targets Id=$ID
  echo "Target $ID deregistred"
done

echo "*********************************************************************************************"

# Deleting target group, and wait for it to deregister

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/delete-target-group.html
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/wait/target-deregistered.html
# First Query to get the ELB name using the --query and --filters
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-listeners.html

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

aws elbv2 delete-listener $LISTARN

echo "Listeners deleted!"
echo "*********************************************************************************************"

echo "Deleting Target Group now..."

aws elbv2 delete-target-group --target-group-arn $TGARN
# Error here because it's already deleted!
# aws elbv2 wait target-deregistered --target-group-arn $TGARN

echo "Target groups deleted!"
echo "*********************************************************************************************"


# Now Terminate all EC2 instances
# https://docs.aws.amazon.com/cli/latest/reference/ec2/terminate-instances.html

echo "Terminating instances now..."

aws ec2 terminate-instances --instance-ids $EC2IDS

echo "Waiting for instances to be terminated..." 
aws ec2 wait instance-terminated --instance-ids $EC2IDS
echo "Instances are terminated!"

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
