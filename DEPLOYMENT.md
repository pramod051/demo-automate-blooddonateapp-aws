# AWS Deployment Guide

## Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** installed (v1.0+)
3. **Docker** installed and running
4. **Jenkins** (for CI/CD automation)

## Required AWS Permissions

Your AWS user/role needs the following permissions:
- ECR: Full access
- ECS: Full access
- DynamoDB: Full access
- VPC: Full access
- IAM: Create/manage roles and policies
- CloudWatch: Create log groups
- Application Load Balancer: Full access

## Quick Deployment

1. **Clone and navigate to project:**
   ```bash
   cd /home/pramod/project/blood-bank-management-system
   ```

2. **Configure AWS credentials:**
   ```bash
   aws configure
   ```

3. **Update environment variables:**
   - Edit `backend/.env.production`
   - Edit `terraform/terraform.tfvars`

4. **Deploy everything:**
   ```bash
   ./deploy.sh
   ```

## Manual Deployment Steps

### 1. Infrastructure Deployment

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2. Build and Push Images

```bash
# Get ECR login
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-south-1.amazonaws.com

# Build backend
cd backend
docker build -t bbms-backend .
docker tag bbms-backend:latest <account-id>.dkr.ecr.ap-south-1.amazonaws.com/bbms-backend:latest
docker push <account-id>.dkr.ecr.ap-south-1.amazonaws.com/bbms-backend:latest

# Build frontend
cd ../frontend
docker build -t bbms-frontend .
docker tag bbms-frontend:latest <account-id>.dkr.ecr.ap-south-1.amazonaws.com/bbms-frontend:latest
docker push <account-id>.dkr.ecr.ap-south-1.amazonaws.com/bbms-frontend:latest
```

### 3. Deploy Services

```bash
aws ecs update-service --cluster bbms-cluster --service bbms-backend --force-new-deployment
aws ecs update-service --cluster bbms-cluster --service bbms-frontend --force-new-deployment
```

## Jenkins CI/CD Setup

1. **Install Jenkins plugins:**
   - AWS Pipeline
   - Docker Pipeline
   - Pipeline

2. **Configure AWS credentials in Jenkins:**
   - Go to Manage Jenkins > Manage Credentials
   - Add AWS credentials

3. **Create new Pipeline job:**
   - Point to your repository
   - Use `Jenkinsfile` from the root

## Architecture Overview

```
Internet → ALB → ECS Fargate Services → DynamoDB
                ├── Frontend (React)
                └── Backend (Node.js)
```

## DynamoDB Tables

- **bbms-users**: User authentication data
- **bbms-donors**: Donor information
- **bbms-requests**: Blood requests
- **bbms-inventory**: Blood inventory tracking

## Monitoring

- CloudWatch logs for application logs
- ECS service metrics
- ALB access logs

## Scaling

- ECS services can be scaled by updating desired count
- DynamoDB uses on-demand billing for automatic scaling

## Cleanup

To destroy all resources:
```bash
cd terraform
terraform destroy
```

## Troubleshooting

1. **ECS tasks failing to start:**
   - Check CloudWatch logs
   - Verify ECR image exists
   - Check task definition configuration

2. **ALB health checks failing:**
   - Verify security groups allow traffic
   - Check application health endpoint

3. **DynamoDB access issues:**
   - Verify IAM roles and policies
   - Check table names in environment variables
