#!/usr/bin/env bash

set -Eeuo pipefail

EXPECTED_BRANCH="dev"
REMOTE_NAME="origin"

fail() {
    echo "ERROR: $1" >&2
    exit 1
}

echo "=================================================="
echo "Pipeline360 - GitHub Update"
echo "=================================================="

# Verify that the command is executed inside a Git repository.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || fail "Run this script from inside the Pipeline360 repository."

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

echo "Repository: $REPO_ROOT"

# Verify the configured GitHub remote.
REMOTE_URL="$(git remote get-url "$REMOTE_NAME" 2>/dev/null)" \
    || fail "Git remote '$REMOTE_NAME' was not found."

echo "Remote:     $REMOTE_URL"

# Always verify the current branch before making Git changes.
CURRENT_BRANCH="$(git branch --show-current)"

if [[ -z "$CURRENT_BRANCH" ]]; then
    fail "Detached HEAD detected. Switch to the dev branch before continuing."
fi

echo "Branch:     $CURRENT_BRANCH"

if [[ "$CURRENT_BRANCH" != "$EXPECTED_BRANCH" ]]; then
    fail "Current branch is '$CURRENT_BRANCH'. This project must be updated from '$EXPECTED_BRANCH'."
fi

echo
echo "[1/6] Fetching the latest remote information..."
git fetch "$REMOTE_NAME" --prune

# Refuse to pull over uncommitted work. This avoids accidental conflicts.
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo
    echo "Local changes detected:"
    git status --short
else
    echo
    echo "[2/6] Updating the local dev branch..."
    git pull --ff-only "$REMOTE_NAME" "$EXPECTED_BRANCH"
fi

echo
echo "[3/6] Current changes:"
git status --short

if [[ -z "$(git status --porcelain)" ]]; then
    echo "Nothing to commit. The repository is already up to date."
    exit 0
fi

echo
read -r -p "Stage all displayed changes with 'git add -A'? [y/N]: " STAGE_CONFIRM

if [[ ! "$STAGE_CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Cancelled. No files were staged."
    exit 0
fi

echo
echo "[4/6] Staging changes..."
git add -A

echo
echo "Staged changes:"
git diff --cached --stat

echo
read -r -p "Enter the Git commit message: " COMMIT_MESSAGE

if [[ -z "${COMMIT_MESSAGE// }" ]]; then
    fail "Commit message cannot be empty."
fi

echo
echo "[5/6] Creating the commit..."
git commit -m "$COMMIT_MESSAGE"

echo
echo "[6/6] Pushing the dev branch to GitHub..."
git push "$REMOTE_NAME" "$EXPECTED_BRANCH"

echo
echo "=================================================="
echo "GitHub update completed successfully."
echo "Branch pushed: $EXPECTED_BRANCH"
echo "Next: Check GitHub Actions and the Pull Request to main."
echo "=================================================="