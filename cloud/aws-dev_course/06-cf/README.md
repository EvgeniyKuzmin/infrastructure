# Cloud Formation

## What to do
1. Create one or more Cloud Formation templates (YAML or JSON based) which would set up a VPC similar to module 5, but simplified:![image info](./diagram.png)
    - the private subnets and the bastion are not required anymore
    - the public subnets should not use elastic IPs
    - use just ordinary public IPs for accessing EC2 instances in the public subnets
    - ensure that the security groups used by the EC2 instances from the public subnets allow HTTP access only from your IP address

2. Optionally, use the Cloud Formation nesting feature to minimize the amount of template configuration duplication.
3. Create a Cloud Formation template which creates one EC2 instance based on the AMI from module 4 in one of the custom VPC public subnets.
4. Optionally, make the template parameterized so that it's possible to specify the desired subnet during stack creation.
5. Manually or using a Cloud Formation template, create one EC2 instance in one of the DB subnets and one EC2 instance in one of the public subnets.
6. Ensure that:
    - the public EC2 instance is accessible from outside VPC and has access to the Internet/DB subnet instance
    - the DB EC2 instance is not accessible from outside VPC and has not access to the Internet
