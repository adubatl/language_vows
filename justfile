# List all recipes
default:
    @just --list

# Start up the frontend
frontend-up:
    npm run dev
alias fe := frontend-up

# Start the database container
db-up:
    ./scripts/db-up.sh

# Stop the database container
db-down:
    ./scripts/db-down.sh

# Restart the database container
db-restart:
    just db-down
    just db-up

# Connect to PostgreSQL database
db-connect:
    docker exec -it language_vows-db-1 psql -U postgres -d language_vows

# Show all tables in the database
db-tables:
    docker exec -it language_vows-db-1 psql -U postgres -d language_vows -c '\dt'

# Show contents of vows table
db-vows:
    docker exec -it language_vows-db-1 psql -U postgres -d language_vows -c 'SELECT * FROM vows;'

# Count rows in a table (default: vows)
db-count table="vows":
    docker exec -it language_vows-db-1 psql -U postgres -d language_vows -c 'SELECT COUNT(*) FROM {{table}};'

# Clear all vows from the table
db-clear:
    docker exec -it language_vows-db-1 psql -U postgres -d language_vows -c 'DELETE FROM vows;'

# Create the vows table (idempotent)
db-init:
    docker exec -it language_vows-db-1 psql -U postgres -d language_vows -f /docker-entrypoint-initdb.d/schema.sql

# Run the Go backend server
go-run:
    ./scripts/go-run.sh

# Start everything (database + backend)
start:
    just db-up
    just go-run
alias be := start

# Backup the database to a file (seed.sql or timestamped)
db-backup type="timestamp":
    ./scripts/db-backup.sh {{type}}

# Restore the database from backup
db-restore:
    ./scripts/db-restore.sh

# Initialize database with schema and seed data
db-init-all:
    just db-init
    just db-restore
