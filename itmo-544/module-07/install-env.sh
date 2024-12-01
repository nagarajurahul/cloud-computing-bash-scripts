#!/bin/bash

# module-07 sample code to install Nginx webserver

sudo apt update
sudo apt install -y nginx

# Get your source code (index.html and app.js) on to each EC2 instance
# So we can serve the provided index.html not the default "welcome to Nginx"

cd /home/ubuntu

# Change URL to your private repo
sudo -u ubuntu git clone git@github.com:illinoistech-itm/rnagaraju.git

# Adjust repo name and path accordingly :-)
sudo cp rnagaraju/itmo-544/module-07/index.html /var/www/html/
sudo cp rnagaraju/itmo-544/module-07/app.js /var/www/html/

