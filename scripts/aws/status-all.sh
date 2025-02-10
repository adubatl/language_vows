#!/usr/bin/env sh
printf "=== AWS Infrastructure Status ===\n\n"

# Function to print section header
print_header() {
    printf "\n=== %s ===\n\n" "$1"
}

# RDS Status
print_header "RDS Status"
./scripts/aws/check.sh rds

# ECR Status
print_header "ECR Status"
./scripts/aws/check.sh ecr

# ECS Status
print_header "ECS Status"
./scripts/aws/check.sh ecs

# VPC Status
print_header "VPC Status"
./scripts/aws/check.sh vpc

# Service Status
print_header "Service Status"
./scripts/aws/services.sh

# Secrets Status
print_header "Secrets Status"
./scripts/aws/secrets.sh

# Subnet Status
print_header "Subnet Status"
printf "%-20s %-15s %-20s %s\n" "SUBNET ID" "CIDR" "NAME" "AZ"
printf "%-20s %-15s %-20s %s\n" "---------" "----" "----" "--"
aws ec2 describe-subnets --no-cli-pager \
    --query 'Subnets[].[SubnetId,CidrBlock,Tags[?Key==`Name`].Value|[0],AvailabilityZone]' \
    --output text | \
while IFS=$'\t' read -r id cidr name az; do
    if [[ $name == *"language-vows"* ]]; then
        printf "%-20s %-15s %-20s %s\n" "$id" "$cidr" "${name:---}" "$az"
    fi
done

printf "\nStatus check completed.\n" 