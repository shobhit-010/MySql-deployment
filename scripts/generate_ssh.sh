#!/bin/bash
set -e

WORKSPACE_DIR=$(pwd)

MYSQL_IP=$(cd terraform && terraform output -raw mysql_private_ip)
BASTION_IP=$(cd terraform && terraform output -raw bastion_public_ip)

# copy key
cp terraform/my-key.pem my-key.pem
chmod 600 my-key.pem

mkdir -p $WORKSPACE_DIR/.ssh

cat <<EOF > $WORKSPACE_DIR/.ssh/config
Host bastion
    HostName $BASTION_IP
    User ubuntu
    IdentityFile $WORKSPACE_DIR/my-key.pem
    StrictHostKeyChecking no

Host mysql
    HostName $MYSQL_IP
    User ubuntu
    IdentityFile $WORKSPACE_DIR/my-key.pem
    ProxyJump bastion
    StrictHostKeyChecking no
EOF

chmod 600 $WORKSPACE_DIR/.ssh/config

echo "✔ SSH config created."
