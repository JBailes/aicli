---
name: Check PR status before pushing
description: Before pushing to an existing PR branch, verify the PR is not already merged - run gh pr view EVERY time, no exceptions
type: feedback
---

Before pushing commits to an existing branch, ALWAYS run `gh pr view <branch>` first to confirm the PR is still open. If it is merged, stop immediately. Create a new branch from current main and open a new PR instead.

**Why:** This has happened multiple times (PR #963, PR #985). Pushing to a merged PR branch corrupts git history and bypasses review. The rule must be followed without exception, even when the push is a follow-up fix to the same feature.

**How to apply:** Every single push to an existing branch requires a prior `gh pr view <branch>` check. No exceptions, even for small follow-up commits. If merged, new branch + new PR.
