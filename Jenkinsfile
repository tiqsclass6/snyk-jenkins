pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1' // AWS region
    }

    triggers {
        cron('H 2 * * 1-5') // Runs Snyk monitoring every weekday at 2 AM
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/tiqsclass6/synk-jenkins'
                sh 'ls -la'
            }
        }

        stage('Build') {
            steps {
                script {
                    if (fileExists('package.json')) {
                        sh 'npm install'
                    } else if (fileExists('requirements.txt')) {
                        sh 'pip install -r requirements.txt'
                    } else if (fileExists('pom.xml')) {
                        sh 'mvn clean install'
                    } else {
                        echo "No recognized dependency file found. Skipping installation."
                    }
                }
            }
        }

        stage('Scan') {
            steps {
                script {
                    snykSecurity(
                        organisation: 'TIQS',
                        projectName: 'tiqsclass6/jfrog-cli',
                        snykInstallation: 'Snyk-API',
                        snykTokenId: 'snyk_token',
                        targetFile: 'package.json'
                    )
                }
            }
        }

        stage('Terraform Setup & Validation') {
            steps {
                sh '''
                terraform init
                terraform validate
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: "Approve Terraform Apply?", ok: "Deploy"
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
            }
        }

        stage('Snyk Continuous Monitoring (Post-Deploy)') {
            steps {
                script {
                    snykSecurity(
                        snykInstallation: 'Snyk-API',
                        snykTokenId: 'snyk_token',
                        monitorProjectOnBuild: true,
                        failOnIssues: false
                    )
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed. Monitoring continues...'
        }
    }
}