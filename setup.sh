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
  clang-format git python3 python3-pip python3-venv 2>&1 | tail -1

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
# 4. Build and test acktng
# -------------------------------------------------------------------------
if [ -d "$SCRIPT_DIR/acktng/src" ]; then
  echo "==> Building acktng..."
  cd "$SCRIPT_DIR/acktng/src"
  make ack
  echo "   Build complete."

  echo "==> Running acktng tests..."
  make unit-tests
  echo "   acktng tests passed."
else
  echo "==> Skipping acktng (repo not cloned)"
fi

# -------------------------------------------------------------------------
# 5. Test web
# -------------------------------------------------------------------------
if [ -d "$SCRIPT_DIR/web" ]; then
  echo "==> Running web tests..."
  cd "$SCRIPT_DIR/web"
  python3 test_integration.py
  echo "   web tests passed."
else
  echo "==> Skipping web (repo not cloned)"
fi

# -------------------------------------------------------------------------
# 6. Set up and test tng-ai
# -------------------------------------------------------------------------
if [ -d "$SCRIPT_DIR/tng-ai" ]; then
  echo "==> Setting up tng-ai..."
  cd "$SCRIPT_DIR/tng-ai"
  if [ ! -d .venv ]; then
    python3 -m venv .venv
  fi
  .venv/bin/pip install -q -r requirements.txt
  .venv/bin/pip install -q "pytest>=8.0.0" "httpx>=0.27.0" "pytest-asyncio>=0.24.0"

  echo "==> Running tng-ai tests..."
  .venv/bin/python -m pytest tests/ -q
  echo "   tng-ai tests passed."
else
  echo "==> Skipping tng-ai (repo not cloned)"
fi

# -------------------------------------------------------------------------
# 7. Set up tngdb (no tests — verify import only)
# -------------------------------------------------------------------------
if [ -d "$SCRIPT_DIR/tngdb/api" ]; then
  echo "==> Setting up tngdb..."
  cd "$SCRIPT_DIR/tngdb"
  if [ ! -d .venv ]; then
    python3 -m venv .venv
  fi
  .venv/bin/pip install -q -r api/requirements.txt
  .venv/bin/python -c "from api.main import app; print('   tngdb API imports OK')"
else
  echo "==> Skipping tngdb (repo not cloned)"
fi

echo ""
echo "==> Setup complete. Development environment is ready."
