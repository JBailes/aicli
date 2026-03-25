# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository is the development environment for the ACK!TNG ecosystem. It contains multiple sub-projects as independent git repositories, each ignored by this parent repo's git.

## Sub-Projects

### WOL (active project)

Repos with `wol` in the name are part of the WOL project. Repos with `tng` or `ack` in the name are legacy and NOT part of WOL.

- **`wol/`** -- Stateless connection interface (C#/.NET). Handles telnet, TLS telnet, WS, and WSS protocols on port 6969. Passes game traffic between clients and the realm. Calls API services directly on the private network. Designed for horizontal autoscaling.
- **`wol-realm/`** -- Game engine (C#/.NET). Runs the MUD world simulation (rooms, NPCs, combat, ticks, game logic). Internal-only service on the private network.
- **`wol-accounts/`** -- Account authentication and identity API (Python/FastAPI/asyncpg). Manages accounts, sessions, and login. Private network service.
- **`wol-players/`** -- Player character API (Python/FastAPI/asyncpg). Manages character identity and progression (name, race, class, level, experience). Private network service.
- **`wol-world/`** -- World prototype data API (Python/FastAPI/asyncpg). Manages areas, rooms, exits, object prototypes, NPC prototypes, resets, shops, loot, and scripts. Private network service.
- **`wol-client/`** -- Game client (Dart/Flutter). Login and connect flow over WebSocket.
- **`wol-docs/`** -- Canonical documentation repository for the WOL ecosystem. Game lore lives in `wol-docs/lore/`. Design proposals (except acktng-only) live in `wol-docs/proposals/`.

### Legacy (not part of WOL)

- **`acktng/`** -- Legacy MUD game server (C). Being replaced by `wol/`. See `acktng/CLAUDE.md` for build/test/architecture details.
- **`web/`** -- Web frontend (Python). Serves the ackmud.com and aha.ackmud.com sites. Pure stdlib HTTP server, no framework dependencies.
- **`tngdb/`** -- Database API server (Python/FastAPI/asyncpg). Read-only HTTP API for game content. No tests currently.
- **`tng-ai/`** -- AI/NPC intelligence service (Python/FastAPI/Groq). API for AI-powered NPC responses.

## Environment Setup

This repo (aicli) is Claude's local development environment only. It does NOT bootstrap the game infrastructure. Game infrastructure bootstrap scripts live in `wol-docs/infrastructure/bootstrap/`.

Run `./setup.sh` to set up a complete development environment in one command. It:

1. Installs all system dependencies via apt-get
2. Starts PostgreSQL (required for integration tests)
3. Clones all sub-project repos (skips repos the user lacks access to)
4. Builds and tests acktng (C build + unit/integration tests)
5. Runs web tests (Python integration tests)
6. Creates venv and runs tng-ai tests (pytest)
7. Creates venv and verifies tngdb imports

### System Dependencies (Debian/Ubuntu)

Installed automatically by `setup.sh`:

- `build-essential`, `libcrypt-dev`, `zlib1g-dev` — C compiler, make, and required libraries (`-lcrypt`, `-lz`)
- `libssl-dev` — OpenSSL for TLS/WSS support in the game server
- `pkg-config`, `libpq-dev` — PostgreSQL client library (game server database backend)
- `postgresql`, `postgresql-client` — Local PostgreSQL server (required for integration tests)
- `clang-format` — Code formatting/lint checks
- `git`, `python3`, `python3-pip`, `python3-venv` — Version control, Python runtime, and virtual environments

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

## Output Style

Never use em dashes (—) in any output, including prose, comments, commit messages, and documentation. Use a comma, colon, parentheses, or rephrase instead.

## Model Mode

Use **Opus** mode (`/model opus`) when writing plans and design proposals. Use **Sonnet** mode (`/model sonnet`) when implementing code.

## Branch and PR Policy

**NEVER push directly to main on any repository. All changes must go through a branch and pull request — no exceptions.** This applies to all sub-projects (wol, acktng, web, tngdb, tng-ai) and this repo.

**Before every push to an existing branch, you MUST run `gh pr view <branch>` to check whether the PR is already merged.** If it is merged, stop — do not push to that branch. Instead, create a new branch from the current main and open a new PR. Pushing to a merged PR branch corrupts the git history and bypasses review. No exceptions.

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

# web
cd web && python3 test_integration.py

# tng-ai
cd tng-ai && .venv/bin/python -m pytest tests/

# tngdb (no tests, import check only)
cd tngdb && .venv/bin/python -c "from api.main import app"
```

### Python virtual environments

`tng-ai/` and `tngdb/` each have their own `.venv/` directory created by `setup.sh`. Always use the project-local venv when running or testing these projects.
