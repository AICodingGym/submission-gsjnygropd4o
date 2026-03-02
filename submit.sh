#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Solution Submission"
echo "   Instance: pytest-dev__pytest-10081"
echo "============================================="
echo ""

# Check if there are any changes to commit
if git diff-index --quiet HEAD --; then
    echo "ℹ️  No changes detected in working directory."
    echo "   All changes are already committed."
    echo ""
else
    echo "📝 Adding all changes..."
    git add -A
    
    # Prompt for commit message
    echo ""
    echo "Enter commit message (or press Enter for default):" 
    read -r COMMIT_MSG
    
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for pytest-dev__pytest-10081"
    fi
    
    echo ""
    echo "💾 Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "📤 Pushing to remote repository (branch: pytest-10081)..."
git push origin pytest-10081

echo ""
echo "✅ Code pushed successfully!"
echo ""

# Get the current commit hash
COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_MSG=$(git log -1 --pretty=%B | tr -d '')
REPO_URL=$(git remote get-url origin 2>/dev/null || git remote get-url test-repo 2>/dev/null || echo "unknown")

echo "============================================="
echo "✅ Code pushed!"
echo "============================================="
echo ""
echo "📋 Check test results in GitHub Actions:"
echo "   $REPO_URL/actions"
echo ""
echo "   Branch: pytest-10081"
echo "   Commit: $COMMIT_HASH"

echo ""
echo "💡 Tip: You can run ./submit.sh again after making more changes."
echo ""
