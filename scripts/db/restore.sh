#!/usr/bin/env sh
if [ -f backend/internal/db/backup/seed.sql ]; then
    cat backend/internal/db/backup/seed.sql | docker exec -i language_vows-db-1 psql -U postgres -d language_vows
    echo "Database restored from backup"
else
    echo "No backup file found at backend/internal/db/backup/seed.sql"
fi 