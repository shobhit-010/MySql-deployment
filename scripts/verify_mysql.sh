#!/bin/bash
set -e

echo "Testing MySQL connection THROUGH BASTION..."

WORKSPACE_DIR=$(pwd)
MYSQL_IP=$(cd terraform && terraform output -raw mysql_private_ip)

# Use SSH tunnel automatically via SSH config
ssh -J bastion mysql "mysql -u root -p1337 -e 'SELECT VERSION();'"

echo "✔ MySQL is reachable through bastion."
