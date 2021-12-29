#!/bin/bash

KEY=/home/evgenii/.ssh/aws_ec2_2021-12-22
SITE_DIR=../website_static
IP=ec2-54-78-88-124.eu-west-1.compute.amazonaws.com
USER=ec2-user
EC2_DIR=/home/ec2-user/site

## Copy files via SSH/SCP
### Step 1. To copy file
# scp -i $KEY -r $SITE_DIR $USER@$IP:$EC2_DIR

### Step 2. To connect to instance
# ssh -i $KEY $USER@$IP

### Step 3. Copy files inside of the instance
# sudo cp site/* /var/www/html


### Copy files via S3_BUCKET
# aws s3 cp $S3_BUCKET /var/www/html --recursive

## Mount EBS attached volume
# device=/dev/xvdf
# mount_dir=share_volume
# lsblk
# file -s $device
# mkfs -t xfs $device
# file -s $device
# mkdir /home/$USER/$mount_dir
# mount $device /home/$USER/$mount_dir
