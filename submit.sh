#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_ansible__ansible-415e08c2970757472314e515cb63a51ad825c45e-v7eee2454f617569fd6889f2211f75bc02a35f9f8"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_ansible__ansible-415e08c2970757472314e515cb63a51ad825c45e-v7eee2454f617569fd6889f2211f75bc02a35f9f8"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: ansible-415e08c2970757472314e515cb63a51ad825c45e-v7eee2454f617569fd6889f2211f75bc02a35f9f8)..."
git push origin ansible-415e08c2970757472314e515cb63a51ad825c45e-v7eee2454f617569fd6889f2211f75bc02a35f9f8

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: ansible-415e08c2970757472314e515cb63a51ad825c45e-v7eee2454f617569fd6889f2211f75bc02a35f9f8"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
