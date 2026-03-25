#!/bin/sh
set -e

OPENCLAW_HOME="${OPENCLAW_HOME:-/home/openclaw/.openclaw}"

# --- Initialize config if not mounted ---
if [ ! -f "$OPENCLAW_HOME/openclaw.json" ]; then
    echo "[entrypoint] No config found — copying default template"
    cp "$OPENCLAW_HOME/openclaw.json.default" "$OPENCLAW_HOME/openclaw.json"
fi

# --- Initialize workspace if empty ---
if [ ! -f "$OPENCLAW_HOME/workspace/SOUL.md" ]; then
    echo "[entrypoint] No workspace found — copying defaults"
    cp -rn "$OPENCLAW_HOME/workspace.default/." "$OPENCLAW_HOME/workspace/" 2>/dev/null || true
fi

# --- Inject API key from env if set ---
if [ -n "$ANTHROPIC_API_KEY" ] || [ -n "$OPENAI_API_KEY" ] || [ -n "$GOOGLE_API_KEY" ]; then
    echo "[entrypoint] API key(s) detected in environment"
fi

# --- Validate config ---
if command -v openclaw >/dev/null 2>&1; then
    echo "[entrypoint] OpenClaw $(openclaw --version 2>/dev/null | head -1)"
    echo "[entrypoint] Config: $OPENCLAW_HOME/openclaw.json"
    echo "[entrypoint] Workspace: $OPENCLAW_HOME/workspace/"
fi

echo "[entrypoint] Starting: $*"
exec "$@"
