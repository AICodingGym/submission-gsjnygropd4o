#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_NodeBB__NodeBB-cfc237c2b79d8c731bbfc6cadf977ed530bfd57a-v0495b863a912fbff5749c67e860612b91825407c"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_NodeBB__NodeBB-cfc237c2b79d8c731bbfc6cadf977ed530bfd57a-v0495b863a912fbff5749c67e860612b91825407c"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: NodeBB-cfc237c2b79d8c731bbfc6cadf977ed530bfd57a-v0495b863a912fbff5749c67e860612b91825407c)..."
git push origin NodeBB-cfc237c2b79d8c731bbfc6cadf977ed530bfd57a-v0495b863a912fbff5749c67e860612b91825407c

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: NodeBB-cfc237c2b79d8c731bbfc6cadf977ed530bfd57a-v0495b863a912fbff5749c67e860612b91825407c"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
