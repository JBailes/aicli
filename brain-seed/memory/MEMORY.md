# Project Memory

## Workflow
- [Model mode](feedback_model_mode.md) -- Opus for proposals/plans, Sonnet for implementation
- [Check PR before pushing](feedback_pr_already_merged.md) -- verify PR is not merged before pushing; create new branch/PR if it is

## Output Style
- [No em dashes](feedback_no_emdashes.md) -- never use em dashes in any output

## Schema Design
- [TEXT[] for flags](feedback_text_arrays_for_flags.md) -- always TEXT[] arrays, never bitvectors or bitmasks

## Infrastructure
- [Health checks from service](feedback_health_checks.md) -- health checks must come from the service itself, not the host
- [No quick fixes on live hosts](feedback_no_quick_fixes.md) -- all changes through PR cycle, never manual commands

## User Preferences
- Do NOT add "Co-Authored-By" or "Generated with Claude Code" lines to any commits or PRs
- NEVER push directly to main on any repo -- always create a branch and PR
- ALWAYS create a new branch and PR for new changes -- never push to an already-merged branch or try to add commits to a merged PR
- All tests must be run locally, never remotely
- Sub-projects (acktng, web, tngdb, tng-ai) are independent git repos ignored by parent aicli git
- acktng remote should use SSH (git@github.com:), not HTTPS
- Git committer: JBailes <jbailes@gmail.com>

## acktng Domain Knowledge
- [shelp definition](project_shelp_definition.md) -- shelp = skill/spell help entries, NOT staff help

## WOL Architecture
- [wol vs wol-realm](project_wol_vs_realm.md) -- wol is stateless connection interface, wol-realm is game engine; gateway is NAT-only

## wol-docs
- [lore and plans location](reference_acktng_lore.md) -- game lore in `wol-docs/lore/`, area plans in `wol-docs/plans/`
- [proposal structure](reference_wol_docs_proposals.md) -- proposals in `wol-docs/proposals/{pending,active,complete,rejected}/`; acktng-only stays in acktng

## Environment
- Debian 13 (trixie)
- Python 3.13 (crypt module removed -- use ctypes libcrypt)
- CI uses clang-format 18 (Ubuntu 24.04); local may differ -- only format changed files
- PostgreSQL 17 installed and running locally for integration tests

## Projects
- [TheBrain Plugin](projects/thebrain.md) -- plugin setup state, signals config, scan results

## References
- [db.conf](reference_db_conf.md) -- local dev DB credentials at `credentials/db.conf` (gitignored), points to remote PostgreSQL at 192.168.1.112:5432
