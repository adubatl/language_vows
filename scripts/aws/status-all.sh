#!/usr/bin/env sh
printf "=== AWS Infrastructure Status ===\n\n"

print_header() {
    printf "\n=== %s ===\n\n" "$1"
}

print_header "RDS Status"
./scripts/aws/check.sh rds

print_header "ECR Status"
./scripts/aws/check.sh ecr

print_header "ECS Status"
./scripts/aws/check.sh ecs

print_header "VPC Status"
./scripts/aws/check.sh vpc

print_header "Service Status"
./scripts/aws/services.sh

print_header "Secrets Status"
./scripts/aws/secrets.sh

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