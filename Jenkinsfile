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

        stage('Prepare SSH Key & Inventory') {
            steps {
                script {

                    def MYSQL_IP = sh(script: "cd terraform && terraform output -raw mysql_private_ip", returnStdout: true).trim()
                    def BASTION_IP = sh(script: "cd terraform && terraform output -raw bastion_public_ip", returnStdout: true).trim()

                    // Copy terraform-generated key into Ansible folder
                    sh "cp terraform/my-key.pem ansible/my-key.pem"
                    sh "chmod 600 ansible/my-key.pem"

                    writeFile file: 'ansible/hosts.ini', text: """
[bastion]
bastion ansible_host=${BASTION_IP} ansible_user=ubuntu ansible_ssh_private_key_file=my-key.pem

[mysql]
${MYSQL_IP} ansible_user=ubuntu ansible_ssh_private_key_file=my-key.pem ansible_ssh_common_args='-o ProxyJump=ubuntu@${BASTION_IP}'
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
