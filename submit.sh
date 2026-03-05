#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_NodeBB__NodeBB-1ea9481af6125ffd6da0592ed439aa62af0bca11-vd59a5728dfc977f44533186ace531248c2917516"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_NodeBB__NodeBB-1ea9481af6125ffd6da0592ed439aa62af0bca11-vd59a5728dfc977f44533186ace531248c2917516"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: NodeBB-1ea9481af6125ffd6da0592ed439aa62af0bca11-vd59a5728dfc977f44533186ace531248c2917516)..."
git push origin NodeBB-1ea9481af6125ffd6da0592ed439aa62af0bca11-vd59a5728dfc977f44533186ace531248c2917516

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: NodeBB-1ea9481af6125ffd6da0592ed439aa62af0bca11-vd59a5728dfc977f44533186ace531248c2917516"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
