KEY=$(HOME)/.ssh/aws_ec2_`date +%Y-%m-%d`
# KEY=$(HOME)/.ssh/aws_ec2_2021-12-22
MYIP=$(shell curl https://ifconfig.me)


all: ssh_key_generate cloud_init cloud_apply

echo:
	echo --==$(MYIP)==--

ssh_key_generate:
	ssh-keygen -f $(KEY) -t rsa -N '' -q
	chmod 400 $(KEY)

cloud_init:
	terraform init

cloud_plan:
	terraform plan -var "ssh_key=${KEY}" -var "ingr_ssh_ip=${MYIP}/32"

cloud_apply:
	terraform apply -var "ssh_key=${KEY}" -var "ingr_ssh_ip=${MYIP}/32" -auto-approve


clean: cloud_destroy tmp_files_delete

cloud_destroy:
	terraform destroy -var "ssh_key=${KEY}" -var "ingr_ssh_ip=${MYIP}/32" -auto-approve

tmp_files_delete:
	rm -f $(KEY)
	rm -f "${KEY}.pub"
	rm -rf .tmp/
