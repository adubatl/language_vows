#!/usr/bin/env sh
. ./scripts/utils/status.sh

print_status_header "$DEFAULT_FORMAT" \
    "RESOURCE STATUS DETAILS" \
    "-------- ------ -------" \
    "ECS Services Setup"

VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=language-vows-vpc" --query 'Vpcs[0].VpcId' --output text)
if [ -z "$VPC_ID" ] || [ "$VPC_ID" = "None" ]; then
    printf "%-25s %-15s %s\n" "VPC Lookup" "FAILED" "VPC not found"
    exit 1
fi

SUBNET_1=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=language-vows-private-1" \
    --query 'Subnets[0].SubnetId' --output text)
SUBNET_2=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=language-vows-private-2" \
    --query 'Subnets[0].SubnetId' --output text)

SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=language-vows-ecs-sg" \
    --query 'SecurityGroups[0].GroupId' --output text)

if [ -z "$SUBNET_1" ] || [ -z "$SUBNET_2" ] || [ -z "$SG_ID" ]; then
    printf "%-25s %-15s %s\n" "Resource Lookup" "FAILED" "Missing required resources"
    exit 1
fi

handle_status "Backend Service" "aws ecs create-service \
    --cluster language-vows \
    --service-name backend \
    --task-definition language-vows-backend \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration \"awsvpcConfiguration={subnets=[$SUBNET_1,$SUBNET_2],securityGroups=[$SG_ID],assignPublicIp=DISABLED}\" \
    --no-cli-pager"

handle_status "Frontend Service" "aws ecs create-service \
    --cluster language-vows \
    --service-name frontend \
    --task-definition language-vows-frontend \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration \"awsvpcConfiguration={subnets=[$SUBNET_1,$SUBNET_2],securityGroups=[$SG_ID],assignPublicIp=DISABLED}\" \
    --no-cli-pager"

printf "\nECS services setup completed.\n" 