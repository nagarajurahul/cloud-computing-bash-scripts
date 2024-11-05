import boto3

ec2 = boto3.client('ec2')

# Describe Launch Templates
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/describe_launch_templates.html
print("Checking Launch Templates")
response = ec2.describe_launch_templates()
print(response)

autoscaling = boto3.client('autoscaling')

# Describe Auto Scaling Groups
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/autoscaling/client/describe_auto_scaling_groups.html
print("Checking Auto Scaling Groups")
response = autoscaling.describe_auto_scaling_groups()
print(response)

# Describe Load Balancer
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/autoscaling/client/describe_load_balancers.html
print("Checking Load Balancers")
response = autoscaling.describe_load_balancers()
print(response)