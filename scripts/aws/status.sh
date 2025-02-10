#!/usr/bin/env sh
printf "=== AWS Resource Overview ===\n\n"

# Function to print section header
print_header() {
    printf "\n=== %s ===\n\n" "$1"
}

# Function to handle AWS queries with consistent formatting
handle_query() {
    local output
    output=$($1)
    if [ $? -eq 0 ]; then
        echo "$output"
    else
        printf "Error fetching data\n"
        return 1
    fi
}

# RDS Instances
print_header "RDS Instances"
handle_query "aws rds describe-db-instances --no-cli-pager \
    --query 'DBInstances[].{ID:DBInstanceIdentifier,Status:DBInstanceStatus,Class:DBInstanceClass,Engine:Engine}' \
    --output table"

# ECR Repositories
print_header "ECR Repositories"
handle_query "aws ecr describe-repositories --no-cli-pager \
    --query 'repositories[].{Name:repositoryName,URI:repositoryUri}' \
    --output table"

# ECS Clusters
print_header "ECS Clusters"
handle_query "aws ecs list-clusters --no-cli-pager \
    --query 'clusterArns[]' \
    --output table"

# VPCs
print_header "VPCs"
handle_query "aws ec2 describe-vpcs --no-cli-pager \
    --query 'Vpcs[].{ID:VpcId,CIDR:CidrBlock,Name:Tags[?Key==\`Name\`].Value|[0]}' \
    --output table"

# Subnets
print_header "Subnets"
handle_query "aws ec2 describe-subnets --no-cli-pager \
    --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,Name:Tags[?Key==\`Name\`].Value|[0],AZ:AvailabilityZone}' \
    --output table" | sed 's/None/---/g'

printf "\nResource overview completed.\n" 