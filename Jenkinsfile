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

        stage('Prepare SSH Key, Config & Inventory') {
            steps {
                script {

                    def MYSQL_IP = sh(script: "cd terraform && terraform output -raw mysql_private_ip", returnStdout: true).trim()
                    def BASTION_IP = sh(script: "cd terraform && terraform output -raw bastion_public_ip", returnStdout: true).trim()

                    // Copy TF generated key into workspace
                    sh "cp terraform/my-key.pem my-key.pem"
                    sh "chmod 600 my-key.pem"

                    // Create .ssh/config inside workspace
                    sh "mkdir -p ${env.WORKSPACE}/.ssh"

                    writeFile file: "${env.WORKSPACE}/.ssh/config", text: """
Host bastion
    HostName ${BASTION_IP}
    User ubuntu
    IdentityFile ${env.WORKSPACE}/my-key.pem
    StrictHostKeyChecking no

Host mysql
    HostName ${MYSQL_IP}
    User ubuntu
    IdentityFile ${env.WORKSPACE}/my-key.pem
    ProxyJump bastion
    StrictHostKeyChecking no
"""

                    sh "chmod 600 ${env.WORKSPACE}/.ssh/config"

                    writeFile file: 'ansible/hosts.ini', text: """
[mysql]
mysql

[mysql:vars]
ansible_user=ubuntu
ansible_ssh_common_args='-F ${env.WORKSPACE}/.ssh/config'
ansible_ssh_private_key_file=${env.WORKSPACE}/my-key.pem
"""
                }
            }
        }

        stage('Test SSH Connectivity') {
            steps {
                sh """
                echo "Testing SSH to private MySQL host..."
                ssh -F ${env.WORKSPACE}/.ssh/config mysql echo "SSH OK"
                """
            }
        }

        stage('Run Ansible') {
            steps {
                sh """
                cd ansible
                ANSIBLE_HOST_KEY_CHECKING=False \
                ansible-playbook -i hosts.ini mysql_install.yml
                """
            }
        }
        
        stage('Verify MySQL Running') {
    steps {
        sh """
        echo "Checking MySQL service status..."
        ssh -F ${env.WORKSPACE}/.ssh/config mysql 'sudo systemctl is-active mysql'
        """
    }
}

stage('Test MySQL Root Login') {
    steps {
        sh """
        echo "Testing MySQL Login..."
        ssh -F ${env.WORKSPACE}/.ssh/config mysql "\
        echo 'SHOW DATABASES;' | sudo mysql -u root -p1337"
        """
    }
}

    }
}
