#!/usr/bin/env sh
. ./scripts/utils/status.sh

print_status_header "$DEFAULT_FORMAT" \
    "RESOURCE STATUS DETAILS" \
    "-------- ------ -------" \
    "AWS Resource Teardown Status"

handle_status "ECS Backend" "aws ecs update-service --no-cli-pager --cluster language-vows --service backend --desired-count 0 2>/dev/null || true"
handle_status "ECS Frontend" "aws ecs update-service --no-cli-pager --cluster language-vows --service frontend --desired-count 0 2>/dev/null || true"
handle_status "ECS Backend Delete" "aws ecs delete-service --no-cli-pager --cluster language-vows --service backend 2>/dev/null || true"
handle_status "ECS Frontend Delete" "aws ecs delete-service --no-cli-pager --cluster language-vows --service frontend 2>/dev/null || true"

TASK_DEFS=$(aws ecs list-task-definitions --no-cli-pager --family-prefix language-vows --query 'taskDefinitionArns[]' --output text)
if [ -n "$TASK_DEFS" ] && [ "$TASK_DEFS" != "None" ]; then
    for task in $TASK_DEFS; do
        handle_status "Task Definition" "aws ecs deregister-task-definition --no-cli-pager --task-definition $task"
    done
else
    printf "%-20s %-15s %s\n" "Task Definitions" "SKIPPED" "No definitions found"
fi

handle_status "Secrets Manager" "aws secretsmanager delete-secret --no-cli-pager --secret-id language-vows/db-password --force-delete-without-recovery"

handle_status "ECS Cluster" "aws ecs delete-cluster --no-cli-pager --cluster language-vows"

handle_status "ECR Frontend" "aws ecr delete-repository --no-cli-pager --repository-name language-vows-frontend --force"
handle_status "ECR Backend" "aws ecr delete-repository --no-cli-pager --repository-name language-vows-backend --force"

handle_status "IAM Policy Detach" "aws iam detach-role-policy --no-cli-pager --role-name language-vows-ecs-execution-role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
handle_status "IAM Role Policy" "aws iam delete-role-policy --no-cli-pager --role-name language-vows-ecs-execution-role --policy-name SecretsManagerAccess"
handle_status "IAM Role" "aws iam delete-role --no-cli-pager --role-name language-vows-ecs-execution-role"

handle_status "RDS Instance" "aws rds delete-db-instance --no-cli-pager --db-instance-identifier language-vows-db --skip-final-snapshot --delete-automated-backups"

handle_status "Security Groups" "./scripts/aws/cleanup-security-groups.sh"

printf "\nTeardown process completed.\n" 