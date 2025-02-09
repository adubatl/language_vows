#!/usr/bin/env sh
if docker compose ps db | grep -q "running"; then
    docker compose down
else
    echo "Database is not running"
fi 