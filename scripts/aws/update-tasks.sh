#!/usr/bin/env sh
printf "=== Task Definition Updates ===\n\n"
printf "%-25s %-15s %s\n" "RESOURCE" "STATUS" "DETAILS"
printf "%-25s %-15s %s\n" "--------" "------" "-------"

handle_status() {
    local resource=$1
    local command=$2
    local output
    
    output=$(eval "$command" 2>&1)
    echo "DEBUG: Command output: $output" >&2
    if [ $? -eq 0 ]; then
        printf "%-25s %-15s %s\n" "$resource" "SUCCESS" "-"
        return 0
    else
        printf "%-25s %-15s %s\n" "$resource" "FAILED" "$(echo "$output" | head -n1)"
        echo "DEBUG: Full error: $output" >&2
        return 1
    fi
}

# Get account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

# Get RDS endpoint
DB_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier language-vows-db \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text)

# Update backend task definition
handle_status "Backend Definition Update" "sed -i.bak 's|YOUR_ACCOUNT_ID|${ACCOUNT_ID}|g; s|language-vows-db.cluster-xxxxx.region.rds.amazonaws.com|${DB_ENDPOINT}|g' .aws/task-definition-backend.json"

# Update frontend task definition
handle_status "Frontend Definition Update" "sed -i.bak 's|http://backend.language-vows.local|http://backend.language-vows.local|g' .aws/task-definition-frontend.json"

printf "\nTask definition updates completed.\n" 