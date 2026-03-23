#!/bin/bash
# Pull latest changes for all sub-project repos.
# Skips repos that don't exist or aren't on a branch.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

REPOS=(acktng web tngdb tng-ai)

for dir in "${REPOS[@]}"; do
    target="$SCRIPT_DIR/$dir"
    if [ ! -d "$target/.git" ]; then
        echo "Skipping $dir (not cloned)"
        continue
    fi

    echo "Pulling $dir..."
    git -C "$target" pull --ff-only 2>&1 | sed 's/^/  /'
done

echo "All repos up to date."
