#!/bin/bash

KEY=/home/evgenii/.ssh/aws_ec2_2021-12-22
SITE_DIR=../website_static
IP=ec2-54-78-88-124.eu-west-1.compute.amazonaws.com
USER=ec2-user
EC2_DIR=/home/ec2-user/site

## Step 1. To copy file
# scp -i $KEY -r $SITE_DIR $USER@$IP:$EC2_DIR

## Step 2. To connect to instance
# ssh -i $KEY $USER@$IP

## Step 3. Copy files inside of the instance
# sudo cp site/* /var/www/html

S3_BUCKET=...
# aws s3 cp $S3_BUCKET /var/www/html --recursive