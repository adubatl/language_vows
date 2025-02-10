#!/usr/bin/env sh
. ./scripts/utils/status.sh

print_status_header "$DEFAULT_FORMAT" \
    "RESOURCE STATUS DETAILS" \
    "-------- ------ -------" \
    "Task Definition Validation"

handle_status "Backend Task Definition" \
    "aws ecs register-task-definition --cli-input-json file://.aws/task-definition-backend.json --no-cli-pager" || exit 1

handle_status "Frontend Task Definition" \
    "aws ecs register-task-definition --cli-input-json file://.aws/task-definition-frontend.json --no-cli-pager" || exit 1

printf "\nTask definition validation completed.\n" 