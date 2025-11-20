#!/bin/bash

ssh -F ~/.ssh/config mysql "sudo systemctl is-active mysql"

ssh -F ~/.ssh/config mysql "echo 'SHOW DATABASES;' | sudo mysql -u root -p1337"
