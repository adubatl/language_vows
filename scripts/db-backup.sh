#!/usr/bin/env sh
mkdir -p backend/internal/db/backup
if [ "$1" = "seed" ]; then
    docker exec language_vows-db-1 pg_dump -U postgres language_vows > backend/internal/db/backup/seed.sql
    echo "Database backed up to seed.sql"
else
    timestamp=$(date +%Y%m%d_%H%M%S)
    docker exec language_vows-db-1 pg_dump -U postgres language_vows > backend/internal/db/backup/backup_${timestamp}.sql
    echo "Database backed up to backup_${timestamp}.sql"
fi 