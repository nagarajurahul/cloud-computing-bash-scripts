import boto3

ec2 = boto3.client('ec2')

# Describe Launch Templates
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/describe_launch_templates.html

response = ec2.describe_launch_templates(
)