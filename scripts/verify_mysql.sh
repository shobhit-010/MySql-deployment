#!/bin/bash
set -e

echo "Testing MySQL connection THROUGH BASTION → PRIVATE"

WORKSPACE_DIR=$(pwd)

ssh -F $WORKSPACE_DIR/.ssh/config bastion <<EOF
  echo "Connected to Bastion"

  ssh -F $WORKSPACE_DIR/.ssh/config mysql <<EOF2
    echo "Connected to Private MySQL Instance"
    mysql -u root -p1337 -e "SHOW DATABASES;"
EOF2

EOF

echo "✔ SUCCESS: MySQL reachable through Bastion → Private"
