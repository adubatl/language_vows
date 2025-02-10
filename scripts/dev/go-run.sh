#!/usr/bin/env sh
if [ "$(uname)" = "Windows_NT" ]; then
    if netstat -ano | findstr ":8080" > /dev/null; then
        echo "Backend server is already running on port 8080"
        exit 0
    fi
else
    if lsof -i:8080 > /dev/null 2>&1; then
        echo "Backend server is already running on port 8080"
        exit 0
    fi
fi
cd backend && go run cmd/main.go 