#!/bin/bash
set -e

echo "Checking MySQL status..."

ssh -F ~/.ssh/config mysql "sudo systemctl is-active mysql"

echo "Testing MySQL root login..."
ssh -F ~/.ssh/config mysql "echo 'SHOW DATABASES;' | sudo mysql -u root -p1337"
