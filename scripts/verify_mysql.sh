#!/bin/bash
set -e

WORKSPACE_DIR=$(pwd)

echo "Checking MySQL service..."
ssh -F $WORKSPACE_DIR/.ssh/config mysql "sudo systemctl is-active mysql"

echo "Testing MySQL login..."
ssh -F $WORKSPACE_DIR/.ssh/config mysql \
"echo 'SHOW DATABASES;' | sudo mysql -u root -p1337"
