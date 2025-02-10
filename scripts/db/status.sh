#!/usr/bin/env sh
# Source the shared status utilities
. ./scripts/utils/status.sh

# Print header
print_status_header "$DEFAULT_FORMAT" \
    "RESOURCE STATUS DETAILS" \
    "-------- ------ -------" \
    "Database Status"

# Check if container is running
CONTAINER_STATUS=$(docker compose ps db --format json | jq -r '.[0].State // empty')
if [ -z "$CONTAINER_STATUS" ]; then
    handle_status "Container" "false" # Use false command to trigger failure case
else
    handle_status "Container" "echo $CONTAINER_STATUS"
fi

# If container is running, check database details
if [ "$CONTAINER_STATUS" = "running" ]; then
    # Check tables
    handle_status "Tables" "docker exec language_vows-db-1 psql -U postgres -d language_vows -c '\dt' -A -t"
    
    # Check vow count
    VOW_COUNT=$(docker exec language_vows-db-1 psql -U postgres -d language_vows -t -c 'SELECT COUNT(*) FROM vows;')
    printf "%-20s %-15s %s\n" "Vow Count" "INFO" "$(echo "$VOW_COUNT" | tr -d '[:space:]')"
fi

printf "\nDatabase status check completed.\n" 