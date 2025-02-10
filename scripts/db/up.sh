#!/usr/bin/env sh
if docker compose ps db | grep -q "running"; then
    echo "Database is already running"
else
    docker compose up db -d
    sleep 2
fi 