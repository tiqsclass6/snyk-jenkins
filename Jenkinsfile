pipeline {
    agent any

    tools {
        nodejs 'NodeJS-18' // Ensure this is configured in Jenkins Global Tool Configuration
    }

    environment {
        AWS_REGION = 'us-east-1'
        SNYK_ORG = '67615456-3e82-4935-9968-23e1de24cd66'
        SNYK_PROJECT = 'snyk-jenkins-test'
    }

    stages {
        stage('Set AWS Credentials') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'snyk_cred',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    aws sts get-caller-identity
                    '''
                }
            }
        }

        stage('Checkout Code') {
            steps {
                script {
                    echo "Checking out source code from GitHub..."
                    checkout([$class: 'GitSCM',
                        branches: [[name: '*/main']],
                        userRemoteConfigs: [[url: 'https://github.com/tiqsclass6/snyk-jenkins']]
                    ])
                    echo "Code checkout successful."
                    sh 'ls -la'
                }
            }
        }

        stage('Install Snyk') {
            steps {
                sh '''
                npm install -g snyk snyk-to-sarif
                snyk --version
                '''
            }
        }

        stage('Update Dependencies') {
            steps {
                sh '''
                npm install -g npm-check-updates
                ncu -u
                npm install
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    echo "Checking for dependencies..."
                    if (fileExists('package.json')) {
                        echo "Node.js project detected. Installing dependencies..."
                        sh 'npm install'
                    } else {
                        echo "No package.json found. Skipping dependency installation."
                    }
                }
            }
        }

        stage('Snyk Scan & Publish to Snyk.io') {
            steps {
                withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_TOKEN')]) {
                    sh '''
                    snyk auth $SNYK_TOKEN
                    snyk test --all-projects --json > snyk.json || echo "Snyk scan encountered issues, but pipeline continues."
                    snyk-to-sarif < snyk.json > snyk.sarif
                    snyk monitor --org=$SNYK_ORG --project-name=$SNYK_PROJECT
                    '''
                }
            }
        }

        stage('Initialize Terraform') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Validate Terraform') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Plan Terraform') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'snyk_cred',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    terraform plan -out=tfplan
                    '''
                }
            }
        }

        stage('Apply Terraform') {
            steps {
                input message: "Approve Terraform Apply?", ok: "Deploy"
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'snyk_cred',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
            }
        }

        stage('Destroy Terraform') {
            steps {
                input message: "Do you want to destroy the Terraform resources?", ok: "Destroy"
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'snyk_cred',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    terraform destroy -auto-approve
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
        }
    }
}
