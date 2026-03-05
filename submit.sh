#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_qutebrowser__qutebrowser-7f9713b20f623fc40473b7167a082d6db0f0fd40-va0fd88aac89cde702ec1ba84877234da33adce8a"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_qutebrowser__qutebrowser-7f9713b20f623fc40473b7167a082d6db0f0fd40-va0fd88aac89cde702ec1ba84877234da33adce8a"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: qutebrowser-7f9713b20f623fc40473b7167a082d6db0f0fd40-va0fd88aac89cde702ec1ba84877234da33adce8a)..."
git push origin qutebrowser-7f9713b20f623fc40473b7167a082d6db0f0fd40-va0fd88aac89cde702ec1ba84877234da33adce8a

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: qutebrowser-7f9713b20f623fc40473b7167a082d6db0f0fd40-va0fd88aac89cde702ec1ba84877234da33adce8a"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
