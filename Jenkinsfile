pipeline {
agent any


environment {
AWS_ACCESS_KEY_ID = credentials('aws-access-key')
AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
}


stages {


stage('Clone Repo') {
steps {
git url: 'https://github.com/shobhit-010/MySql-deployment.git'
}
}


stage('Create Backend') {
steps {
sh 'bash scripts/backend.sh'
}
}


stage('Terraform Apply') {
steps {
sh 'bash scripts/terraform_apply.sh'
}
}


stage('Generate SSH + Inventory') {
steps {
sh 'bash scripts/generate_ssh.sh'
sh 'bash scripts/generate_inventory.sh'
}
}


stage('Run Ansible') {
steps {
sh 'bash scripts/run_ansible.sh'
}
}


stage('Verify MySQL') {
steps {
sh 'bash scripts/verify_mysql.sh'
}
}
}
}