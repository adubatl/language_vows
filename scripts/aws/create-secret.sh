#!/usr/bin/env sh
. ./scripts/utils/status.sh

print_status_header "$DEFAULT_FORMAT" \
    "RESOURCE STATUS DETAILS" \
    "-------- ------ -------" \
    "AWS Secrets Manager Setup"

if [ ! -f .env.aws.generated ]; then
    printf "%-25s %-15s %s\n" "Credentials File" "FAILED" "File not found"
    exit 1
fi

DB_PASSWORD=$(grep DB_PASSWORD .env.aws.generated | cut -d'=' -f2)
if [ -z "$DB_PASSWORD" ]; then
    printf "%-25s %-15s %s\n" "DB Password" "FAILED" "Password not found"
    exit 1
fi

handle_status "DB Password Secret" "aws secretsmanager create-secret \
    --name language-vows/db-password \
    --secret-string \"$DB_PASSWORD\" \
    --description \"Database password for language-vows\""

printf "\nSecrets setup completed.\n" 