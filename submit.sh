#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_ansible__ansible-bec27fb4c0a40c5f8bbcf26a475704227d65ee73-v30a923fb5c164d6cd18280c02422f75e611e8fb2"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_ansible__ansible-bec27fb4c0a40c5f8bbcf26a475704227d65ee73-v30a923fb5c164d6cd18280c02422f75e611e8fb2"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: ansible-bec27fb4c0a40c5f8bbcf26a475704227d65ee73-v30a923fb5c164d6cd18280c02422f75e611e8fb2)..."
git push origin ansible-bec27fb4c0a40c5f8bbcf26a475704227d65ee73-v30a923fb5c164d6cd18280c02422f75e611e8fb2

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: ansible-bec27fb4c0a40c5f8bbcf26a475704227d65ee73-v30a923fb5c164d6cd18280c02422f75e611e8fb2"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
