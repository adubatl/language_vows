#!/usr/bin/env sh
. ./scripts/utils/status.sh

print_status_header "$DEFAULT_FORMAT" \
    "RESOURCE STATUS DETAILS" \
    "-------- ------ -------" \
    "Security Groups Setup"

handle_status() {
    local resource=$1
    local command=$2
    local output
    
    output=$(eval "$command" 2>&1)
    echo "DEBUG: Command output: $output" >&2
    if [ $? -eq 0 ]; then
        printf "$DEFAULT_FORMAT" "$resource" "SUCCESS" "-"
        return 0
    else
        case "$output" in
            *"already exists"* | *"InvalidGroup.Duplicate"*)
                printf "$DEFAULT_FORMAT" "$resource" "SKIPPED" "Already exists"
                return 0
                ;;
            *)
                printf "$DEFAULT_FORMAT" "$resource" "FAILED" "$(echo "$output" | head -n1)"
                echo "DEBUG: Full error: $output" >&2
                return 1
                ;;
        esac
    fi
}

VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=language-vows-vpc" --query 'Vpcs[0].VpcId' --output text)
if [ "$VPC_ID" = "None" ] || [ -z "$VPC_ID" ]; then
    echo "DEBUG: VPC lookup failed. Output: $(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=language-vows-vpc")" >&2
    printf "$DEFAULT_FORMAT" "VPC Lookup" "FAILED" "Could not find VPC"
    exit 1
fi
echo "DEBUG: Found VPC: $VPC_ID" >&2

ECS_SG=$(aws ec2 describe-security-groups \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=language-vows-ecs-sg" \
    --query 'SecurityGroups[0].GroupId' \
    --output text)
echo "DEBUG: Security group lookup result: $ECS_SG" >&2

if [ "$ECS_SG" = "None" ] || [ -z "$ECS_SG" ]; then
    echo "DEBUG: Creating new security group..." >&2
    handle_status "ECS Security Group" "aws ec2 create-security-group --group-name language-vows-ecs-sg --description 'Security group for ECS tasks' --vpc-id $VPC_ID" || exit 1
    
    sleep 2

    echo "DEBUG: Looking up newly created security group..." >&2
    ECS_SG=$(aws ec2 describe-security-groups \
        --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=language-vows-ecs-sg" \
        --query 'SecurityGroups[0].GroupId' \
        --output text)

    if [ "$ECS_SG" = "None" ] || [ -z "$ECS_SG" ]; then
        echo "DEBUG: Failed to get security group ID after creation" >&2
        exit 1
    fi
    echo "DEBUG: Created security group: $ECS_SG" >&2
else
    printf "$DEFAULT_FORMAT" "ECS Security Group" "SKIPPED" "Already exists"
fi

handle_status "Internal Access" "aws ec2 authorize-security-group-ingress \
    --group-id $ECS_SG \
    --protocol -1 \
    --source-group $ECS_SG" || true

RDS_SG=$(aws ec2 describe-security-groups \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=default" \
    --query 'SecurityGroups[0].GroupId' \
    --output text)

if [ "$RDS_SG" != "None" ] && [ -n "$RDS_SG" ]; then
    handle_status "RDS Access Rules" "aws ec2 authorize-security-group-ingress \
        --group-id $RDS_SG \
        --protocol tcp \
        --port 5432 \
        --source-group $ECS_SG" || true
else
    printf "$DEFAULT_FORMAT" "RDS Security Group" "FAILED" "Default group not found"
    exit 1
fi

printf "\nSecurity groups setup completed.\n" 