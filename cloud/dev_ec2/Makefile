KEY_PATH = "/home/evgenii/.ssh"
KEY_PREFIX = "aws_ec2_"
PASSPHRASE = ""


all: generate_ssh_keys cloud_init cloud_deploy

generate_ssh_keys:
	ssh-keygen -f "${KEY_PATH}/${KEY_PREFIX}`date +%Y-%m-%d`" -t rsa -N $(PASSPHRASE) -q
	chmod 400 "${KEY_PATH}/${KEY_PREFIX}`date +%Y-%m-%d`"

cloud_init:
	terraform init

cloud_deploy:
	terraform validate
	terraform apply -var "ssh_key=${KEY_PATH}/${KEY_PREFIX}`date +%Y-%m-%d`" -auto-approve


clean: cloud_destroy delete_ssh_keys

cloud_destroy:
	terraform destroy -var "ssh_key=${KEY_PATH}/${KEY_PREFIX}`date +%Y-%m-%d`" -auto-approve

delete_ssh_keys:
	rm -f "${KEY_PATH}/${KEY_PREFIX}`date +%Y-%m-%d`"
	rm -f "${KEY_PATH}/${KEY_PREFIX}`date +%Y-%m-%d`.pub"
