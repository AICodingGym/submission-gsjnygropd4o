#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_gravitational__teleport-b8fbb2d1e90ffcde88ed5fe9920015c1be075788-vee9b09fb20c43af7e520f57e9239bbcf46b7113d"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_gravitational__teleport-b8fbb2d1e90ffcde88ed5fe9920015c1be075788-vee9b09fb20c43af7e520f57e9239bbcf46b7113d"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: teleport-b8fbb2d1e90ffcde88ed5fe9920015c1be075788-vee9b09fb20c43af7e520f57e9239bbcf46b7113d)..."
git push origin teleport-b8fbb2d1e90ffcde88ed5fe9920015c1be075788-vee9b09fb20c43af7e520f57e9239bbcf46b7113d

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: teleport-b8fbb2d1e90ffcde88ed5fe9920015c1be075788-vee9b09fb20c43af7e520f57e9239bbcf46b7113d"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
