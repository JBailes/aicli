# aicli

Development environment for the ACK!TNG MUD ecosystem.

## Quick Start

```sh
git clone git@github.com:JBailes/aicli.git
cd aicli
./setup.sh
```

`setup.sh` handles everything: installs system dependencies, starts PostgreSQL, clones all sub-project repos, builds the game server, and runs all tests. Requires root/sudo on Debian or Ubuntu.

## Sub-Projects

| Directory | Description | Tests |
|-----------|-------------|-------|
| `acktng/` | Main MUD game server (C) | `cd src && make unit-tests` |
| `web/`    | Web frontend (Python) | `python3 test_integration.py` |
| `tng-ai/` | AI/NPC intelligence service (Python/FastAPI) | `.venv/bin/python -m pytest tests/` |
| `tngdb/`  | Database API server (Python/FastAPI) | None (import check only) |

Each sub-project is an independent git repo. They are ignored by this repo's git but fully functional for commits, branches, and pushes within their own directories.

## Requirements

- Debian or Ubuntu (tested on Debian 13, Ubuntu 24.04)
- SSH key with access to the GitHub repos
- Root/sudo access (for apt-get and PostgreSQL)
