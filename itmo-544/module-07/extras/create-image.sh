# Storing the instance id here...

# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html

EC2IDS=$(aws ec2 describe-instances \
    --output=text \
    --query='Reservations[*].Instances[*].InstanceId' --filter Name=instance-state-name,Values=pending,running)

echo "Finding and storing the Instance IDs"
echo "*********************************************************************************************"
echo $EC2IDS
echo "*********************************************************************************************"


# https://docs.aws.amazon.com/cli/latest/reference/ec2/create-image.html

echo "Creating our custom AMI now..."

aws ec2 create-image \
    --instance-id $EC2IDS \
    --name "My EC2 Server" \
    --description "An AMI for my server" \
    --tag-specifications "ResourceType=image,Tags=[{Key=name,Value=module-07}]"

# Replace the ami in the arguments with this new AMI


# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html   


AMI=$(aws ec2 describe-images \
    --filters "Name=tag:name,Values=module-07" \
    --query 'Images[*].[ImageId]' \
    --output text)

echo "*********************************************************************************************"
echo "Finding and storing our custom AMI"
echo "*********************************************************************************************"
echo $AMI
echo "*********************************************************************************************"

