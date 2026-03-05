#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_tutao__tutanota-b4934a0f3c34d9d7649e944b183137e8fad3e859-vbc0d9ba8f0071fbe982809910959a6ff8884dbbf"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_tutao__tutanota-b4934a0f3c34d9d7649e944b183137e8fad3e859-vbc0d9ba8f0071fbe982809910959a6ff8884dbbf"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: tutanota-b4934a0f3c34d9d7649e944b183137e8fad3e859-vbc0d9ba8f0071fbe982809910959a6ff8884dbbf)..."
git push origin tutanota-b4934a0f3c34d9d7649e944b183137e8fad3e859-vbc0d9ba8f0071fbe982809910959a6ff8884dbbf

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: tutanota-b4934a0f3c34d9d7649e944b183137e8fad3e859-vbc0d9ba8f0071fbe982809910959a6ff8884dbbf"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
