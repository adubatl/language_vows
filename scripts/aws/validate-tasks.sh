#!/usr/bin/env sh
# Source the shared status utilities
. ./scripts/utils/status.sh

# Print header
print_status_header "$DEFAULT_FORMAT" \
    "RESOURCE STATUS DETAILS" \
    "-------- ------ -------" \
    "Task Definition Validation"

# Validate backend task definition
handle_status "Backend Task Definition" \
    "aws ecs register-task-definition --cli-input-json file://.aws/task-definition-backend.json --no-cli-pager" || exit 1

# Validate frontend task definition
handle_status "Frontend Task Definition" \
    "aws ecs register-task-definition --cli-input-json file://.aws/task-definition-frontend.json --no-cli-pager" || exit 1

printf "\nTask definition validation completed.\n" 