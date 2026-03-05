#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_future-architect__vuls-e4728e388120b311c4ed469e4f942e0347a2689b-v264a82e2f4818e30f5a25e4da53b27ba119f62b5"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_future-architect__vuls-e4728e388120b311c4ed469e4f942e0347a2689b-v264a82e2f4818e30f5a25e4da53b27ba119f62b5"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: vuls-e4728e388120b311c4ed469e4f942e0347a2689b-v264a82e2f4818e30f5a25e4da53b27ba119f62b5)..."
git push origin vuls-e4728e388120b311c4ed469e4f942e0347a2689b-v264a82e2f4818e30f5a25e4da53b27ba119f62b5

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: vuls-e4728e388120b311c4ed469e4f942e0347a2689b-v264a82e2f4818e30f5a25e4da53b27ba119f62b5"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
