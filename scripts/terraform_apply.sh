#!/bin/bash

cd terraform
terraform init -reconfigure -input=false

STATE=$(terraform state list || true)

if [ -z "$STATE" ]; then
    echo "No infra detected — applying Terraform..."
    terraform apply -auto-approve
else
    echo "Infra exists — skipping apply."
fi
