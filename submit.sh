#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_NodeBB__NodeBB-397835a05a8e2897324e566b41c5e616e172b4af-v89631a1cdb318276acb48860c5d78077211397c6"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_NodeBB__NodeBB-397835a05a8e2897324e566b41c5e616e172b4af-v89631a1cdb318276acb48860c5d78077211397c6"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: NodeBB-397835a05a8e2897324e566b41c5e616e172b4af-v89631a1cdb318276acb48860c5d78077211397c6)..."
git push origin NodeBB-397835a05a8e2897324e566b41c5e616e172b4af-v89631a1cdb318276acb48860c5d78077211397c6

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: NodeBB-397835a05a8e2897324e566b41c5e616e172b4af-v89631a1cdb318276acb48860c5d78077211397c6"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
