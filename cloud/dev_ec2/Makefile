KEY_PATH = "/home/evgenii/.ssh/"
KEY_PREFIX = "aws_"
KEY_NAME = "${KEY_PREFIX}ec2-2021-11-29"
PASSPHRASE = ""

generate_ssh_keys:
	ssh-keygen -f "${KEY_PATH}/${KEY_NAME}" -t rsa -N $(PASSPHRASE) -q
	chmod 400 "${KEY_PATH}/${KEY_NAME}"

delete_ssh_keys:
	rm -f "${KEY_PATH}/${KEY_NAME}"
	rm -f "${KEY_PATH}/${KEY_NAME}.pub"