#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_tutao__tutanota-09c2776c0fce3db5c6e18da92b5a45dce9f013aa-vbc0d9ba8f0071fbe982809910959a6ff8884dbbf"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_tutao__tutanota-09c2776c0fce3db5c6e18da92b5a45dce9f013aa-vbc0d9ba8f0071fbe982809910959a6ff8884dbbf"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: tutanota-09c2776c0fce3db5c6e18da92b5a45dce9f013aa-vbc0d9ba8f0071fbe982809910959a6ff8884dbbf)..."
git push origin tutanota-09c2776c0fce3db5c6e18da92b5a45dce9f013aa-vbc0d9ba8f0071fbe982809910959a6ff8884dbbf

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: tutanota-09c2776c0fce3db5c6e18da92b5a45dce9f013aa-vbc0d9ba8f0071fbe982809910959a6ff8884dbbf"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
