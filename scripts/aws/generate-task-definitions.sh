#!/usr/bin/env sh
# Source the shared status utilities
. ./scripts/utils/status.sh

# Print header
print_status_header "$DEFAULT_FORMAT" \
    "RESOURCE STATUS DETAILS" \
    "-------- ------ -------" \
    "Task Definition Generation"

# Load environment variables
if [ ! -f .env.aws ]; then
    printf "%-25s %-15s %s\n" "Environment" "FAILED" ".env.aws not found"
    exit 1
fi
. .env.aws

# Get RDS endpoint
RDS_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier ${PROJECT_NAME}-db \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text)

if [ -z "$RDS_ENDPOINT" ] || [ "$RDS_ENDPOINT" = "None" ]; then
    printf "%-25s %-15s %s\n" "RDS Endpoint" "FAILED" "Could not fetch endpoint"
    exit 1
fi

# Generate backend task definition
handle_status "Backend Definition" "cat .aws/task-definition-backend.template.json | \
    sed \"s/\${PROJECT_NAME}/$PROJECT_NAME/g\" | \
    sed \"s/\${AWS_ACCOUNT_ID}/$AWS_ACCOUNT_ID/g\" | \
    sed \"s/\${AWS_REGION}/$AWS_REGION/g\" | \
    sed \"s/\${RDS_ENDPOINT}/$RDS_ENDPOINT/g\" | \
    sed \"s/\${DB_NAME}/$DB_NAME/g\" | \
    sed \"s/\${DB_USERNAME}/$DB_USERNAME/g\" \
    > .aws/task-definition-backend.json"

printf "\nTask definition generation completed.\n" 