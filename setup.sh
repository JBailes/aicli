#!/bin/bash
# Full development environment setup for ACK!TNG ecosystem.
# Run as root or with sudo. Idempotent — safe to re-run.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# -------------------------------------------------------------------------
# 1. System dependencies
# -------------------------------------------------------------------------

# Remove stale Microsoft apt repo if present. .NET is installed via
# dotnet-install.sh (section 7), so this repo is not needed. Its GPG key
# uses SHA-1 binding signatures, which sqv on Debian 13 rejects as of
# 2026-02-01, causing apt-get update to fail.
if [ -f /etc/apt/sources.list.d/microsoft-prod.list ]; then
  echo "==> Removing stale Microsoft apt source (not needed, breaks apt on Debian 13)..."
  rm -f /etc/apt/sources.list.d/microsoft-prod.list
fi

echo "==> Installing system dependencies..."
apt-get update -qq
echo "==> Upgrading installed packages..."
apt-get upgrade -y -qq 2>&1 | tail -1
apt-get install -y -qq \
  build-essential libcrypt-dev zlib1g-dev libssl-dev \
  pkg-config libpq-dev postgresql postgresql-client \
  clang-format git curl python3 python3-pip python3-venv \
  python3-psycopg2 python3-yaml \
  liblua5.4-dev \
  nodejs npm 2>&1 | tail -1

# -------------------------------------------------------------------------
# 2. Install Claude Code CLI
# -------------------------------------------------------------------------
if ! command -v claude &>/dev/null; then
  echo "==> Installing Claude Code CLI..."
  curl -fsSL https://claude.ai/install.sh | bash
  # The installer places claude in ~/.local/bin. Symlink it onto the system
  # PATH so it is available immediately (same approach used for dotnet below).
  if [ -f "$HOME/.local/bin/claude" ]; then
    ln -sf "$HOME/.local/bin/claude" /usr/local/bin/claude
  fi
  export PATH="$HOME/.local/bin:$PATH"
else
  echo "==> Claude Code CLI already installed ($(claude --version 2>/dev/null || echo 'unknown version'))"
fi

# -------------------------------------------------------------------------
# 3. Install thebrain (Claude Code plugin)
# -------------------------------------------------------------------------
THEBRAIN_DIR="$SCRIPT_DIR/thebrain"

if [ ! -d "$THEBRAIN_DIR" ]; then
  echo "==> Cloning thebrain..."
  git clone https://github.com/Advenire-Consulting/thebrain.git "$THEBRAIN_DIR"
fi

echo "==> Installing thebrain dependencies..."
cd "$THEBRAIN_DIR"
npm install --silent

echo "==> Registering thebrain plugin with Claude Code..."
claude plugins marketplace add "$THEBRAIN_DIR" 2>/dev/null || true
claude plugins install thebrain@thebrain-local 2>/dev/null || true

# -------------------------------------------------------------------------
# 3b. Seed brain state (behavioral calibration + memory)
# -------------------------------------------------------------------------
BRAIN_DIR="$HOME/.claude/brain"
BRAIN_SEED="$SCRIPT_DIR/brain-seed"

# Determine the Claude Code project memory path.
# Claude Code derives this from the absolute working directory, replacing
# path separators with dashes and prepending a dash.
SANITIZED="$(echo "$SCRIPT_DIR" | tr '/' '-')"
MEMORY_DIR="$HOME/.claude/projects/${SANITIZED}/memory"

if [ -d "$BRAIN_SEED" ]; then
  mkdir -p "$BRAIN_DIR" "$MEMORY_DIR/projects"

  # Seed signals.db (behavioral calibration) if not already present
  if [ ! -f "$BRAIN_DIR/signals.db" ]; then
    echo "==> Seeding brain signals database..."
    cp "$BRAIN_SEED/signals.db" "$BRAIN_DIR/signals.db"
  else
    echo "==> Brain signals database already exists, skipping seed"
  fi

  # Seed config.json (workspace pointer), always regenerate to match paths
  echo "==> Writing brain config..."
  sed "s|__AICLI_DIR__|$SCRIPT_DIR|g" "$BRAIN_SEED/config.json" > "$BRAIN_DIR/config.json"

  # Seed prefrontal rules if not already present
  if [ ! -f "$BRAIN_DIR/prefrontal-live.md" ]; then
    echo "==> Seeding prefrontal rules..."
    cp "$BRAIN_SEED/prefrontal-live.md" "$BRAIN_DIR/prefrontal-live.md"
    cp "$BRAIN_SEED/prefrontal-live.md" "$BRAIN_DIR/prefrontal-cortex.md"
  else
    echo "==> Prefrontal rules already exist, skipping seed"
  fi

  # Seed memory files if MEMORY.md is not already present
  if [ ! -f "$MEMORY_DIR/MEMORY.md" ]; then
    echo "==> Seeding Claude Code memory files..."
    cp "$BRAIN_SEED"/memory/*.md "$MEMORY_DIR/"
    cp "$BRAIN_SEED"/memory/projects/*.md "$MEMORY_DIR/projects/"
  else
    echo "==> Memory files already exist, skipping seed"
  fi
fi

# -------------------------------------------------------------------------
# 4. Ensure PostgreSQL is running
# -------------------------------------------------------------------------
echo "==> Ensuring PostgreSQL is running..."
if ! pg_lsclusters -h | grep -q 'online'; then
  pg_ctlcluster "$(pg_lsclusters -h | awk '{print $1}')" main start
fi
echo "   PostgreSQL is online."

# -------------------------------------------------------------------------
# 5. Clone sub-project repos (skip if already present or no access)
# -------------------------------------------------------------------------
REPOS=(
  "wol git@github.com:JBailes/wol.git"
  "wol-realm git@github.com:JBailes/wol-realm.git"
  "wol-accounts git@github.com:JBailes/wol-accounts.git"
  "wol-players git@github.com:JBailes/wol-players.git"
  "wol-world git@github.com:JBailes/wol-world.git"
  "wol-client git@github.com:JBailes/wol-client.git"
  "wol-docs git@github.com:JBailes/wol-docs.git"
  "web-wol git@github.com:JBailes/web-wol.git"
  "web-tng git@github.com:JBailes/web-tng.git"
  "web-personal git@github.com:JBailes/web-personal.git"
  "acktng git@github.com:ackmudhistoricalarchive/acktng.git"
  "tngdb git@github.com:ackmudhistoricalarchive/tngdb.git"
  "tng-ai git@github.com:ackmudhistoricalarchive/tng-ai.git"
  "wolf git@github.com:JBailes/wolf.git"
  "SimpleNAS git@github.com:JBailes/SimpleNAS.git"
  "infrastructure git@github.com:JBailes/infrastructure.git"
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
# 6. Build and test acktng
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
# 7. Install .NET 9 SDK (via caching proxy on nginx-proxy, CT 118)
# -------------------------------------------------------------------------
DOTNET_CACHE_URL="http://192.168.1.118:8080"

if ! command -v dotnet &>/dev/null || ! dotnet --list-sdks | grep -q "^9\."; then
  echo "==> Installing .NET 9 SDK..."
  curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
  chmod +x /tmp/dotnet-install.sh
  if ! bash /tmp/dotnet-install.sh --channel 9.0 --install-dir /usr/local/dotnet \
      --azure-feed "$DOTNET_CACHE_URL" 2>/dev/null; then
    echo "   Cache unreachable, downloading directly from Microsoft"
    bash /tmp/dotnet-install.sh --channel 9.0 --install-dir /usr/local/dotnet
  fi
  ln -sf /usr/local/dotnet/dotnet /usr/local/bin/dotnet
fi

if [ -d "$SCRIPT_DIR/web-tng" ]; then
  echo "==> Running web-tng tests..."
  cd "$SCRIPT_DIR/web-tng"
  dotnet test AckWeb.sln --configuration Release
  echo "   web-tng tests passed."
else
  echo "==> Skipping web-tng (repo not cloned)"
fi

if [ -d "$SCRIPT_DIR/web-wol" ]; then
  echo "==> Running web-wol tests..."
  cd "$SCRIPT_DIR/web-wol"
  dotnet test WolWeb.sln --configuration Release
  echo "   web-wol tests passed."
else
  echo "==> Skipping web-wol (repo not cloned)"
fi

if [ -d "$SCRIPT_DIR/web-personal" ]; then
  echo "==> Running web-personal tests..."
  cd "$SCRIPT_DIR/web-personal"
  npm install --silent
  npm test
  echo "   web-personal tests passed."
else
  echo "==> Skipping web-personal (repo not cloned)"
fi

# -------------------------------------------------------------------------
# 8. Set up and test tng-ai
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
# 9. Set up tngdb (no tests, verify import only)
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
