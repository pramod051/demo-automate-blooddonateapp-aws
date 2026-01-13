#!/bin/bash

set -e

echo "🚀 Starting BBMS Deployment..."

# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=${AWS_DEFAULT_REGION:-ap-south-1}

echo "📋 Account ID: $ACCOUNT_ID"
echo "📍 Region: $REGION"

# Deploy infrastructure
echo "🏗️  Deploying infrastructure..."
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan

# Get ECR repository URLs
BACKEND_REPO_URL=$(terraform output -raw ecr_backend_repository_url)
FRONTEND_REPO_URL=$(terraform output -raw ecr_frontend_repository_url)
ALB_DNS=$(terraform output -raw alb_dns_name)

echo "📦 Backend ECR: $BACKEND_REPO_URL"
echo "📦 Frontend ECR: $FRONTEND_REPO_URL"
echo "🌐 Load Balancer: $ALB_DNS"

cd ..

# Login to ECR
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Build and push backend
echo "🔨 Building backend..."
cd backend
docker build -t bbms-backend .
docker tag bbms-backend:latest $BACKEND_REPO_URL:latest
docker push $BACKEND_REPO_URL:latest

cd ../frontend

# Build and push frontend
echo "🔨 Building frontend..."
docker build -t bbms-frontend .
docker tag bbms-frontend:latest $FRONTEND_REPO_URL:latest
docker push $FRONTEND_REPO_URL:latest

cd ..

# Update ECS services
echo "🚀 Updating ECS services..."
aws ecs update-service --cluster bbms-cluster --service bbms-backend --force-new-deployment
aws ecs update-service --cluster bbms-cluster --service bbms-frontend --force-new-deployment

echo "⏳ Waiting for services to stabilize..."
aws ecs wait services-stable --cluster bbms-cluster --services bbms-backend bbms-frontend

echo "✅ Deployment complete!"
echo "🌐 Application URL: http://$ALB_DNS"
