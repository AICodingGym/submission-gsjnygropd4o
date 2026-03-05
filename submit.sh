#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_element-hq__element-web-404c412bcb694f04ba0c4d5479541203d701bca0-vnan"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_element-hq__element-web-404c412bcb694f04ba0c4d5479541203d701bca0-vnan"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: element-web-404c412bcb694f04ba0c4d5479541203d701bca0-vnan)..."
git push origin element-web-404c412bcb694f04ba0c4d5479541203d701bca0-vnan

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: element-web-404c412bcb694f04ba0c4d5479541203d701bca0-vnan"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
