#!/bin/bash

# Connect to my EC2 instance with SSH
USERNAME='ubuntu'
PRIVATE_KEY='~/.ssh/ec2_t3-micro_2021-08-17.pem'
DNS='ec2-52-48-122-233.eu-west-1.compute.amazonaws.com'

ssh -i $PRIVATE_KEY $USERNAME@$DNS