#!/usr/bin/env sh
printf "=== AWS Secrets Status ===\n\n"
printf "%-40s %-20s %s\n" "SECRET NAME" "LAST MODIFIED" "DETAILS"
printf "%-40s %-20s %s\n" "-----------" "-------------" "-------"

# List all secrets
aws secretsmanager list-secrets \
    --query 'SecretList[].[Name,LastChangedDate]' \
    --output text | \
while IFS=$'\t' read -r name date; do
    if [[ $name == *"language-vows"* ]]; then
        formatted_date=$(date -d "@$((${date%.*}))" '+%Y-%m-%d %H:%M:%S')
        printf "%-40s %-20s %s\n" "$name" "$formatted_date" "-"
    fi
done

printf "\nSecrets check completed.\n" 