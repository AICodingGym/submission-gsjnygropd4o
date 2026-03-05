#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_internetarchive__openlibrary-91efee627df01e32007abf2d6ebf73f9d9053076-vbee42ad1b72fb23c6a1c874868a720b370983ed2"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_internetarchive__openlibrary-91efee627df01e32007abf2d6ebf73f9d9053076-vbee42ad1b72fb23c6a1c874868a720b370983ed2"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: openlibrary-91efee627df01e32007abf2d6ebf73f9d9053076-vbee42ad1b72fb23c6a1c874868a720b370983ed2)..."
git push origin openlibrary-91efee627df01e32007abf2d6ebf73f9d9053076-vbee42ad1b72fb23c6a1c874868a720b370983ed2

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: openlibrary-91efee627df01e32007abf2d6ebf73f9d9053076-vbee42ad1b72fb23c6a1c874868a720b370983ed2"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
