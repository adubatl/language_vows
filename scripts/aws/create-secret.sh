#!/usr/bin/env sh
# Source the shared status utilities
. ./scripts/utils/status.sh

# Print header
print_status_header "$DEFAULT_FORMAT" \
    "RESOURCE STATUS DETAILS" \
    "-------- ------ -------" \
    "AWS Secrets Manager Setup"

# Check for credentials file
if [ ! -f .env.aws.generated ]; then
    printf "%-25s %-15s %s\n" "Credentials File" "FAILED" "File not found"
    exit 1
fi

# Get DB password
DB_PASSWORD=$(grep DB_PASSWORD .env.aws.generated | cut -d'=' -f2)
if [ -z "$DB_PASSWORD" ]; then
    printf "%-25s %-15s %s\n" "DB Password" "FAILED" "Password not found"
    exit 1
fi

# Create secret
handle_status "DB Password Secret" "aws secretsmanager create-secret \
    --name language-vows/db-password \
    --secret-string \"$DB_PASSWORD\" \
    --description \"Database password for language-vows\""

printf "\nSecrets setup completed.\n" 