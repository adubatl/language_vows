#!/usr/bin/env sh

# Default format strings for status output
DEFAULT_FORMAT="%-20s %-15s %s\n"
DEFAULT_HEADER="RESOURCE STATUS DETAILS"
DEFAULT_SEPARATOR="-------- ------ -------"

# Print status header with custom or default format
print_status_header() {
    local format="${1:-$DEFAULT_FORMAT}"
    local header="${2:-$DEFAULT_HEADER}"
    local separator="${3:-$DEFAULT_SEPARATOR}"
    
    printf "\n=== %s ===\n\n" "${4:-Status}"
    printf "$format" $(echo "$header" | tr ' ' '\n')
    printf "$format" $(echo "$separator" | tr ' ' '\n')
}

# Handle command execution and status output
handle_status() {
    local resource=$1
    local command=$2
    local format="${3:-$DEFAULT_FORMAT}"
    local output
    
    # Execute command and capture output
    output=$(eval "$command" 2>&1)
    status=$?

    # Log debug output if DEBUG is set
    [ -n "$DEBUG" ] && echo "DEBUG: Command output: $output" >&2
    
    if [ $status -eq 0 ]; then
        printf "$format" "$resource" "SUCCESS" "-"
        [ -n "$LOG_FILE" ] && log "INFO" "$resource: SUCCESS - $output" "$LOG_FILE"
        return 0
    else
        case "$output" in
            *"already exists"* | \
            *"AlreadyExistsException"* | \
            *"ResourceExistsException"* | \
            *"has been taken"* | \
            *"EntityAlreadyExists"* | \
            *"InvalidGroup.Duplicate"* | \
            *"RepositoryAlreadyExistsException"*)
                printf "$format" "$resource" "SKIPPED" "Already exists"
                [ -n "$LOG_FILE" ] && log "INFO" "$resource: SKIPPED - Already exists" "$LOG_FILE"
                ;;
            *"not found"* | \
            *"NoSuchEntity"* | \
            *"NotFoundException"* | \
            *"DBInstanceNotFound"* | \
            *"ClusterNotFoundException"* | \
            *"ServiceNotActiveException"* | \
            *"INACTIVE"* | \
            *"Unable to locate"* | \
            *"ServiceNotFoundException"*)
                printf "$format" "$resource" "SKIPPED" "Not found"
                [ -n "$LOG_FILE" ] && log "INFO" "$resource: SKIPPED - Not found" "$LOG_FILE"
                ;;
            *"DependencyViolation"*)
                printf "$format" "$resource" "BLOCKED" "Has dependencies"
                [ -n "$LOG_FILE" ] && log "WARN" "$resource: BLOCKED - Has dependencies" "$LOG_FILE"
                ;;
            *"ValidationError"* | \
            *"ValidationException"*)
                printf "$format" "$resource" "FAILED" "Validation error"
                [ -n "$DEBUG" ] && echo "DEBUG: $output" >&2
                [ -n "$LOG_FILE" ] && log "ERROR" "$resource: FAILED - $output" "$LOG_FILE"
                return 1
                ;;
            *"LimitExceeded"*)
                printf "$format" "$resource" "FAILED" "Service limit exceeded"
                [ -n "$LOG_FILE" ] && log "ERROR" "$resource: FAILED - $output" "$LOG_FILE"
                return 1
                ;;
            *)
                printf "$format" "$resource" "FAILED" "$(echo "$output" | head -n1)"
                [ -n "$DEBUG" ] && echo "DEBUG: Full error: $output" >&2
                [ -n "$LOG_FILE" ] && log "ERROR" "$resource: FAILED - $output" "$LOG_FILE"
                return 1
                ;;
        esac
    fi
    return 0
}

# Optional logging function
log() {
    local level=$1
    local message=$2
    local log_file=$3
    
    if [ -n "$log_file" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $level: $message" >> "$log_file"
    fi
} 