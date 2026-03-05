#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_flipt-io__flipt-9d25c18b79bc7829a6fb08ec9e8793d5d17e2868"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_flipt-io__flipt-9d25c18b79bc7829a6fb08ec9e8793d5d17e2868"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: flipt-9d25c18b79bc7829a6fb08ec9e8793d5d17e2868)..."
git push origin flipt-9d25c18b79bc7829a6fb08ec9e8793d5d17e2868

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: flipt-9d25c18b79bc7829a6fb08ec9e8793d5d17e2868"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
