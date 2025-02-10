#!/usr/bin/env sh
. "$(dirname "$0")/../utils/status.sh"

if [ -f "$(dirname "$0")/../../.env.aws" ]; then
    . "$(dirname "$0")/../../.env.aws"
else
    printf "%-20s %-15s %s\n" "Config" "FAILED" ".env.aws not found"
    exit 1
fi

if ! command -v just >/dev/null 2>&1; then
    echo "Error: just command not found"
    exit 1
fi

LOG_FILE=".aws/setup-$(date '+%Y%m%d-%H%M%S').log"
mkdir -p "$(dirname "$LOG_FILE")"
: > "$LOG_FILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1: $2" >> "$LOG_FILE"
}

print_status_header "$DEFAULT_FORMAT" \
    "RESOURCE STATUS DETAILS" \
    "-------- ------ -------" \
    "AWS Resource Setup Status"

log "INFO" "Starting AWS infrastructure setup"

output=$(./scripts/aws/setup.sh 2>&1)
status=$?
log "INFO" "Setup output: $output"

if [ $status -ne 0 ]; then
    error_msg=$(echo "$output" | grep -v "VPC SKIPPED" | head -n1)
    printf "%-30s %-15s %s\n" "Initial Setup" "FAILED" "$error_msg"
    log "ERROR" "Full error output: $output"
    exit 1
fi
printf "%-30s %-15s %s\n" "Initial Setup" "SUCCESS" "-"

attempts=0
max_attempts=120
while [ $attempts -lt $max_attempts ]; do
    status=$(aws rds describe-db-instances \
        --db-instance-identifier language-vows-db \
        --no-cli-pager \
        --query 'DBInstances[0].DBInstanceStatus' \
        --output text 2>/dev/null)
    
    case "$status" in
        "available")
            printf "%-30s %-15s %s\n" "RDS Instance" "SUCCESS" "Available"
            break
            ;;
        "deleting")
            if [ $attempts -eq 0 ]; then
                printf "%-30s %-15s %s\n" "RDS Instance" "PENDING" "Waiting for previous instance to be deleted..."
            fi
            if [ $attempts -eq 60 ]; then
                printf "%-30s %-15s %s\n" "RDS Instance" "PENDING" "Still deleting, please be patient..."
            fi
            ;;
        "creating"|"backing-up"|"modifying")
            if [ $attempts -eq 0 ]; then
                printf "%-30s %-15s %s\n" "RDS Instance" "PENDING" "Creating..."
            fi
            ;;
        *)
            if [ "$status" = "None" ] || [ -z "$status" ]; then
                break
            fi
            printf "%-30s %-15s %s\n" "RDS Instance" "FAILED" "Unexpected status: $status"
            exit 1
            ;;
    esac
    
    attempts=$((attempts + 1))
    if [ $attempts -eq $max_attempts ]; then
        printf "%-30s %-15s %s\n" "RDS Instance" "FAILED" "Timeout after $((max_attempts * 10))s"
        exit 1
    fi
    sleep 10
done

if [ "$status" = "deleting" ] || [ "$status" = "None" ] || [ -z "$status" ]; then
    printf "%-30s %-15s %s\n" "RDS Instance" "PENDING" "Previous instance deleted, creating new one..."
    sleep 30
    
    DB_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9#%^*+=' | fold -w 16 | head -n 1)
    
    mkdir -p .aws
    cat > .env.aws.generated << EOL
# Generated AWS Credentials - DO NOT COMMIT THIS FILE
# Generated on $(date)
DB_PASSWORD=${DB_PASSWORD}
EOL
    
    attempts=0
    while [ $attempts -lt $max_attempts ]; do
        status=$(aws rds describe-db-instances \
            --db-instance-identifier language-vows-db \
            --no-cli-pager \
            --query 'DBInstances[0].DBInstanceStatus' \
            --output text 2>/dev/null)
        
        case "$status" in
            "available")
                printf "%-30s %-15s %s\n" "RDS Instance" "SUCCESS" "Available"
                break
                ;;
            "creating"|"backing-up"|"modifying")
                if [ $attempts -eq 0 ]; then
                    printf "%-30s %-15s %s\n" "RDS Instance" "PENDING" "Creating..."
                fi
                ;;
            *)
                if [ $attempts -eq 0 ]; then
                    aws rds create-db-instance \
                        --db-instance-identifier language-vows-db \
                        --db-instance-class db.t3.micro \
                        --engine postgres \
                        --master-username postgres \
                        --master-user-password "$DB_PASSWORD" \
                        --allocated-storage 20 \
                        --backup-retention-period 7 \
                        --no-multi-az \
                        --auto-minor-version-upgrade \
                        --no-publicly-accessible \
                        --db-subnet-group-name language-vows-db-subnet \
                        --no-cli-pager \
                        --tags Key=Project,Value=language-vows || {
                            printf "%-30s %-15s %s\n" "RDS Instance" "FAILED" "Creation failed"
                            exit 1
                        }
                fi
                ;;
        esac
        
        attempts=$((attempts + 1))
        if [ $attempts -eq $max_attempts ]; then
            printf "%-30s %-15s %s\n" "RDS Instance" "FAILED" "Timeout after $((max_attempts * 10))s"
            exit 1
        fi
        sleep 10
    done
fi

handle_status "Credentials" "just aws-fetch-credentials" || exit 1
handle_status "Security Groups" "just aws-create-security" || exit 1
handle_status "Secrets Manager" "just aws-create-secret" || exit 1
handle_status "ECS Role" "just aws-create-ecs-role" || exit 1
handle_status "Task Definitions" "just aws-update-tasks" || exit 1
handle_status "Task Validation" "just aws-validate-tasks" || exit 1
handle_status "ECS Services" "just aws-create-services" || exit 1

printf "\nSetup completed. See %s for details.\n" "$LOG_FILE" 