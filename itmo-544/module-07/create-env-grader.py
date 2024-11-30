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


# Commenting from here


# # Describe Launch Templates
# # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/describe_launch_templates.html
# print('*' * 79)
# print("Checking Launch Templates...")
# response = ec2.describe_launch_templates()
# print(response)
# # print(response['LaunchTemplates'])

# print("The number of launch templates are: " + str(len(response['LaunchTemplates'])))

# if len(response['LaunchTemplates']) >= 1:
#     print("Correct answer you have:" + str(len(response['LaunchTemplates'])) + " Launch Templates...")
#     grandtotal += 1
#     currentPoints()
# else:
#     print("You have  an incorrect number of Launch Templates: " + str(len(response['LaunchTemplates'])) + ", perhaps check if you have created the Launch Templates...")
#     currentPoints()



# # Describe Auto Scaling Groups
# # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/autoscaling/client/describe_auto_scaling_groups.html
# print('*' * 79)
# print("Checking Auto Scaling Groups...")
# response = autoscaling.describe_auto_scaling_groups()
# print(response)

# print("The number of Auto Scaling Groups are: " + str(len(response['AutoScalingGroups'])))

# if len(response['AutoScalingGroups']) >= 1:

#     asgname=(response['AutoScalingGroups'][0]['AutoScalingGroupName'])
#     print(asgname)
#     print(type(asgname))

#     print("Correct answer you have:" + str(len(response['AutoScalingGroups'])) + " Auto Scaling Groups...")
#     grandtotal += 1
#     currentPoints()
# else:
#     print("You have  an incorrect number of Auto Scaling Groups: " + str(len(response['AutoScalingGroups'])) + ", perhaps check if you have created Auto Scaling Groups...")
#     currentPoints()



# # Describe Load Balancer
# # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/autoscaling/client/describe_load_balancers.html
# print('*' * 79)
# print("Checking Load Balancers...")
# response = elbv2.describe_load_balancers()
# responseELB=response
# print(response)

# print("The number of Load Balancers are: " + str(len(response['LoadBalancers'])))

# if len(response['LoadBalancers']) >= 1:
#     print("Correct answer you have:" + str(len(response['LoadBalancers'])) + " Load Balancers...")
#     grandtotal += 1
#     currentPoints()
# else:
#     print("You have  an incorrect number of Load Balancers: " + str(len(response['LoadBalancers'])) + ", perhaps check if you have created Load Balancers...")
#     currentPoints()


# Commenting till here


print('*' * 79)
print("Checking RDS instances...")

rds = boto3.client('rds')

# Check for RDS instances
try:
    response = rds.describe_db_instances()
    db_instances = response['DBInstances']
    
    if db_instances:
        print(f"Correct answer: You have {len(db_instances)} RDS instance(s).")
        grandtotal += 1
        currentPoints()
    else:
        print("Incorrect answer: No RDS instances found.")
        currentPoints()
except Exception as e:
    print(f"An error occurred: {e}")


print('*' * 79)
print("Checking module-06 tag in RDS instances...")



try:
    if db_instances:
        found_tag = False
        for db_instance in db_instances:
            # Get the ARN of the DB instance
            db_arn = db_instance['DBInstanceArn']
            
            # Fetch tags for the DB instance
            tags_response = rds.list_tags_for_resource(ResourceName=db_arn)
            tags = tags_response['TagList']
            
            print("Tags")
            print(tags)

            # Check if 'module-07' tag exists
            for tag in tags:
                if tag['Key'] == 'Name' and tag['Value'] =='module-07':
                    print(f"DB Instance '{db_instance['DBInstanceIdentifier']}' has the 'module-06' tag.")
                    found_tag = True
                    break
        
        if found_tag:
            print("Correct answer: At least one database instance has the 'module-06' tag.")
            grandtotal += 1
            currentPoints()
        else:
            print("Incorrect answer: No database instances have the 'module-06' tag.")
            currentPoints()
    else:
        print("There are no instances of RDS to check tags.")
        currentPoints()
except Exception as e:
    print(f"An error occurred: {e}")


print('*' * 79)
print("Checking Secrets...")

secrets_manager = boto3.client('secretsmanager')

try:
    response = secrets_manager.list_secrets()
    secrets = response['SecretList']

    if secrets:
        print(f"Correct answer: You have {len(secrets)} secret(s) in Secrets Manager.")
        grandtotal += 1
        currentPoints()
    else:
        print("Incorrect answer: No secrets found in Secrets Manager.")
        currentPoints()
except Exception as e:
    print(f"An error occurred: {e}")




s3 = boto3.client('s3')

response = s3.list_buckets()


print(response)

print("The number of buckets are: " + str(len(response['Buckets'])))

if len(response['Buckets']) >= 2:
    print("Correct answer you have:" + str(len(response['Buckets'])) + " Buckets...")
    grandtotal += 1
    currentPoints()
else:
    print("You have  an incorrect number of Buckets: " + str(len(response['Buckets'])) + ", perhaps check your code if you have created the S3 buckets...")
    currentPoints()

# Commenting from here

# # Describe EC2 instances
# # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/describe_instances.html
# print('*' * 79)
# print("Checking EC2 instances now...")
# response = ec2.describe_instances(
#     Filters=[
#         {
#             'Name': 'tag:Name',
#             'Values': [
#                 'module-06',
#             ],
#         },
#         {
#             'Name': 'instance-state-name',
#             'Values': [
#                'running'
#             ]
#         }
#     ],
# )
# print(response)

# # print(response['Reservations'][0]['Instances'])
# reservations=response['Reservations']
# ec2_instances = []

# for reservation in reservations:
#     for instance in reservation['Instances']:
#         ec2_instances.append(instance)

# print(ec2_instances)


# print("The number of Instances are: " + str(len(ec2_instances)))

# if len(ec2_instances) >= 3:
#     print("Correct answer you have:" + str(len(ec2_instances)) + " Instances...")
#     grandtotal += 1
#     currentPoints()
# else:
#     print("You have  an incorrect number of Instances: " + str(len(ec2_instances)) + ", perhaps check if you have correctly configured your Instances...")
#     currentPoints()

# Commenting till here

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