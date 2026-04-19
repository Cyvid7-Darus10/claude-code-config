#!/bin/bash
# session-persist.sh - Auto-save session state on Stop
# Zero-dependency: pure bash, no jq required.
# Persists working context (git state, cwd) for cross-session continuity.

set -u

INPUT=$(cat 2>/dev/null || true)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_DIR="${HOME}/.claude/sessions"
LOG_DIR="${HOME}/.claude/logs"

mkdir -p "$SESSION_DIR" "$LOG_DIR" 2>/dev/null || true

# Extract session_id (best-effort JSON parse without jq).
SESSION_ID=$(printf '%s' "$INPUT" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')
SESSION_ID="${SESSION_ID:-unknown}"

CWD=$(pwd)
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "none")

# Gather git state as comma-separated strings (safe, bounded).
MODIFIED_FILES=$(git diff --name-only 2>/dev/null | head -10 | tr '\n' ',' | sed 's/,$//')
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null | head -10 | tr '\n' ',' | sed 's/,$//')

SESSION_FILE="${SESSION_DIR}/session-${SESSION_ID}.json"

# Emit a single-line JSON record. Only fields known-safe (no quotes in values).
printf '{"timestamp":"%s","session_id":"%s","working_directory":"%s","branch":"%s","modified_files":"%s","staged_files":"%s"}\n' \
  "$TIMESTAMP" "$SESSION_ID" "$CWD" "$GIT_BRANCH" "$MODIFIED_FILES" "$STAGED_FILES" \
  > "$SESSION_FILE"

# Prune: keep last 30 sessions.
ls -t "$SESSION_DIR"/session-*.json 2>/dev/null | tail -n +31 | xargs rm -f 2>/dev/null || true

printf '{"timestamp":"%s","session_id":"%s","event":"session_persist","file":"%s"}\n' \
  "$TIMESTAMP" "$SESSION_ID" "$SESSION_FILE" \
  >> "${LOG_DIR}/session-metrics.jsonl" 2>/dev/null || true

exit 0
