# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository is the development environment for the ACKmud ecosystem. It contains multiple sub-projects as independent git repositories, each ignored by this parent repo's git.

## Sub-Projects

### WOL (active project)

Repos with `wol` in the name are part of the WOL project. Repos with `tng` or `ack` in the name are legacy and NOT part of WOL.

- **`wol/`** -- Stateless connection interface (C#/.NET). Handles telnet, TLS telnet, WS, and WSS protocols on port 6969. Passes game traffic between clients and the realm. Calls API services directly on the private network. Designed for horizontal autoscaling.
- **`wol-realm/`** -- Game engine (C#/.NET). Runs the MUD world simulation (rooms, NPCs, combat, ticks, game logic). Internal-only service on the private network.
- **`wol-accounts/`** -- Account authentication and identity API (C#/.NET/Npgsql). Manages accounts, sessions, and login. Private network service.
- **`wol-world/`** -- World prototype data API (C#/.NET/Npgsql). Manages areas, rooms, exits, object prototypes, NPC prototypes, resets, shops, loot, and scripts. Private network service.
- **`wol-client/`** -- Game client (Dart/Flutter). Login and connect flow over WebSocket.
- **`wol-docs/`** -- Canonical documentation repository for the WOL ecosystem. Game lore lives in `wol-docs/lore/`. Design proposals (except acktng-only) live in `wol-docs/proposals/`.

### Web

- **`web-wol/`** -- WOL website for ackmud.com (C#/.NET Blazor WASM + ASP.NET Core host with /health). Served by Kestrel on wol-web (CT 209).
- **`web-tng/`** -- ACK Historical Archive website for aha.ackmud.com (C#/.NET Blazor WASM + ASP.NET Core API). Includes /who, /gsgp, /reference endpoints and /health check. Served by Kestrel on ack-web (CT 247).
- **`web-personal/`** -- Personal website for bailes.us (React + Vite SPA). Served by static file server on personal-web (CT 117).

### Infrastructure

- **`wolf/`** -- Utility scripts for Wolf (Proxmox VE helper tool) users.
- **`SimpleNAS/`** -- NAS management tooling.
- **`infrastructure/`** -- Homelab infrastructure configuration (includes ACK and WOL).

### Legacy (not part of WOL)

- **`acktng/`** -- Legacy MUD game server (C). Being replaced by WOL. See `acktng/CLAUDE.md` for build/test/architecture details.
- **`tngdb/`** -- Database API server (Python/FastAPI/asyncpg). Read-only HTTP API for game content. No tests currently.
- **`tng-ai/`** -- AI/NPC intelligence service (Python/FastAPI/Groq). API for AI-powered NPC responses.

## Environment Setup

This repo (aicli) is Claude's local development environment only. It does NOT bootstrap the game infrastructure. Game infrastructure bootstrap scripts live in `wol-docs/infrastructure/bootstrap/`.

Run `./setup.sh` to set up a complete development environment in one command. It:

1. Installs and upgrades all system dependencies via apt-get
2. Installs Claude Code CLI
3. Installs thebrain (Claude Code plugin)
4. Starts PostgreSQL (required for integration tests)
5. Clones all sub-project repos (skips repos the user lacks access to): wol, wol-realm, wol-accounts, wol-players, wol-world, wol-client, wol-docs, web-wol, web-tng, web-personal, acktng, tngdb, tng-ai, wolf, SimpleNAS, infrastructure
6. Builds and tests acktng (C build + unit/integration tests)
7. Installs .NET 9 SDK (for web-wol and web-tng)
8. Builds and tests web-tng (dotnet test)
9. Builds and tests web-wol (dotnet test)
10. Builds and tests web-personal (npm test)
11. Creates venv and runs tng-ai tests (pytest)
12. Creates venv and verifies tngdb imports

### System Dependencies (Debian/Ubuntu)

Installed automatically by `setup.sh`:

- `build-essential`, `libcrypt-dev`, `zlib1g-dev` -- C compiler, make, and required libraries (`-lcrypt`, `-lz`)
- `libssl-dev` -- OpenSSL for TLS/WSS support in the game server
- `pkg-config`, `libpq-dev` -- PostgreSQL client library (game server database backend)
- `postgresql`, `postgresql-client` -- Local PostgreSQL server (required for integration tests)
- `clang-format` -- Code formatting/lint checks
- `git`, `python3`, `python3-pip`, `python3-venv` -- Version control, Python runtime, and virtual environments
- `liblua5.4-dev` -- Lua 5.4 headers and library (acktng scripting engine)
- `nodejs`, `npm` -- Node.js runtime (thebrain plugin, web-personal)

## setup.sh Maintenance Policy

`setup.sh` is the single command that sets up the entire development environment. It MUST be kept up to date:

- **When a new dependency is added to any sub-project, add it to `setup.sh`.** This includes system packages (apt-get), language runtimes, build tools, and test dependencies.
- **`setup.sh` must remain idempotent.** Every section must be safe to re-run: check before installing, skip if already present, never duplicate work. Running `setup.sh` twice in a row must produce the same result as running it once.
- **All installed packages are upgraded on every run.** `apt-get upgrade` ensures no stale versions persist.

## Design Proposal Requirement

For any task that is not a bugfix, you MUST first deliver a design proposal describing the proposed changes — including the problem, approach, affected files/repos, and any trade-offs — and discuss it with the user. Do NOT begin implementation until the user has explicitly signed off on the proposal. No code changes, no file creation, no prototyping, and no database writes until approval is given.

Querying databases for information to research or write a proposal is permitted. Writing to any database (INSERT, UPDATE, DELETE, or schema changes) is implementation and requires an approved proposal first.

Bugfixes do NOT require a proposal and may be implemented directly.

**All proposals MUST be written to `wol-docs/proposals/`.** This is the canonical location for every proposal. Do not write proposals anywhere else (not in the repo root, not in `wol/`, not in `web/`, etc.).

- `wol-docs/proposals/pending/` — proposals awaiting discussion or approval
- `wol-docs/proposals/active/` — proposals currently being implemented
- `wol-docs/proposals/complete/` — proposals that have been fully implemented
- `wol-docs/proposals/rejected/` — proposals that were rejected

**Exception:** acktng-specific proposals (bugfixes or changes with no effect outside acktng) remain in `acktng/docs/proposals/`.

## aimee Integration

aimee (`aimee/`) is an AI coding assistant toolkit installed locally. Use it before falling back to raw tool calls:

### Memory-first lookup

Before searching the codebase with Grep or Glob, first check aimee's knowledge:

- `aimee memory search <terms>` -- searches learned facts, past context, and conversation history. Use this when looking for project knowledge, past decisions, or infrastructure details.
- `aimee index find <identifier>` -- finds code definitions and references by identifier name across all indexed projects. Use this when looking for a function, class, or variable.

If aimee returns relevant results, use them instead of searching. If not, fall back to Grep/Glob as usual.

### Delegation

Use `aimee delegate <role> "prompt"` to offload tasks to sub-agents when available. Roles:

- **deploy** -- remote operations (SSH, systemctl, deployment scripts)
- **validate** -- health checks, service verification
- **test** -- running test suites
- **diagnose** -- investigating failures, log analysis
- **execute** -- generic shell tasks

Add `--background` for long-running tasks, `--durable` to persist results in the database. Only delegate when sub-agents are configured (aimee will error otherwise).

## Output Style

Never use em dashes (—) in any output, including prose, comments, commit messages, and documentation. Use a comma, colon, parentheses, or rephrase instead.

## Commit Authorship

Do NOT add "Co-Authored-By", "Generated with Claude Code", or any other AI attribution lines to commits or PRs. The user is the sole author.

## Model Mode

Use **Opus** mode (`/model opus`) when writing plans and design proposals. Use **Sonnet** mode (`/model sonnet`) when implementing code.

## Deployment Policy

Never suggest quick fixes, manual commands, or workarounds to apply directly on live hosts. All changes must go through the full cycle: push to a branch, create a PR, merge, then pull and deploy from the merged code. No exceptions.

## Branch and PR Policy

**Before writing any code in a sub-project, pull the latest `main` first.** Run `git fetch origin && git checkout main && git pull origin main` in the target repo. This ensures you are working on the most current code and avoids conflicts with recently merged changes.

**NEVER push directly to main on any repository. All changes must go through a branch and pull request -- no exceptions.** This applies to all sub-projects (wol, acktng, web, tngdb, tng-ai) and this repo.

**Before EVERY `git push`, you MUST run `gh pr view <branch> --json state` to check whether a PR for that branch is already merged.** This applies even if you created the branch yourself earlier in the same session, even if you just pushed to it minutes ago, and even if you are confident it is not merged. No exceptions, no skipping. If the PR is merged, stop: do not push to that branch. Instead, create a new branch from `origin/main` (fetch first) and open a new PR. Pushing to a merged PR's branch reopens a closed PR and corrupts the review history.

**Before pushing to a PR or creating a PR, check for merge conflicts with `main` and fix them.** Run `git fetch origin` then `git merge origin/main` (or rebase) on your branch. Resolve any conflicts before pushing. Do not open or push to a PR that has merge conflicts.

## Testing

All tests (unit, integration, etc.) for all sub-projects must be run locally. Never run tests on remote systems or trigger remote CI — always validate locally before pushing.

### Running all tests

```sh
./setup.sh    # runs everything including all tests
```

### Running tests individually

```sh
# acktng
cd acktng/src && make lint && make unit-tests

# web-tng
cd web-tng && dotnet test AckWeb.sln

# web-wol
cd web-wol && dotnet test WolWeb.sln

# web-personal
cd web-personal && npm test

# tng-ai
cd tng-ai && .venv/bin/python -m pytest tests/

# tngdb (no tests, import check only)
cd tngdb && .venv/bin/python -c "from api.main import app"
```

### Python virtual environments

`tng-ai/` and `tngdb/` each have their own `.venv/` directory created by `setup.sh`. Always use the project-local venv when running or testing these projects.
