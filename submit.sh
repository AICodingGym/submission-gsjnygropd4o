#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_ansible__ansible-164881d871964aa64e0f911d03ae270acbad253c-v390e508d27db7a51eece36bb6d9698b63a5b638a"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_ansible__ansible-164881d871964aa64e0f911d03ae270acbad253c-v390e508d27db7a51eece36bb6d9698b63a5b638a"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: ansible-164881d871964aa64e0f911d03ae270acbad253c-v390e508d27db7a51eece36bb6d9698b63a5b638a)..."
git push origin ansible-164881d871964aa64e0f911d03ae270acbad253c-v390e508d27db7a51eece36bb6d9698b63a5b638a

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: ansible-164881d871964aa64e0f911d03ae270acbad253c-v390e508d27db7a51eece36bb6d9698b63a5b638a"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
