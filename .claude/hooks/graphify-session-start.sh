#!/usr/bin/env bash
# SessionStart: ensure graphify is installed, then rebuild the code graph.
# Fails open: a graphify problem must never block the session.
set -u
export PATH="$HOME/.local/bin:$PATH"
if ! command -v graphify >/dev/null 2>&1; then
  uv tool install --quiet "git+https://github.com/Graphify-Labs/graphify@v8" >/dev/null 2>&1 \
    || pip install --quiet graphifyy >/dev/null 2>&1 || exit 0
fi
# Make graphify visible to the Bash tool for the rest of the session.
[ -n "${CLAUDE_ENV_FILE:-}" ] && echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
graphify hook install >/dev/null 2>&1 || true   # git hooks live in .git/, not tracked
graphify update . >/dev/null 2>&1 || true
exit 0
