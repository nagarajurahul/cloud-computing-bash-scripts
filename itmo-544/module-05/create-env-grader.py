import boto3

ec2 = boto3.client('ec2')

# Describe Launch Templates
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/describe_launch_templates.html

response = ec2.describe_launch_templates(
)

autoscaling = boto3.client('autoscaling')

# Describe Auto Scaling Groups
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/autoscaling/client/describe_auto_scaling_groups.html
response = client.describe_auto_scaling_groups()

response = autoscaling.describe_load_balancers()