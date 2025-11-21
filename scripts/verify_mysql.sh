#!/bin/bash
set -e

echo "Testing MySQL connection THROUGH BASTION → PRIVATE"

# First SSH to bastion, then from bastion SSH to private EC2, then run MySQL
ssh bastion <<'EOF'
  echo "Connected to Bastion"

  ssh mysql <<'EOF2'
    echo "Connected to Private MySQL Instance"
    mysql -u root -p1337 -e "SHOW DATABASES;"
EOF2

EOF

echo "✔ SUCCESS: MySQL reachable through Bastion → Private"
