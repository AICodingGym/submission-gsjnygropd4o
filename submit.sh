#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_future-architect__vuls-e049df50fa1eecdccc5348e27845b5c783ed7c76-v73dc95f6b90883d8a87e01e5e9bb6d3cc32add6d"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_future-architect__vuls-e049df50fa1eecdccc5348e27845b5c783ed7c76-v73dc95f6b90883d8a87e01e5e9bb6d3cc32add6d"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: vuls-e049df50fa1eecdccc5348e27845b5c783ed7c76-v73dc95f6b90883d8a87e01e5e9bb6d3cc32add6d)..."
git push origin vuls-e049df50fa1eecdccc5348e27845b5c783ed7c76-v73dc95f6b90883d8a87e01e5e9bb6d3cc32add6d

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: vuls-e049df50fa1eecdccc5348e27845b5c783ed7c76-v73dc95f6b90883d8a87e01e5e9bb6d3cc32add6d"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
