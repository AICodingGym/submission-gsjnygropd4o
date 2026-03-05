#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_qutebrowser__qutebrowser-f7753550f2c1dcb2348e4779fd5287166754827e-v059c6fdc75567943479b23ebca7c07b5e9a7f34c"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_qutebrowser__qutebrowser-f7753550f2c1dcb2348e4779fd5287166754827e-v059c6fdc75567943479b23ebca7c07b5e9a7f34c"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: qutebrowser-f7753550f2c1dcb2348e4779fd5287166754827e-v059c6fdc75567943479b23ebca7c07b5e9a7f34c)..."
git push origin qutebrowser-f7753550f2c1dcb2348e4779fd5287166754827e-v059c6fdc75567943479b23ebca7c07b5e9a7f34c

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: qutebrowser-f7753550f2c1dcb2348e4779fd5287166754827e-v059c6fdc75567943479b23ebca7c07b5e9a7f34c"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
