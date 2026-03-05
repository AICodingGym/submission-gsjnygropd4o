#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_future-architect__vuls-d576b6c6c15e56c47cc3e26f5878867677d4a9ea"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_future-architect__vuls-d576b6c6c15e56c47cc3e26f5878867677d4a9ea"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: vuls-d576b6c6c15e56c47cc3e26f5878867677d4a9ea)..."
git push origin vuls-d576b6c6c15e56c47cc3e26f5878867677d4a9ea

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: vuls-d576b6c6c15e56c47cc3e26f5878867677d4a9ea"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
