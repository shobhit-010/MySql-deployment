#!/bin/bash
set -e

echo "Testing MySQL connection through bastion..."

mysql -h "$(cd terraform && terraform output -raw mysql_private_ip)" -u root -p1337 -e "SELECT VERSION();"

echo "✔ MySQL is installed and reachable."
