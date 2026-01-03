#!/usr/bin/env bash
# dev-session-stop.sh
# Stop development containers cleanly

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Life Scheduler - Dev Session Stop${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}Stopping containers...${NC}"
echo "Command: docker compose down"
echo ""
echo "What this does:"
echo "  - Stops app and db containers gracefully"
echo "  - Removes container instances"
echo "  - Removes the network bridge"
echo "  - Database data persists in 'postgres_data' volume"
echo ""

docker compose down

echo -e "${GREEN}✓ Containers stopped${NC}"
echo ""

# Step 2: Check Git Repository Status
echo -e "${YELLOW}Checking repository status...${NC}"
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "⚠️  Not a git repository - skipping backup"
else
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
    
    # Check for uncommitted changes
    UNCOMMITTED=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    UNSTAGED=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$UNCOMMITTED" -gt 0 ] || [ "$UNSTAGED" -gt 0 ]; then
        echo "⚠️  Uncommitted changes detected:"
        git status --short
        echo ""
        
        # Auto-commit if there are changes
        echo "📝 Auto-committing changes..."
        git add -A
        
        # Generate commit message with timestamp
        COMMIT_MSG="dev: end of session $(date '+%Y-%m-%d %H:%M')"
        
        if git commit -m "$COMMIT_MSG" 2>/dev/null; then
            echo -e "${GREEN}✓ Changes committed${NC}"
            
            # Push to GitHub (Layer 1 backup)
            echo "📤 Pushing to GitHub (Layer 1 backup)..."
            if git push origin "$CURRENT_BRANCH" 2>/dev/null; then
                echo -e "${GREEN}✓ Successfully pushed to GitHub${NC}"
            else
                echo "⚠️  Failed to push to GitHub (check network)"
            fi
        else
            echo "⚠️  Nothing to commit"
        fi
    else
        echo "✅ No changes to commit"
        
        # Still try to push any unpushed commits
        REMOTE_BRANCH=$(git rev-parse --abbrev-ref --symbolic-full-name "$CURRENT_BRANCH@{upstream}" 2>/dev/null || echo "")
        if [ -n "$REMOTE_BRANCH" ]; then
            LOCAL=$(git rev-parse @ 2>/dev/null || echo "")
            REMOTE=$(git rev-parse "$REMOTE_BRANCH" 2>/dev/null || echo "")
            if [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]; then
                AHEAD=$(git rev-list --count "$REMOTE_BRANCH"..@ 2>/dev/null || echo "0")
                if [ "$AHEAD" -gt 0 ]; then
                    echo "📤 Pushing unpushed commits..."
                    if git push origin "$CURRENT_BRANCH" 2>/dev/null; then
                        echo -e "${GREEN}✓ Successfully pushed to GitHub${NC}"
                    else
                        echo "⚠️  Failed to push to GitHub (check network)"
                    fi
                fi
            fi
        fi
    fi
fi
echo ""

# Step 3: Dropbox Sync Reminder
echo -e "${YELLOW}Dropbox Sync Reminder...${NC}"
osascript -e 'display dialog "▶️  RESUME Dropbox Sync\n\nDevelopment session complete:\n1. Resume Dropbox sync for this folder\n2. Layer 1 backup (GitHub) complete\n3. Layer 2 backup (Dropbox) will sync\n\n(System utility coming soon)" buttons {"I'\''ll Resume Dropbox"} default button 1 with title "Life Scheduler Dev Session" with icon note'
echo -e "${GREEN}✓ Dropbox sync reminder acknowledged${NC}"
echo ""

echo "Database data preserved. To restart:"
echo "  ./dev-session-start.sh"
echo ""

