#!/bin/bash
set -e

# Load environment variables
source .env.aws

# Fetch RDS credentials
DB_PASSWORD=$(aws rds describe-db-instances \
    --db-instance-identifier ${PROJECT_NAME}-db \
    --query 'DBInstances[0].MasterUserPassword' \
    --output text)

# Get RDS endpoint
DB_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier ${PROJECT_NAME}-db \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text)

# Create .env.aws.generated with sensitive data
cat > .env.aws.generated << EOL
# Generated AWS Credentials - DO NOT COMMIT THIS FILE
# Generated on $(date)

# Database Configuration
DB_HOST=${DB_ENDPOINT}
DB_PORT=5432
DB_NAME=${DB_NAME}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}

# ECR Repository URLs
ECR_FRONTEND_URL=$(aws ecr describe-repositories --repository-names ${PROJECT_NAME}-frontend --query 'repositories[0].repositoryUri' --output text)
ECR_BACKEND_URL=$(aws ecr describe-repositories --repository-names ${PROJECT_NAME}-backend --query 'repositories[0].repositoryUri' --output text)
EOL

echo "Credentials saved to .env.aws.generated" 