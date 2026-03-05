#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_protonmail__webclients-d8ff92b414775565f496b830c9eb6cc5fa9620e6"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_protonmail__webclients-d8ff92b414775565f496b830c9eb6cc5fa9620e6"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: webclients-d8ff92b414775565f496b830c9eb6cc5fa9620e6)..."
git push origin webclients-d8ff92b414775565f496b830c9eb6cc5fa9620e6

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: webclients-d8ff92b414775565f496b830c9eb6cc5fa9620e6"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
