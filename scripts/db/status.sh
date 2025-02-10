#!/usr/bin/env sh
. ./scripts/utils/status.sh

print_status_header "$DEFAULT_FORMAT" \
    "RESOURCE STATUS DETAILS" \
    "-------- ------ -------" \
    "Database Status"

CONTAINER_STATUS=$(docker compose ps db --format json | jq -r '.[0].State // empty')
if [ -z "$CONTAINER_STATUS" ]; then
    handle_status "Container" "false"
else
    handle_status "Container" "echo $CONTAINER_STATUS"
fi

if [ "$CONTAINER_STATUS" = "running" ]; then
    handle_status "Tables" "docker exec language_vows-db-1 psql -U postgres -d language_vows -c '\dt' -A -t"
    
    VOW_COUNT=$(docker exec language_vows-db-1 psql -U postgres -d language_vows -t -c 'SELECT COUNT(*) FROM vows;')
    printf "%-20s %-15s %s\n" "Vow Count" "INFO" "$(echo "$VOW_COUNT" | tr -d '[:space:]')"
fi

printf "\nDatabase status check completed.\n" 