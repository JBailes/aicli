---
name: shelp definition
description: What "shelp" means in the acktng codebase
type: project
---

`shelp` (shelp_entries in the DB) contains help entries for **skills and spells**, not staff help. It is distinct from `help` (help_entries), which covers general player commands and game concepts.

**Why:** User corrected an incorrect assumption that shelp = staff help.
**How to apply:** Whenever referencing shelp in code, proposals, or documentation, describe it as skill/spell help, not staff help.
