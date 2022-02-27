KEY=$(HOME)/.ssh/aws_ec2_`date +%Y-%m-%d`


all: ssh_key_generate cloud_init cloud_apply

ssh_key_generate:
	ssh-keygen -f $(KEY) -t rsa -N '' -q
	chmod 400 $(KEY)

cloud_init:
	terraform init

cloud_plan:
	terraform plan -var "ssh_key=${KEY}"

cloud_apply:
	terraform apply -auto-approve -var "ssh_key=${KEY}"

clean: cloud_destroy tmp_files_delete

cloud_destroy:
	terraform destroy -auto-approve -var "ssh_key=${KEY}"

tmp_files_delete:
	rm -f $(KEY)
	rm -f "${KEY}.pub"
