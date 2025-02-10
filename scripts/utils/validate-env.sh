#!/usr/bin/env sh

validate_env() {
    local missing=0
    for var in "$@"; do
        if [ -z "$(eval echo \$$var)" ]; then
            echo "Error: $var is not set"
            missing=1
        fi
    done
    return $missing
}

# Required variables for AWS deployment
REQUIRED_VARS="
AWS_REGION
AWS_ACCOUNT_ID
PROJECT_NAME
DB_NAME
DB_USERNAME
"

validate_env $REQUIRED_VARS 