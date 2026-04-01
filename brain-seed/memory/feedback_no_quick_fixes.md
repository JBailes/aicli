---
name: No quick fixes on live hosts
description: Never suggest manual commands or workarounds on live hosts; all changes must go through PR cycle
type: feedback
---

Never suggest quick fixes, manual commands, or workarounds to apply directly on live hosts. All changes must go through the full cycle: push to a branch, create a PR, merge, then pull and deploy from the merged code.

**Why:** The user wants a disciplined deployment workflow. Ad-hoc commands on live hosts bypass review, are not reproducible, and can diverge from the source of truth in git.

**How to apply:** When encountering a bug or issue on a live host, always fix it in the code/scripts, push a PR, and let the user merge and redeploy. Do not suggest `pct exec`, `ssh`, or any direct host commands as a workaround.
