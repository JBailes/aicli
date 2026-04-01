---
name: db.conf location and purpose
description: Local development database credentials are stored in credentials/db.conf (gitignored)
type: reference
---

Local dev DB config lives at `/root/aicli/credentials/db.conf` (gitignored). It contains a PostgreSQL connection string pointing to the remote host at `192.168.1.112:5432`, database `acktng`. This file controls which database the local development environment connects to.
