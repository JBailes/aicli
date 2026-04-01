---
name: TEXT[] arrays for flags
description: Always use TEXT[] arrays for flags in database schemas, never bitvectors or integer bitmasks
type: feedback
---

Always use TEXT[] arrays for flags in database schemas. Never use bitvectors or integer bitmasks.

**Why:** Readability and queryability are prioritized over storage efficiency. TEXT[] arrays are human-readable and self-documenting.

**How to apply:** Any time a schema needs flag fields (room flags, object flags, NPC flags, exit flags, etc.), use `TEXT[] NOT NULL DEFAULT '{}'`. Do not suggest converting to bitvectors, even for in-memory performance.
