#!/usr/bin/env sh
printf "=== GitHub Secrets Setup ===\n\n"
printf "%-25s %-15s %s\n" "SECRET" "STATUS" "DETAILS"
printf "%-25s %-15s %s\n" "------" "------" "-------"

handle_status() {
    local resource=$1
    local command=$2
    local output
    
    output=$($command 2>&1)
    if [ $? -eq 0 ]; then
        printf "%-25s %-15s %s\n" "$resource" "SUCCESS" "-"
    else
        printf "%-25s %-15s %s\n" "$resource" "FAILED" "$(echo "$output" | head -n1)"
        return 1
    fi
    return 0
}

AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)

if [ ! -f .env.aws.generated ]; then
    printf "%-25s %-15s %s\n" "Credentials File" "FAILED" "File not found"
    exit 1
fi

DB_PASSWORD=$(grep DB_PASSWORD .env.aws.generated | cut -d'=' -f2)

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$DB_PASSWORD" ]; then
    printf "%-25s %-15s %s\n" "Credentials Check" "FAILED" "Missing credentials"
    exit 1
fi

handle_status "AWS Access Key ID" "gh secret set AWS_ACCESS_KEY_ID --body \"$AWS_ACCESS_KEY_ID\"" || exit 1
handle_status "AWS Secret Key" "gh secret set AWS_SECRET_ACCESS_KEY --body \"$AWS_SECRET_ACCESS_KEY\"" || exit 1
handle_status "DB Password" "gh secret set DB_PASSWORD --body \"$DB_PASSWORD\"" || exit 1

printf "\nGitHub secrets setup completed.\n" 