#!/usr/bin/env sh
. ./scripts/utils/status.sh

print_status_header "$DEFAULT_FORMAT" \
    "RESOURCE STATUS DETAILS" \
    "-------- ------ -------" \
    "ECS Services Status"

handle_status "Backend Service" "aws ecs describe-services --no-cli-pager \
    --cluster language-vows \
    --services backend \
    --query 'services[0].{Status:status,Running:runningCount,Desired:desiredCount}' \
    --output text"

handle_status "Frontend Service" "aws ecs describe-services --no-cli-pager \
    --cluster language-vows \
    --services frontend \
    --query 'services[0].{Status:status,Running:runningCount,Desired:desiredCount}' \
    --output text"

printf "\nRecent Events:\n"
printf "%-25s %-30s %s\n" "SERVICE" "TIMESTAMP" "MESSAGE"
printf "%-25s %-30s %s\n" "-------" "---------" "-------"

aws ecs describe-services --no-cli-pager \
    --cluster language-vows \
    --services backend frontend \
    --query 'services[].{name:serviceName,events:events[0:3]}[]' \
    --output json | jq -r '.[] | select(.events != null) | .events[] | "\(.name)\t\(.createdAt)\t\(.message)"' | \
    while IFS=$'\t' read -r service timestamp message; do
        printf "%-25s %-30s %s\n" "${service:0:20}" "$(date -d "$timestamp" '+%Y-%m-%d %H:%M:%S')" "${message:0:50}..."
    done

printf "\nService check completed.\n" 