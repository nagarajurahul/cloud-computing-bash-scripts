import boto3
from tqdm import tqdm
import requests
import time

ec2 = boto3.client('ec2')
elbv2 = boto3.client('elbv2')
autoscaling = boto3.client('autoscaling')


grandtotal = 0
totalPoints = 5


response = ec2.describe_regions()

# Function to print out current points progress
def currentPoints():
  print("Current Points: " + str(grandtotal) + " out of " + str(totalPoints) + ".")



# Describe Launch Templates
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/describe_launch_templates.html
print('*' * 79)
print("Checking Launch Templates...")
response = ec2.describe_launch_templates()
print(response)
# print(response['LaunchTemplates'])

print("The number of launch templates are: " + str(len(response['LaunchTemplates'])))

if len(response['LaunchTemplates']) == 0:
    print("Correct answer you have:" + str(len(response['LaunchTemplates'])) + " Launch Templates...")
    grandtotal += 1
    currentPoints()
else:
    print("You have  an incorrect number of Launch Templates: " + str(len(response['LaunchTemplates'])) + ", perhaps check if you have deleted the Launch Templates...")
    currentPoints()



# Describe Auto Scaling Groups
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/autoscaling/client/describe_auto_scaling_groups.html
print('*' * 79)
print("Checking Auto Scaling Groups...")
response = autoscaling.describe_auto_scaling_groups()
print(response)

print("The number of Auto Scaling Groups are: " + str(len(response['AutoScalingGroups'])))

if len(response['AutoScalingGroups']) == 0:
    print("Correct answer you have:" + str(len(response['AutoScalingGroups'])) + " Auto Scaling Groups...")
    grandtotal += 1
    currentPoints()
else:
    print("You have  an incorrect number of Auto Scaling Groups: " + str(len(response['AutoScalingGroups'])) + ", perhaps check if you have deleted your Auto Scaling Groups...")
    currentPoints()



# Describe Load Balancer
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/autoscaling/client/describe_load_balancers.html
print('*' * 79)
print("Checking Load Balancers...")
response = elbv2.describe_load_balancers()
print(response)

print("The number of Load Balancers are: " + str(len(response['LoadBalancers'])))

if len(response['LoadBalancers']) == 0:
    print("Correct answer you have:" + str(len(response['LoadBalancers'])) + " Load Balancers...")
    grandtotal += 1
    currentPoints()
else:
    print("You have  an incorrect number of Load Balancers: " + str(len(response['LoadBalancers'])) + ", perhaps check if you have deleted your Load Balancers...")
    currentPoints()



# Describe EC2 instances
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/describe_instances.html
print('*' * 79)
print("Checking EC2 instances now...")
response = ec2.describe_instances(
    Filters=[
        {
            'Name': 'tag:Name',
            'Values': [
                'module-06',
            ],
        },
        {
            'Name': 'instance-state-name',
            'Values': [
               'running'
            ]
        }
    ],
)
print(response)
reservations=response['Reservations']
ec2_instances = []

for reservation in reservations:
    for instance in reservation['Instances']:
        ec2_instances.append(instance)

print(ec2_instances)


print("The number of Instances are: " + str(len(ec2_instances)))

if len(ec2_instances) == 0:
    print("Correct answer you have:" + str(len(ec2_instances)) + " Instances...")
    grandtotal += 1
    currentPoints()
else:
    print("You have  an incorrect number of Instances: " + str(len(ec2_instances)) + ", perhaps check if you have correctly terminated your Instances...")
    currentPoints()


print('*' * 79)
print("Checking RDS instances now...")

rds = boto3.client('rds')

try:
    response = rds.describe_db_instances()
    db_instances = response['DBInstances']
    
    if not db_instances:
        print("Correct answer: There are zero RDS instances.")
        grandtotal += 1
        currentPoints()
    else:
        print(f"Incorrect answer: You have {len(db_instances)} RDS instance(s).")
        currentPoints()
except Exception as e:  
    print(f"An error occurred: {e}")


# Commenting from here

# # Describe Target Groups
# # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/elbv2/client/describe_target_groups.html#ElasticLoadBalancingv2.Client.describe_target_groups
# print('*' * 79)
# print("Checking Target Groups now...")

# response = elbv2.describe_target_groups()
# print(response)

# print("The number of Target Groups are: " + str(len(response['TargetGroups'])))

# if len(response['TargetGroups']) == 0:
#     print("Correct answer you have:" + str(len(response['TargetGroups'])) + " Target Groups...")
#     grandtotal += 1
#     currentPoints()
# else:
#     print("You have  an incorrect number of Target Groups: " + str(len(response['TargetGroups'])) + ", perhaps check if you have correctly deleted your Target Groups...")
#     currentPoints()

# print('*' * 79)
# print("\r")

# Commenting till here

