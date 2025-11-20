#!/bin/bash
set -e

echo "Generating SSH config..."

# Get IPs from terraform
MYSQL_IP=$(cd terraform && terraform output -raw mysql_private_ip)
BASTION_IP=$(cd terraform && terraform output -raw bastion_public_ip)

# Copy key
cp terraform/my-key.pem my-key.pem
chmod 600 my-key.pem

# Create SSH config directory
mkdir -p ~/.ssh

# Create SSH config file
cat <<EOF > ~/.ssh/config
Host bastion
    HostName $BASTION_IP
    User ubuntu
    IdentityFile $(pwd)/my-key.pem
    StrictHostKeyChecking no

Host mysql
    HostName $MYSQL_IP
    User ubuntu
    IdentityFile $(pwd)/my-key.pem
    ProxyJump bastion
    StrictHostKeyChecking no
EOF

chmod 600 ~/.ssh/config

echo "SSH config created successfully!"
