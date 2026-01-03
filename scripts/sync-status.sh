#!/bin/bash
# Check Git status and sync readiness

echo "📊 Git Status and Sync Readiness Check"
echo "========================================"
echo ""

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not a git repository"
    exit 1
fi

# Current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "📍 Current branch: $CURRENT_BRANCH"
echo ""

# Check for uncommitted changes
UNCOMMITTED=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
UNSTAGED=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')

if [ "$UNCOMMITTED" -gt 0 ] || [ "$UNSTAGED" -gt 0 ]; then
    echo "⚠️  Uncommitted changes:"
    git status --short
    echo ""
    echo "   Status: NOT READY for sync"
    echo "   Action: Commit or stash changes before syncing"
else
    echo "✅ No uncommitted changes"
fi

# Check for unpushed commits
REMOTE_BRANCH=$(git rev-parse --abbrev-ref --symbolic-full-name "$CURRENT_BRANCH@{upstream}" 2>/dev/null || echo "")
if [ -n "$REMOTE_BRANCH" ]; then
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$REMOTE_BRANCH" 2>/dev/null || echo "")
    BASE=$(git merge-base @ "$REMOTE_BRANCH" 2>/dev/null || echo "")
    
    if [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]; then
        AHEAD=$(git rev-list --count "$REMOTE_BRANCH"..@ 2>/dev/null || echo "0")
        BEHIND=$(git rev-list --count @.."$REMOTE_BRANCH" 2>/dev/null || echo "0")
        
        if [ "$AHEAD" -gt 0 ]; then
            echo "📤 Unpushed commits: $AHEAD"
            echo "   Status: READY to push (use scripts/backup.sh)"
        fi
        if [ "$BEHIND" -gt 0 ]; then
            echo "📥 Unpulled commits: $BEHIND"
            echo "   Action: Consider pulling first"
        fi
    else
        echo "✅ All commits pushed"
    fi
else
    echo "⚠️  No remote branch configured"
fi

# Remote status
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "Not configured")
echo ""
echo "🔗 Remote: $REMOTE_URL"

# Final status
echo ""
if [ "$UNCOMMITTED" -eq 0 ] && [ "$UNSTAGED" -eq 0 ]; then
    echo "✅ Status: READY for backup/sync"
    echo "   Run: ./scripts/backup.sh"
else
    echo "❌ Status: NOT READY - commit changes first"
fi

