#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_flipt-io__flipt-b2393f07d893024ab1e47ea2081e0289e1f9d56f"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_flipt-io__flipt-b2393f07d893024ab1e47ea2081e0289e1f9d56f"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: flipt-b2393f07d893024ab1e47ea2081e0289e1f9d56f)..."
git push origin flipt-b2393f07d893024ab1e47ea2081e0289e1f9d56f

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: flipt-b2393f07d893024ab1e47ea2081e0289e1f9d56f"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
