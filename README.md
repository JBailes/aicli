# aicli

Development environment for the ACK!TNG MUD ecosystem.

## Quick Start

```sh
git clone git@github.com:<your-org>/aicli.git
cd aicli
./setup.sh
```

`setup.sh` handles everything: installs system dependencies, starts PostgreSQL, clones all sub-project repos, builds the game server, and runs all tests. Requires root/sudo on Debian or Ubuntu.

## Sub-Projects

| Directory | Description |
|-----------|-------------|
| `acktng/` | Main MUD game server (C) — see `acktng/CLAUDE.md` for details |
| `web/`    | Web frontend |
| `tngdb/`  | Database tooling and utilities |
| `tng-ai/` | AI/NPC intelligence systems |

Each sub-project is an independent git repo. They are ignored by this repo's git but fully functional for commits, branches, and pushes within their own directories.

## Requirements

- Debian or Ubuntu (tested on Debian 13, Ubuntu 24.04)
- SSH key with access to the GitHub repos
- Root/sudo access (for apt-get and PostgreSQL)

## Testing

All tests must be run locally before pushing. See `CLAUDE.md` for details.
