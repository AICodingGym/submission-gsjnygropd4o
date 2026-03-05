#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_gravitational__teleport-e6681abe6a7113cfd2da507f05581b7bdf398540-v626ec2a48416b10a88641359a169d99e935ff037"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_gravitational__teleport-e6681abe6a7113cfd2da507f05581b7bdf398540-v626ec2a48416b10a88641359a169d99e935ff037"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: teleport-e6681abe6a7113cfd2da507f05581b7bdf398540-v626ec2a48416b10a88641359a169d99e935ff037)..."
git push origin teleport-e6681abe6a7113cfd2da507f05581b7bdf398540-v626ec2a48416b10a88641359a169d99e935ff037

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: teleport-e6681abe6a7113cfd2da507f05581b7bdf398540-v626ec2a48416b10a88641359a169d99e935ff037"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
