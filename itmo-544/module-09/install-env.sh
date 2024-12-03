#!/bin/bash

# module-08 sample code

# Add comment and link describing NodeJs install
# Installing Nodejs 22

# Node JS Package List URL Link: https://github.com/nodesource/distributions?tab=readme-ov-file#using-debian-as-root-nodejs-22
sudo apt-get install -y curl nginx

# Get the URL of the package
curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh

sudo -E bash nodesource_setup.sh

# Install Node JS
sudo apt-get install -y nodejs

# Debugging purposes

echo "After node install..."

# Print out output
node -v

##############################################################################
# Use NPM (node package manager to install AWS JavaScript SDK)
##############################################################################
# Run NPM to install the NPM Node packages needed for the code
# You will start this NodeJS script by executing the command: node app.js
# from the directory where app.js is located. The program `pm2` can be
# used to auto start NodeJS applications (as they don't have a normal
# systemd service handler).
# <https://pm2.keymetrics.io/docs/usage/quick-start/>. This will require
# the install of PM2 via npm as well.
cd /home/ubuntu
# sudo -u ubuntu npm install @aws-sdk/client-dynamodb @aws-sdk/client-sqs @aws-sdk/client-s3 @aws-sdk/client-sns express multer multer-s3 uuid ip


# Debugging purposes

echo "After cd..."

# Install necessary libraries for our application
sudo -u ubuntu npm install @aws-sdk/client-sns @aws-sdk/client-sqs @aws-sdk/client-rds @aws-sdk/client-s3 @aws-sdk/client-secrets-manager express multer multer-s3 uuid ip mysql2 

sudo npm install pm2 -g

# Get your source code (index.html and app.js) on to each EC2 instance
# So we can serve the provided index.html not the default "welcome to Nginx"

# Change URL to your private repo
sudo -u ubuntu git clone git@github.com:illinoistech-itm/rnagaraju.git


# Debugging purposes

echo "After git clone..."

sudo cp rnagaraju/itmo-544/module-09/default /etc/nginx/sites-available/default
sudo systemctl daemon-reload
sudo systemctl restart nginx

# cd command to the directory containing app.js
# WARNING!!! This is the path in my GitHub Repo - yours could be different
# Please adjust accordingly - There be Dragons!
cd rnagaraju/itmo-544/module-09/

# Debugging purposes

echo "After cd to project app directory..."

# Used to auto start the app.js nodejs application at deploy time
sudo pm2 start app.js



# ##############################################################################
# # Install and Configure CloudWatch Agent
# ##############################################################################

# # Install the CloudWatch Agent
# sudo apt-get install -y amazon-cloudwatch-agent

# # Create CloudWatch Agent configuration
# cat <<EOF | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/config.json
# {
#   "metrics": {
#     "append_dimensions": {
#       "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
#       "InstanceId": "${aws:InstanceId}"
#     },
#     "aggregation_dimensions": [["AutoScalingGroupName"]],
#     "metrics_collected": {
#       "nginx": {
#         "collection_interval": 60,
#         "metrics_collection": {
#           "connections_active": true,
#           "connections_accepted": true,
#           "connections_handled": true,
#           "requests": true
#         }
#       },
#       "statsd": {
#         "service_address": ":8125"
#       }
#     }
#   },
#   "logs": {
#     "logs_collected": {
#       "files": {
#         "collect_list": [
#           {
#             "file_path": "/var/log/messages",
#             "log_group_name": "system-logs",
#             "log_stream_name": "{instance_id}"
#           },
#           {
#             "file_path": "/var/log/nginx/access.log",
#             "log_group_name": "nginx-access-logs",
#             "log_stream_name": "{instance_id}"
#           },
#           {
#             "file_path": "/var/log/nginx/error.log",
#             "log_group_name": "nginx-error-logs",
#             "log_stream_name": "{instance_id}"
#           },
#           {
#             "file_path": "/root/.pm2/logs/*.log",
#             "log_group_name": "pm2-logs",
#             "log_stream_name": "{instance_id}/pm2-out-stream"
#           },
#           {
#             "file_path": "/root/.pm2/logs/*-error.log",
#             "log_group_name": "pm2-logs",
#             "log_stream_name": "{instance_id}/pm2-error-stream"
#           }
#         ]
#       }
#     }
#   }
# }

# EOF

# # Start the CloudWatch Agent
# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
#     -a fetch-config \
#     -m ec2 \
#     -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json \
#     -s

# # Debugging purposes
# echo "CloudWatch Agent installation and configuration completed."

# # Finish
# echo "Setup completed."


#         #  {
#         #     "file_path": "/path/to/your/javascript/app.log",
#         #     "log_group_name": "javascript-app-logs",
#         #     "log_stream_name": "{instance_id}"
#         #   }