#!/bin/bash
set -e

echo "Running Ansible playbook..."
cd ansible

ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook -i hosts.ini mysql_install.yml
