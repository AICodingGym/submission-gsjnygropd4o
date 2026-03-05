#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_NodeBB__NodeBB-97c8569a798075c50e93e585ac741ab55cb7c28b-vf2cf3cbd463b7ad942381f1c6d077626485a1e9e"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_NodeBB__NodeBB-97c8569a798075c50e93e585ac741ab55cb7c28b-vf2cf3cbd463b7ad942381f1c6d077626485a1e9e"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: NodeBB-97c8569a798075c50e93e585ac741ab55cb7c28b-vf2cf3cbd463b7ad942381f1c6d077626485a1e9e)..."
git push origin NodeBB-97c8569a798075c50e93e585ac741ab55cb7c28b-vf2cf3cbd463b7ad942381f1c6d077626485a1e9e

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: NodeBB-97c8569a798075c50e93e585ac741ab55cb7c28b-vf2cf3cbd463b7ad942381f1c6d077626485a1e9e"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
