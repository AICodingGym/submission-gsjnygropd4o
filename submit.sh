#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_NodeBB__NodeBB-4327a09d76f10a79109da9d91c22120428d3bdb9-vnan"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_NodeBB__NodeBB-4327a09d76f10a79109da9d91c22120428d3bdb9-vnan"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: NodeBB-4327a09d76f10a79109da9d91c22120428d3bdb9-vnan)..."
git push origin NodeBB-4327a09d76f10a79109da9d91c22120428d3bdb9-vnan

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: NodeBB-4327a09d76f10a79109da9d91c22120428d3bdb9-vnan"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
