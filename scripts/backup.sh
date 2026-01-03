#!/bin/bash
# Manual backup trigger script
# Run this at end of coding sessions (when AI gives green light)

set -e  # Exit on error

echo "🔄 Starting backup process..."

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

# 1. Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  Warning: You have uncommitted changes."
    echo "   Current status:"
    git status --short
    echo ""
    read -p "   Do you want to commit these changes? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add -A
        read -p "   Enter commit message: " COMMIT_MSG
        git commit -m "${COMMIT_MSG:-Backup commit}"
        echo "✅ Changes committed"
    else
        echo "❌ Backup cancelled - please commit or stash changes first"
        exit 1
    fi
fi

# 2. Push to GitHub (Layer 1 backup)
echo "📤 Pushing to GitHub (Layer 1 backup)..."
if git push origin "$CURRENT_BRANCH"; then
    echo "✅ Successfully pushed to GitHub"
else
    echo "❌ Failed to push to GitHub"
    exit 1
fi

# 3. Show status
echo ""
echo "📊 Backup Summary:"
echo "   Branch: $CURRENT_BRANCH"
echo "   Remote: $(git remote get-url origin 2>/dev/null || echo 'Not configured')"
echo ""
echo "✅ Backup complete!"
echo ""
echo "📦 Next step: Manually sync Dropbox folder (Layer 2 backup)"
echo "   (Dropbox sync disabled during agent mode to avoid conflicts)"

