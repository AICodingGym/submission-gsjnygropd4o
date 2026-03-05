#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_navidrome__navidrome-d21932bd1b2379b0ebca2d19e5d8bae91040268a"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_navidrome__navidrome-d21932bd1b2379b0ebca2d19e5d8bae91040268a"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: navidrome-d21932bd1b2379b0ebca2d19e5d8bae91040268a)..."
git push origin navidrome-d21932bd1b2379b0ebca2d19e5d8bae91040268a

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: navidrome-d21932bd1b2379b0ebca2d19e5d8bae91040268a"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
