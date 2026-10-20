#!/usr/bin/env bash
set -e

# Change to script directory (project root)
cd "$(dirname "$0")"

echo "=========================================="
echo "          Starting DevPilot               "
echo "=========================================="

# Load environment variables if .env exists
if [ -f .env ]; then
    echo "▶ Loading environment variables from .env..."
    set -a
    source .env
    set +a
fi

# 1. Start PostgreSQL (pgvector) container
echo "▶ Starting PostgreSQL container..."
if ! docker info >/dev/null 2>&1; then
    echo "⚠️  Docker is not running. Launching Docker..."
    open -a Docker
    echo "Waiting for Docker daemon to become ready..."
    while ! docker info >/dev/null 2>&1; do
        sleep 2
    done
fi

docker compose up -d postgres
echo "✓ Database is running on port 5433."

# 2. Check and start backend & frontend
echo ""
echo "=========================================="
echo "To run the services in separate terminals:"
echo "------------------------------------------"
echo "1) Terminal 1 (Backend):"
echo "   cd backend && ./mvnw spring-boot:run"
echo ""
echo "2) Terminal 2 (Frontend):"
echo "   cd client && npm run dev"
echo "=========================================="
echo ""
echo "Opening app in dev mode..."

# Trap CTRL+C to cleanly kill background processes
trap 'kill $(jobs -p) 2>/dev/null' EXIT

# Start backend
(cd backend && ./mvnw spring-boot:run) &
BACKEND_PID=$!

# Start frontend
(cd client && npm run dev) &
FRONTEND_PID=$!

wait
