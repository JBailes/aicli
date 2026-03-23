# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository is the development environment for the ACK!TNG ecosystem. It contains multiple sub-projects as independent git repositories, each ignored by this parent repo's git.

## Sub-Projects

- **`acktng/`** — Main MUD game server (C). See `acktng/CLAUDE.md` for build/test/architecture details. Game lore lives in `acktng/docs/lore/`.
- **`web/`** — Web frontend (Python). Serves the ackmud.com and aha.ackmud.com sites. Pure stdlib HTTP server, no framework dependencies.
- **`tngdb/`** — Database API server (Python/FastAPI/asyncpg). Read-only HTTP API for game content. No tests currently.
- **`tng-ai/`** — AI/NPC intelligence service (Python/FastAPI/Groq). API for AI-powered NPC responses.

## Environment Setup

Run `./setup.sh` to set up a complete development environment in one command. It:

1. Installs all system dependencies via apt-get
2. Starts PostgreSQL (required for acktng integration tests)
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

Proposals live in `docs/proposals/` within the relevant repository:
- `docs/proposals/open/` — active proposals pending discussion or implementation
- `docs/proposals/completed/` — proposals that have been fully implemented
- `docs/proposals/rejected/` — proposals that were rejected

This applies to all repositories: aicli, acktng, web, tngdb, and tng-ai.

## Branch and PR Policy

**NEVER push directly to main on any repository. All changes must go through a branch and pull request — no exceptions.** This applies to all sub-projects (acktng, web, tngdb, tng-ai) and this repo.

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

# tngdb (no tests — import check only)
cd tngdb && .venv/bin/python -c "from api.main import app"
```

### Python virtual environments

`tng-ai/` and `tngdb/` each have their own `.venv/` directory created by `setup.sh`. Always use the project-local venv when running or testing these projects.
