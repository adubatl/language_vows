#!/usr/bin/env sh
printf "=== AWS Service Quotas ===\n\n"
printf "%-35s %-15s %s\n" "QUOTA" "VALUE" "DETAILS"
printf "%-35s %-15s %s\n" "-----" "-----" "-------"

handle_status() {
    local resource=$1
    local command=$2
    local output
    
    output=$($command 2>&1)
    if [ $? -eq 0 ]; then
        echo "$output" | while read -r line; do
            printf "%-35s %-15s %s\n" "$(echo "$line" | cut -f1)" "$(echo "$line" | cut -f2)" "-"
        done
    else
        printf "%-35s %-15s %s\n" "$resource" "FAILED" "Could not fetch quota"
    fi
}

# Check Fargate quotas
handle_status "Fargate Quotas" "aws service-quotas list-service-quotas \
    --service-code fargate \
    --query 'Quotas[].[QuotaName,Value]' \
    --output text"

# Check account status
printf "\n=== Account Status ===\n\n"
aws sts get-caller-identity \
    --query '{Account:Account,UserID:UserId,ARN:Arn}' \
    --output table

printf "\nQuota check completed.\n" 