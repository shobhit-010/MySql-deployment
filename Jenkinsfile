pipeline {
    agent any

    environment {
        // FIXED: Correct way to bind AWS credentials
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
    }

    stages {

        stage('Clone Repo') {
            steps {
                git url: 'https://github.com/shobhit-010/MySql-deployment.git'
            }
        }
        
       stage('Create S3 Bucket & DynamoDB Table (If Not Exists)') {
    steps {
        sh '''
        
        BUCKET="shobhit-mysql-tf-state"
        TABLE="shobhit-mysql-tf-lock"
        REGION="ap-south-1"

        echo "Checking S3 bucket..."
        if aws s3api head-bucket --bucket $BUCKET 2>/dev/null; then
            echo "✔ Bucket already exists: $BUCKET"
        else
            echo "➕ Creating bucket: $BUCKET"
            aws s3api create-bucket \
                --bucket $BUCKET \
                --region $REGION \
                --create-bucket-configuration LocationConstraint=$REGION
        fi

        echo "Checking DynamoDB table..."
        if aws dynamodb describe-table --table-name $TABLE --region $REGION 2>/dev/null; then
            echo "✔ DynamoDB table already exists: $TABLE"
        else
            echo "➕ Creating DynamoDB table: $TABLE"
            aws dynamodb create-table \
                --table-name $TABLE \
                --attribute-definitions AttributeName=LockID,AttributeType=S \
                --key-schema AttributeName=LockID,KeyType=HASH \
                --billing-mode PAY_PER_REQUEST \
                --region $REGION
        fi

        echo "⏳ Waiting for DynamoDB table to become ACTIVE..."
        aws dynamodb wait table-exists --table-name $TABLE --region $REGION

        echo "✔ Backend resources ready!"
        '''
    }
}


    stage('Terraform Init') {
    steps {
        sh '''
        cd terraform
        terraform init -reconfigure -input=false
        '''
    }
}

        
    stage('Terraform Apply (Only If No Infra Exists)') {
    steps {
        script {
            def output = sh(
                script: "cd terraform && terraform state list || true",
                returnStdout: true
            ).trim()

            if (output == "") {
                echo "✔ No infra found — creating infra now..."
                sh "cd terraform && terraform apply -auto-approve"
            } else {
                echo "✔ Infra already exists — skipping Terraform apply."
            }
        }
    }
}

        stage('Prepare SSH Key, Config & Inventory') {
            steps {
                script {

                    def MYSQL_IP = sh(script: "cd terraform && terraform output -raw mysql_private_ip", returnStdout: true).trim()
                    def BASTION_IP = sh(script: "cd terraform && terraform output -raw bastion_public_ip", returnStdout: true).trim()

                    // Copy Terraform-generated private key
                    sh "cp terraform/my-key.pem my-key.pem"
                    sh "chmod 600 my-key.pem"

                    // SSH config
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

                    // Inventory file
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
