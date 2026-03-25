# aicli

Development environment for the ACKmud ecosystem. Contains the WOL game platform and legacy ACK!TNG projects as independent sub-repos.

## Quick Start

```sh
git clone git@github.com:JBailes/aicli.git
cd aicli
./setup.sh
```

`setup.sh` handles everything: installs system dependencies, starts PostgreSQL, clones all sub-project repos, builds acktng, and runs all tests. Requires root/sudo on Debian or Ubuntu.

## Sub-Projects

### WOL (active)

| Directory | Description | Language |
|-----------|-------------|----------|
| `wol/` | Stateless connection interface: telnet, TLS, WS, WSS on port 6969 | C#/.NET |
| `wol-realm/` | Game engine: world simulation, rooms, NPCs, combat, ticks | C#/.NET |
| `wol-accounts/` | Account authentication and session API | Python/FastAPI |
| `wol-players/` | Player character identity and progression API | Python/FastAPI |
| `wol-world/` | World prototype data API (areas, rooms, objects, NPCs) | Python/FastAPI |
| `wol-client/` | Game client (login and connect flow over WebSocket) | Dart/Flutter |
| `wol-docs/` | Canonical documentation: lore, proposals, infrastructure | Markdown |

### Legacy (not part of WOL)

| Directory | Description | Tests |
|-----------|-------------|-------|
| `acktng/` | Legacy MUD game server being replaced by WOL | `cd src && make unit-tests` |
| `web/` | Web frontend for ackmud.com and aha.ackmud.com (Blazor WASM + nginx) | `python3 test_integration.py` |
| `tng-ai/` | AI/NPC intelligence service (Groq-backed) | `.venv/bin/python -m pytest tests/` |
| `tngdb/` | Read-only HTTP API for game content | import check only |

Each sub-project is an independent git repo ignored by this repo's git but fully functional for commits, branches, and PRs within its own directory.

## Requirements

- Debian or Ubuntu (tested on Debian 13, Ubuntu 24.04)
- SSH key with access to the GitHub repos
- Root/sudo access (for apt-get and PostgreSQL)
