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

# print(response)

# print("The number of regions are: " + str(len(response['Regions'])))

# if len(response['Regions']) > 5:
#     print("Correct answer you have:" + str(len(response['Regions'])) + " regions...")
#     grandtotal += 1
#     currentPoints()
# else:
#     print("You have  an incorrect number of regions: " + str(len(response['Regions'])) + ", perhaps check your code where you declared number of regions...")
#     currentPoints()



# Describe Launch Templates
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/describe_launch_templates.html
print('*' * 79)
print("Checking Launch Templates...")
response = ec2.describe_launch_templates()
print(response)
# print(response['LaunchTemplates'])

print("The number of launch templates are: " + str(len(response['LaunchTemplates'])))

if len(response['LaunchTemplates']) >= 1:
    print("Correct answer you have:" + str(len(response['LaunchTemplates'])) + " Launch Templates...")
    grandtotal += 1
    currentPoints()
else:
    print("You have  an incorrect number of Launch Templates: " + str(len(response['LaunchTemplates'])) + ", perhaps check if you have created the Launch Templates...")
    currentPoints()



# Describe Auto Scaling Groups
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/autoscaling/client/describe_auto_scaling_groups.html
print('*' * 79)
print("Checking Auto Scaling Groups...")
response = autoscaling.describe_auto_scaling_groups()
print(response)

print("The number of Auto Scaling Groups are: " + str(len(response['AutoScalingGroups'])))

if len(response['AutoScalingGroups']) >= 1:

    asgname=(response['AutoScalingGroups'][0]['AutoScalingGroupName'])
    print(asgname)
    print(type(asgname))

    print("Correct answer you have:" + str(len(response['AutoScalingGroups'])) + " Auto Scaling Groups...")
    grandtotal += 1
    currentPoints()
else:
    print("You have  an incorrect number of Auto Scaling Groups: " + str(len(response['AutoScalingGroups'])) + ", perhaps check if you have created Auto Scaling Groups...")
    currentPoints()



# Describe Load Balancer
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/autoscaling/client/describe_load_balancers.html
print('*' * 79)
print("Checking Load Balancers...")
response = elbv2.describe_load_balancers()
responseELB=response
print(response)

print("The number of Load Balancers are: " + str(len(response['LoadBalancers'])))

if len(response['LoadBalancers']) >= 1:
    print("Correct answer you have:" + str(len(response['LoadBalancers'])) + " Load Balancers...")
    grandtotal += 1
    currentPoints()
else:
    print("You have  an incorrect number of Load Balancers: " + str(len(response['LoadBalancers'])) + ", perhaps check if you have created Load Balancers...")
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
                'module-05',
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

# print(response['Reservations'][0]['Instances'])
reservations=response['Reservations']
ec2_instances = []

for reservation in reservations:
    for instance in reservation['Instances']:
        ec2_instances.append(instance)

print(ec2_instances)


print("The number of Instances are: " + str(len(ec2_instances)))

if len(ec2_instances) >= 3:
    print("Correct answer you have:" + str(len(ec2_instances)) + " Instances...")
    grandtotal += 1
    currentPoints()
else:
    print("You have  an incorrect number of Instances: " + str(len(ec2_instances)) + ", perhaps check if you have correctly configured your Instances...")
    currentPoints()



##############################################################################
# Test 5: Check PublicDNS and HTTP return status to check if webserver was 
# installed and working
##############################################################################
print('*' * 79)
print("Testing for the correct HTTP status (200) response from the webserver via the ELB URL...")
# https://pypi.org/project/tqdm/
for i in tqdm(range(30)):
  time.sleep(1)


checkHttpReturnStatusMismatch = False
print("http://" + responseELB['LoadBalancers'][0]['DNSName'])
try:
  res=requests.get("http://" + responseELB['LoadBalancers'][0]['DNSName'])
  if res.status_code == 200:
    print("Successful request of the index.html file from " + str(responseELB['LoadBalancers'][0]['DNSName']))
  else:
    checkHttpReturnStatusMismatch = True
    print("Incorrect http response code: " + str(res.status_code) + "from " + str(responseELB['LoadBalancers'][0]['DNSName']))
except requests.exceptions.ConnectionError as errc:
  print ("Error Connecting:",errc)
  checkHttpReturnStatusMismatch = True
  print("No response code returned - not able to connect: " + str(res.status_code) + "from " + str(responseELB['LoadBalancers'][0]['DNSName'])) 
  sys.exit("Perhaps wait 1-2 minutes to let the install-env.sh server to finish installing the Nginx server and get the service ready to except external connections? Rerun this test script.")

if checkHttpReturnStatusMismatch == False:
   print("Correct HTTP status code of 200, received for the Elastic Load Balancer URL...")
   grandtotal += 1
   currentPoints()
else:
   print("Incorrect status code received. Perhaps go back and take a look at the --user-file value and the content of the install-env.sh script. Or check your security group to make sure the correct ports are open.")

print('*' * 79)
print("\r")