#!/bin/bash
# Full development environment setup for ACK!TNG ecosystem.
# Run as root or with sudo. Idempotent — safe to re-run.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# -------------------------------------------------------------------------
# 1. System dependencies
# -------------------------------------------------------------------------
echo "==> Installing system dependencies..."
apt-get update -qq
apt-get install -y -qq \
  build-essential libcrypt-dev zlib1g-dev libssl-dev \
  pkg-config libpq-dev postgresql postgresql-client \
  clang-format git python3 2>&1 | tail -1

# -------------------------------------------------------------------------
# 2. Ensure PostgreSQL is running
# -------------------------------------------------------------------------
echo "==> Ensuring PostgreSQL is running..."
if ! pg_lsclusters -h | grep -q 'online'; then
  pg_ctlcluster "$(pg_lsclusters -h | awk '{print $1}')" main start
fi
echo "   PostgreSQL is online."

# -------------------------------------------------------------------------
# 3. Clone sub-project repos (skip if already present or no access)
# -------------------------------------------------------------------------
REPOS=(
  "acktng git@github.com:ackmudhistoricalarchive/acktng.git"
  "web git@github.com:ackmudhistoricalarchive/web.git"
  "tngdb git@github.com:ackmudhistoricalarchive/tngdb.git"
  "tng-ai git@github.com:ackmudhistoricalarchive/tng-ai.git"
)

echo "==> Cloning repositories..."
for entry in "${REPOS[@]}"; do
  dir="${entry%% *}"
  url="${entry#* }"
  target="$SCRIPT_DIR/$dir"

  if [ -d "$target" ]; then
    echo "   Skipping $dir (already exists)"
    continue
  fi

  if git clone "$url" "$target" 2>/dev/null; then
    echo "   Cloned $dir"
  else
    echo "   Skipping $dir (no access or repo not found)"
  fi
done

# -------------------------------------------------------------------------
# 4. Build acktng
# -------------------------------------------------------------------------
if [ -d "$SCRIPT_DIR/acktng/src" ]; then
  echo "==> Building acktng..."
  cd "$SCRIPT_DIR/acktng/src"
  make ack
  echo "   Build complete."

  # -------------------------------------------------------------------------
  # 5. Run tests
  # -------------------------------------------------------------------------
  echo "==> Running acktng tests..."
  make unit-tests
  echo "   All tests passed."
else
  echo "==> Skipping acktng build (repo not cloned)"
fi

echo ""
echo "==> Setup complete. Development environment is ready."
