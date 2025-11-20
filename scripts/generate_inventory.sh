#!/bin/bash
set -e

echo "Generating Ansible inventory..."

WORKSPACE_DIR=$(pwd)

cat <<EOF > ansible/hosts.ini
[mysql]
mysql

[mysql:vars]
ansible_user=ubuntu
ansible_ssh_common_args="-F $WORKSPACE_DIR/.ssh/config"
ansible_ssh_private_key_file=$WORKSPACE_DIR/my-key.pem
EOF

echo "✔ Inventory created!"
