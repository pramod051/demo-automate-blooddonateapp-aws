pipeline {
    agent any
    
    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        ECR_BACKEND_REPO = 'bbms-backend'
        ECR_FRONTEND_REPO = 'bbms-frontend'
        ECS_CLUSTER = 'bbms-cluster'
        ECS_BACKEND_SERVICE = 'bbms-backend'
        ECS_FRONTEND_SERVICE = 'bbms-frontend'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Backend') {
            steps {
                dir('backend') {
                    script {
                        def backendImage = docker.build("${ECR_BACKEND_REPO}:${BUILD_NUMBER}")
                        
                        // Get ECR login token  
 
                        sh '''
                           aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
                        '''
                        
                        // Tag and push image
                        sh '''
                            ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                            docker tag ${ECR_BACKEND_REPO}:${BUILD_NUMBER} $ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/${ECR_BACKEND_REPO}:${BUILD_NUMBER}
                            docker tag ${ECR_BACKEND_REPO}:${BUILD_NUMBER} $ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/${ECR_BACKEND_REPO}:latest
                            docker push $ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/${ECR_BACKEND_REPO}:${BUILD_NUMBER}
                            docker push $ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/${ECR_BACKEND_REPO}:latest
                        '''
                    }
                }
            }
        }
        
        stage('Build Frontend') {
            steps {
                dir('frontend') {
                    script {
                        def frontendImage = docker.build("${ECR_FRONTEND_REPO}:${BUILD_NUMBER}")
                        
                        // Tag and push image
                        sh '''
                            ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                            docker tag ${ECR_FRONTEND_REPO}:${BUILD_NUMBER} $ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/${ECR_FRONTEND_REPO}:${BUILD_NUMBER}
                            docker tag ${ECR_FRONTEND_REPO}:${BUILD_NUMBER} $ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/${ECR_FRONTEND_REPO}:latest
                            docker push $ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/${ECR_FRONTEND_REPO}:${BUILD_NUMBER}
                            docker push $ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/${ECR_FRONTEND_REPO}:latest
                        '''
                    }
                }
            }
        }
        
        stage('Deploy Infrastructure') {
            when {
		anyof {
                    branch 'main'
		    branch 'master'
		}
            }
            steps {
                dir('terraform') {
                    sh '''
                        terraform init
                        terraform plan -out=tfplan
                        terraform apply -auto-approve tfplan
                    '''
                }
            }
        }
        
        stage('Deploy to ECS') {
            when {
		anyof {
                    branch 'main'
		    branch 'master'
		}
            }
            steps {
                sh '''
                    # Update backend service
                    aws ecs update-service --cluster $ECS_CLUSTER --service $ECS_BACKEND_SERVICE --force-new-deployment
                    
                    # Update frontend service
                    aws ecs update-service --cluster $ECS_CLUSTER --service $ECS_FRONTEND_SERVICE --force-new-deployment
                    
                    # Wait for deployment to complete
                    aws ecs wait services-stable --cluster $ECS_CLUSTER --services $ECS_BACKEND_SERVICE $ECS_FRONTEND_SERVICE
                '''
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
