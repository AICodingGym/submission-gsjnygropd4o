#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_ansible__ansible-40ade1f84b8bb10a63576b0ac320c13f57c87d34-v6382ea168a93d80a64aab1fbd8c4f02dc5ada5bf"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_ansible__ansible-40ade1f84b8bb10a63576b0ac320c13f57c87d34-v6382ea168a93d80a64aab1fbd8c4f02dc5ada5bf"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: ansible-40ade1f84b8bb10a63576b0ac320c13f57c87d34-v6382ea168a93d80a64aab1fbd8c4f02dc5ada5bf)..."
git push origin ansible-40ade1f84b8bb10a63576b0ac320c13f57c87d34-v6382ea168a93d80a64aab1fbd8c4f02dc5ada5bf

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: ansible-40ade1f84b8bb10a63576b0ac320c13f57c87d34-v6382ea168a93d80a64aab1fbd8c4f02dc5ada5bf"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
