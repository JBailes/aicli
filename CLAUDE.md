# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository is the development environment for the ACK!TNG ecosystem. It contains multiple sub-projects as independent git repositories, each ignored by this parent repo's git.

## Sub-Projects

- **`acktng/`** — The main MUD game server (C). See `acktng/CLAUDE.md` for build/test/architecture details.
- **`web/`** — Web frontend for the game.
- **`tngdb/`** — Database tooling and utilities.
- **`tng-ai/`** — AI/NPC intelligence systems.

## Environment Setup

Run `./setup.sh` to set up a complete development environment in one command. It:

1. Installs all system dependencies via apt-get
2. Starts PostgreSQL (required for integration tests)
3. Clones all sub-project repos (skips repos the user lacks access to)
4. Builds the acktng game server
5. Runs all acktng tests (unit + integration)

### System Dependencies (Debian/Ubuntu)

Installed automatically by `setup.sh`:

- `build-essential`, `libcrypt-dev`, `zlib1g-dev` — C compiler, make, and required libraries (`-lcrypt`, `-lz`)
- `libssl-dev` — OpenSSL for TLS/WSS support in the game server
- `pkg-config`, `libpq-dev` — PostgreSQL client library (game server database backend)
- `postgresql`, `postgresql-client` — Local PostgreSQL server (required for integration tests)
- `clang-format` — Code formatting/lint checks
- `git`, `python3` — Version control and test scripts

## Testing

All tests (unit, integration, etc.) for all sub-projects must be run locally. Never run tests on remote systems or trigger remote CI — always validate locally before pushing.

### acktng tests

```sh
cd acktng/src
make lint         # Check formatting
make unit-tests   # Unit tests + integration tests (requires running PostgreSQL)
```
