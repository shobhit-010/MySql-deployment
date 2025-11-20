pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
    }

    stages {

        stage('Clone Repo') {
            steps {
                git url: 'https://github.com/shobhit-010/MySql-deployment.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                sh '''
                cd terraform
                terraform init
                terraform apply -auto-approve
                '''
            }
        }

        stage('Prepare SSH Key & SSH Config & Inventory') {
            steps {
                script {

                    def MYSQL_IP = sh(
                        script: "cd terraform && terraform output -raw mysql_private_ip",
                        returnStdout: true
                    ).trim()

                    def BASTION_IP = sh(
                        script: "cd terraform && terraform output -raw bastion_public_ip",
                        returnStdout: true
                    ).trim()

                    // Copy Terraform key to ansible/
                    sh "cp terraform/my-key.pem ansible/my-key.pem"
                    sh "chmod 600 ansible/my-key.pem"

                    // Create SSH directory
                    sh "mkdir -p ~/.ssh"

                    // Create SSH config file dynamically
                    writeFile file: "${env.WORKSPACE}/.ssh/config", text: """
Host bastion
    HostName ${BASTION_IP}
    User ubuntu
    IdentityFile ${env.WORKSPACE}/ansible/my-key.pem

Host mysql-private
    HostName ${MYSQL_IP}
    User ubuntu
    IdentityFile ${env.WORKSPACE}/ansible/my-key.pem
    ProxyJump bastion
"""

                    sh "chmod 600 ~/.ssh/config"

                    // Generate hosts.ini with ProxyJump host
                    writeFile file: 'ansible/hosts.ini', text: """
[mysql]
mysql-private ansible_user=ubuntu
"""
                }
            }
        }

        stage('Run Ansible') {
            steps {
                sh '''
                cd ansible
                ansible-playbook -i hosts.ini mysql_install.yml
                '''
            }
        }
    }
}
