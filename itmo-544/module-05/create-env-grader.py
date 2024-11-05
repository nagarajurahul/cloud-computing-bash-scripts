import boto3

ec2 = boto3.client('ec2')

grandtotal = 0
totalPoints = 5

response = ec2.describe_regions()

# Function to print out current points progress
def currentPoints():
  print("Current Points: " + str(grandtotal) + " out of " + str(totalPoints) + ".")

print(response)

print("The number of regions are: " + str(len(response['Regions'])))

if len(response['Regions']) > 5:
    print("Correct answer you have:" + str(len(response['Regions'])) + " regions...")
    grandtotal += 1
    currentPoints()
else:
    print("You have  an incorrect number of regions: " + str(len(response['Regions'])) + "perhaps check your code where you declared number of regions...")
    currentPoints()



# Describe Launch Templates
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/describe_launch_templates.html
print("Checking Launch Templates")
response = ec2.describe_launch_templates()
print(response)
print(response['LaunchTemplates'])

autoscaling = boto3.client('autoscaling')

# Describe Auto Scaling Groups
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/autoscaling/client/describe_auto_scaling_groups.html
print("Checking Auto Scaling Groups")
response = autoscaling.describe_auto_scaling_groups()
print(response)
asgname=(response['AutoScalingGroups'][0]['AutoScalingGroupName'])
print(asgname)

# Describe Load Balancer
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/autoscaling/client/describe_load_balancers.html
print("Checking Load Balancers")
response = autoscaling.describe_load_balancers(
    AutoScalingGroupName=asgname,
)
print(response)


# Describe EC2 instances
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/describe_instances.html
print("Checking EC2 instances now")
response = ec2.describe_instances(
    Filters=[
        {
            'Name': 'tag:name',
            'Values': [
                'module-05',
            ],
        },
    ],
)
print(response)
print(response['Reservations'][0]['Instances'])