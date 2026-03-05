#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Pro Solution Submission"
echo "   Instance: instance_qutebrowser__qutebrowser-9ed748effa8f3bcd804612d9291da017b514e12f-v363c8a7e5ccdf6968fc7ab84a2053ac78036691d"
echo "============================================="

if git diff-index --quiet HEAD --; then
    echo "No changes detected. All changes are already committed."
else
    echo "Adding all changes..."
    git add -A
    echo "Enter commit message (or press Enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for instance_qutebrowser__qutebrowser-9ed748effa8f3bcd804612d9291da017b514e12f-v363c8a7e5ccdf6968fc7ab84a2053ac78036691d"
    fi
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "Pushing to remote (branch: qutebrowser-9ed748effa8f3bcd804612d9291da017b514e12f-v363c8a7e5ccdf6968fc7ab84a2053ac78036691d)..."
git push origin qutebrowser-9ed748effa8f3bcd804612d9291da017b514e12f-v363c8a7e5ccdf6968fc7ab84a2053ac78036691d

COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
echo ""
echo "Code pushed! Check test results:"
echo "  $REPO_URL/actions"
echo "  Branch: qutebrowser-9ed748effa8f3bcd804612d9291da017b514e12f-v363c8a7e5ccdf6968fc7ab84a2053ac78036691d"
echo "  Commit: $COMMIT_HASH"
echo ""
echo "Run ./submit.sh again after making more changes."
