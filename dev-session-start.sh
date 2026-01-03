#!/usr/bin/env bash
# dev-session-start.sh
# Educational script to understand Dev Containers workflow
# Run this to manually start a development session

set -e  # Exit on any error

# ANSI colors for output clarity
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Life Scheduler - Dev Session Start${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 0: Dropbox Sync Reminder
echo -e "${YELLOW}[0/5] Dropbox Sync Reminder...${NC}"
osascript -e 'display dialog "⏸️  PAUSE Dropbox Sync\n\nBefore starting development:\n1. Pause Dropbox sync for this folder\n2. This prevents file conflicts during agent mode\n\n(System utility coming soon)" buttons {"I'\''ve Paused Dropbox"} default button 1 with title "Life Scheduler Dev Session" with icon caution'
echo -e "${GREEN}✓ Dropbox sync reminder acknowledged${NC}"
echo ""

# Step 1: Check Git Repository Status
echo -e "${YELLOW}[1/5] Checking repository status...${NC}"
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not a git repository"
    exit 1
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
echo "📍 Current branch: $CURRENT_BRANCH"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "⚠️  Warning: You have uncommitted changes:"
    git status --short
    echo ""
else
    echo "✅ No uncommitted changes"
fi
echo ""

# Step 2: Auto Pull from GitHub (Layer 1 backup)
echo -e "${YELLOW}[2/5] Pulling latest from GitHub...${NC}"
if git pull origin "$CURRENT_BRANCH" 2>/dev/null; then
    echo -e "${GREEN}✓ Repository up to date${NC}"
else
    echo "⚠️  Could not pull (no remote or network issue)"
fi
echo ""

# Step 3: Check if .env exists
echo -e "${YELLOW}[3/5] Checking environment configuration...${NC}"
if [ ! -f .env ]; then
    echo "ERROR: .env file not found!"
    echo "Please copy .env.example to .env and configure it:"
    echo "  cp .env.example .env"
    exit 1
fi
echo -e "${GREEN}✓ .env file exists${NC}"
echo ""

# Step 4: Start Docker containers
echo -e "${YELLOW}[4/5] Starting Docker containers...${NC}"
echo "Command: docker compose up -d"
echo "What this does:"
echo "  - Starts PostgreSQL database container (db service)"
echo "  - Starts Flask application container (app service)"
echo "  - Runs in detached mode (-d = background)"
echo "  - Creates network for services to communicate"
echo ""
docker compose up -d
echo -e "${GREEN}✓ Containers running${NC}"
echo ""

# Step 5: Wait for services to be healthy
echo -e "${YELLOW}[5/5] Waiting for services to be healthy...${NC}"
echo "Checking health checks defined in docker-compose.yml..."
echo "(PostgreSQL must accept connections, Flask must respond to /health)"
echo ""

# Wait up to 60 seconds for containers to be healthy
TIMEOUT=60
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
    DB_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' life-scheduler-db 2>/dev/null || echo "starting")
    APP_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' life-scheduler-app 2>/dev/null || echo "starting")
    
    if [ "$DB_HEALTH" = "healthy" ] && [ "$APP_HEALTH" = "healthy" ]; then
        echo -e "${GREEN}✓ All services healthy${NC}"
        break
    fi
    
    echo "  db: $DB_HEALTH | app: $APP_HEALTH (${ELAPSED}s elapsed)"
    sleep 5
    ELAPSED=$((ELAPSED + 5))
done

if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "WARNING: Services did not become healthy within ${TIMEOUT}s"
    echo "Check logs with: docker compose logs"
fi
echo ""

# Final: Instructions for Cursor
echo -e "${YELLOW}Ready for development!${NC}"
echo ""
echo "Your containers are running. Now open your workspace in Cursor:"
echo ""
echo "  ${GREEN}cursor Life-Scheduler.code-workspace${NC}"
echo ""
echo "Cursor will detect .devcontainer/devcontainer.json and prompt:"
echo '  "Reopen in Container?"'
echo ""
echo "Click YES. Cursor will:"
echo "  1. Attach to the running 'app' container"
echo "  2. Open /app directory inside container"
echo "  3. Install extensions inside container"
echo "  4. Give you a terminal INSIDE the container"
echo "  5. Load your workspace settings"
echo ""
echo "From that terminal, all commands run in container environment:"
echo "  - pytest              (runs tests)"
echo "  - flask run           (starts dev server)"
echo "  - alembic upgrade head (applies migrations)"
echo "  - python --version    (shows container's Python 3.12)"
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}WHY THIS MATTERS (Environment Parity)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "When you code inside the container:"
echo "  ✓ Your Python = Production Python (same base image)"
echo "  ✓ Your packages = Production packages (same requirements.txt)"
echo "  ✓ Your PostgreSQL = Production PostgreSQL (same version)"
echo "  ✓ Zero 'works on my machine' issues"
echo ""
echo "The volume mount (.:/app in docker-compose.yml) means:"
echo "  - You edit files in Cursor (inside container)"
echo "  - Changes sync instantly to your Mac filesystem"
echo "  - Committed to Git from either side"
echo "  - Your workspace persists across sessions"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
echo ""
echo "To stop containers when done:"
echo "  docker compose down"