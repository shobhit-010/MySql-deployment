#!/bin/bash
set -e

echo "Generating Ansible inventory..."

cat <<EOF > ansible/hosts.ini
[mysql]
mysql

[mysql:vars]
ansible_user=ubuntu
ansible_ssh_common_args='-F ~/.ssh/config'
ansible_ssh_private_key_file=$(pwd)/my-key.pem
EOF

echo "Inventory created!"
