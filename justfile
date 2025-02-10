# List all recipes
default:
    @just --list

# Start all services with Docker Compose
up:
    docker compose up -d

# Stop all services
down:
    docker compose down

# Show logs for all services
logs:
    docker compose logs -f

# Show logs for a specific service
service-logs service:
    docker compose logs -f {{service}}

# Pull the Mistral model for Ollama
ollama-pull:
    docker compose exec ollama ollama pull mistral

# Start up the frontend
frontend-up:
    npm run dev
alias fe := frontend-up

# Start the database container
db-up:
    ./scripts/db/up.sh

# Stop the database container
db-down:
    ./scripts/db/down.sh

# Restart the database container
db-restart:
    just db-down
    just db-up

# Connect to PostgreSQL database
db-connect:
    docker exec -it language_vows-db-1 psql -U postgres -d language_vows

# Show all tables in the database
db-tables:
    ./scripts/db/status.sh

# Show contents of vows table
db-vows:
    docker exec language_vows-db-1 psql -U postgres -d language_vows -c '\x on' -c 'SELECT * FROM vows;'

# Count rows in a table (default: vows)
db-count table="vows":
    docker exec language_vows-db-1 psql -U postgres -d language_vows -t -c 'SELECT COUNT(*) FROM {{table}};' | tr -d '[:space:]'

# Clear all vows from the table
db-clear:
    docker exec -it language_vows-db-1 psql -U postgres -d language_vows -c 'DELETE FROM vows;'

# Create the vows table (idempotent)
db-init:
    docker exec -it language_vows-db-1 psql -U postgres -d language_vows -f /docker-entrypoint-initdb.d/schema.sql

# Run the Go backend server
go-run:
    ./scripts/dev/go-run.sh

# Check status of all services
status:
    @echo "=== Database Status ==="
    @just db-status
    @echo "\n=== Backend Status ==="
    @just backend-status
    @echo "\n=== Ollama Status ==="
    @just ollama-status

# Check database status
db-status:
    ./scripts/db/status.sh

# Check backend status
backend-status:
    @curl -s http://localhost:8080/api/vows > /dev/null && echo "Backend: ✅ Running" || echo "Backend: ❌ Not running"

# Check Ollama status
ollama-status:
    @curl -s http://localhost:11434/api/version > /dev/null && echo "Ollama: ✅ Running" || echo "Ollama: ❌ Not running"

# Start everything (backend, database, and Ollama)
start:
    just db-up
    docker compose up -d ollama
    sleep 5  # Give Ollama time to start
    just go-run
alias be := start

# Backup the database to a file (seed.sql or timestamped)
db-backup type="timestamp":
    ./scripts/db/backup.sh {{type}}

# Restore the database from backup
db-restore:
    ./scripts/db/restore.sh

# Initialize database with schema and seed data
db-init-all:
    just db-init
    just db-restore

# List all AWS resources for the project
aws-status:
    ./scripts/aws/status.sh

# Check specific AWS resource status
aws-check RESOURCE:
    ./scripts/aws/check.sh {{RESOURCE}}

# Set GitHub secrets from AWS config and generated credentials
gh-secrets:
    ./scripts/gh-secrets.sh

# Check AWS Secrets Manager
aws-check-secrets:
    ./scripts/aws/secrets.sh

# Validate ECS task definitions
aws-validate-tasks:
    ./scripts/aws/validate-tasks.sh

# Check ECS service status and events
aws-check-services:
    ./scripts/aws/services.sh

# Check AWS Fargate service quotas
aws-check-quotas:
    ./scripts/aws/quotas.sh

# Create AWS secret for DB password
aws-create-secret:
    ./scripts/aws/create-secret.sh

# Update task definitions with actual values
aws-update-tasks:
    ./scripts/aws/update-tasks.sh

# Create security groups for ECS and RDS
aws-create-security:
    ./scripts/aws/create-security.sh

# Create ECS execution role
aws-create-ecs-role:
    ./scripts/aws/create-ecs-role.sh

# Create ECS services
aws-create-services:
    ./scripts/aws/create-services.sh

# Clean up AWS resources
aws-cleanup:
    ./scripts/aws/cleanup.sh

# Full AWS cleanup including VPC and RDS
aws-teardown:
    ./scripts/aws/teardown.sh

# Generate AWS task definitions
aws-generate-tasks:
    ./scripts/aws/generate-task-definitions.sh

# Full AWS setup sequence with generated tasks
aws-setup-all:
    test -f .env.aws || { echo "Error: Must be run from project root directory"; exit 1; }
    just aws-generate-tasks
    test -x scripts/aws/setup-all.sh || chmod +x scripts/aws/setup-all.sh
    scripts/aws/setup-all.sh

# Check all AWS resource status
aws-status-all:
    ./scripts/aws/status-all.sh

# Fetch AWS credentials and save to .env.aws.generated
aws-fetch-credentials:
    ./scripts/dev/fetch-credentials.sh
