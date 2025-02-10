#!/usr/bin/env sh
if [ -z "$1" ]; then
    echo "Usage: $0 <resource-type>"
    echo "Available options: rds, ecr, ecs, vpc"
    exit 1
fi

printf "=== AWS %s Status ===\n\n" "${1^^}"

case "$1" in
    "rds")
        printf "%-30s %-15s %s\n" "INSTANCE" "STATUS" "ENDPOINT"
        printf "%-30s %-15s %s\n" "--------" "------" "--------"
        aws rds describe-db-instances --no-cli-pager \
            --query 'DBInstances[].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address]' \
            --output text | \
        while IFS=$'\t' read -r id status endpoint; do
            if [[ $id == *"language-vows"* ]]; then
                printf "%-30s %-15s %s\n" "$id" "$status" "$endpoint"
            fi
        done
        ;;
        
    "ecr")
        printf "%-30s %s\n" "REPOSITORY" "URI"
        printf "%-30s %s\n" "----------" "---"
        aws ecr describe-repositories --no-cli-pager \
            --query 'repositories[].[repositoryName,repositoryUri]' \
            --output text | \
        while IFS=$'\t' read -r name uri; do
            if [[ $name == *"language-vows"* ]]; then
                printf "%-30s %s\n" "$name" "$uri"
            fi
        done
        ;;
        
    "ecs")
        printf "%-30s %s\n" "CLUSTER" "STATUS"
        printf "%-30s %s\n" "-------" "------"
        aws ecs list-clusters --no-cli-pager | \
        jq -r '.clusterArns[]' | \
        while read -r arn; do
            name=$(basename "$arn")
            if [[ $name == *"language-vows"* ]]; then
                status=$(aws ecs describe-clusters --clusters "$arn" --query 'clusters[0].status' --output text)
                printf "%-30s %s\n" "$name" "$status"
            fi
        done
        ;;
        
    "vpc")
        printf "%-20s %-15s %-20s %s\n" "VPC ID" "CIDR" "NAME" "STATE"
        printf "%-20s %-15s %-20s %s\n" "------" "----" "----" "-----"
        aws ec2 describe-vpcs --no-cli-pager \
            --query 'Vpcs[].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0],State]' \
            --output text | \
        while IFS=$'\t' read -r id cidr name state; do
            if [[ $name == *"language-vows"* ]]; then
                printf "%-20s %-15s %-20s %s\n" "$id" "$cidr" "${name:---}" "$state"
            fi
        done
        ;;
        
    *)
        echo "Unknown resource type: $1"
        echo "Available options: rds, ecr, ecs, vpc"
        exit 1
        ;;
esac

printf "\n%s check completed.\n" "${1^^}" 