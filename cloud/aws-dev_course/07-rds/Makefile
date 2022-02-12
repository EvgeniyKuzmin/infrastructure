KEY=$(HOME)/.ssh/aws_ec2_`date +%Y-%m-%d`
MYIP=$(shell curl https://ifconfig.me)
PWD=$(shell date +%s | sha256sum | base64 | head -c 32)
SECRET=$(shell python -c "import secrets as s; print(s.token_hex())")


all: ssh_key_generate cloud_init cloud_apply

echo:
	@echo --==$(KEY)==--
	@echo --==$(MYIP)==--
	@echo --==$(PWD)==--
	@echo --==$(SECRET)==--

ssh_key_generate:
	ssh-keygen -f $(KEY) -t rsa -N '' -q
	chmod 400 $(KEY)

cloud_init:
	terraform init

cloud_plan:
	terraform plan \
		-var "ssh_key=${KEY}" \
		-var "ingr_ssh_ip=${MYIP}/32" \
		-var "db_password=${PWD}" \
		-var "flask_secret=${SECRET}"

cloud_apply:
	terraform apply -auto-approve \
		-var "ssh_key=${KEY}" \
		-var "ingr_ssh_ip=${MYIP}/32" \
		-var "db_password=${PWD}" \
		-var "flask_secret=${SECRET}"


clean: cloud_destroy tmp_files_delete

cloud_destroy:
	terraform destroy -auto-approve \
		-var "ssh_key=${KEY}" \
		-var "ingr_ssh_ip=${MYIP}/32" \
		-var "db_password=${PWD}" \
		-var "flask_secret=${SECRET}"

tmp_files_delete:
	rm -f $(KEY)
	rm -f "${KEY}.pub"
	rm -rf .tmp/
