#!/usr/bin/env sh
. ./scripts/utils/status.sh

print_status_header "$DEFAULT_FORMAT" \
    "RESOURCE STATUS DETAILS" \
    "-------- ------ -------" \
    "ECS Role Setup"

handle_status "ECS Role Creation" "aws iam create-role \
    --role-name language-vows-ecs-execution-role \
    --assume-role-policy-document '{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ecs-tasks.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}'" || true

handle_status "ECS Task Policy" "aws iam attach-role-policy \
    --role-name language-vows-ecs-execution-role \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy" || true

handle_status "Secrets Access Policy" "aws iam put-role-policy \
    --role-name language-vows-ecs-execution-role \
    --policy-name SecretsManagerAccess \
    --policy-document '{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"secretsmanager:GetSecretValue\"],\"Resource\":\"arn:aws:secretsmanager:us-east-1:427385373315:secret:language-vows/*\"}]}'" || true

printf "\nECS role setup completed.\n" 