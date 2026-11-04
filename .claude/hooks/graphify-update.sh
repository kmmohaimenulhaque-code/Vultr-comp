#!/usr/bin/env bash
# PostToolUse (Edit|Write|MultiEdit|NotebookEdit): keep the graph current. AST-only, no LLM.
export PATH="$HOME/.local/bin:$PATH"
command -v graphify >/dev/null 2>&1 || exit 0
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
graphify update . >/dev/null 2>&1 || true
exit 0
