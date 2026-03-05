#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_NodeBB__NodeBB-84dfda59e6a0e8a77240f939a7cb8757e6eaf945-v2c59007b1005cd5cd14cbb523ca5229db1fd2dd8"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_NodeBB__NodeBB-84dfda59e6a0e8a77240f939a7cb8757e6eaf945-v2c59007b1005cd5cd14cbb523ca5229db1fd2dd8"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: NodeBB-84dfda59e6a0e8a77240f939a7cb8757e6eaf945-v2c59007b1005cd5cd14cbb523ca5229db1fd2dd8)..."
git push origin NodeBB-84dfda59e6a0e8a77240f939a7cb8757e6eaf945-v2c59007b1005cd5cd14cbb523ca5229db1fd2dd8

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: NodeBB-84dfda59e6a0e8a77240f939a7cb8757e6eaf945-v2c59007b1005cd5cd14cbb523ca5229db1fd2dd8"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
