#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_future-architect__vuls-e1df74cbc1a1d1889428b3333a3b2405c4651993"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_future-architect__vuls-e1df74cbc1a1d1889428b3333a3b2405c4651993"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: vuls-e1df74cbc1a1d1889428b3333a3b2405c4651993)..."
git push origin vuls-e1df74cbc1a1d1889428b3333a3b2405c4651993

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: vuls-e1df74cbc1a1d1889428b3333a3b2405c4651993"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
