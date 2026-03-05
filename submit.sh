#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_NodeBB__NodeBB-bd80d36e0dcf78cd4360791a82966078b3a07712-v4fbcfae8b15e4ce5d132c408bca69ebb9cf146ed"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_NodeBB__NodeBB-bd80d36e0dcf78cd4360791a82966078b3a07712-v4fbcfae8b15e4ce5d132c408bca69ebb9cf146ed"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: NodeBB-bd80d36e0dcf78cd4360791a82966078b3a07712-v4fbcfae8b15e4ce5d132c408bca69ebb9cf146ed)..."
git push origin NodeBB-bd80d36e0dcf78cd4360791a82966078b3a07712-v4fbcfae8b15e4ce5d132c408bca69ebb9cf146ed

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: NodeBB-bd80d36e0dcf78cd4360791a82966078b3a07712-v4fbcfae8b15e4ce5d132c408bca69ebb9cf146ed"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
