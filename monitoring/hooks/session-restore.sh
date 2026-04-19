#!/bin/bash
# session-restore.sh - Restore session context on SessionStart
# Zero-dependency: pure bash, no jq required.
# Loads the most recent session state scoped to the current working directory.

set -u

INPUT=$(cat 2>/dev/null || true)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_DIR="${HOME}/.claude/sessions"
CHECKPOINT_DIR="${HOME}/.claude/checkpoints"
LOG_DIR="${HOME}/.claude/logs"

mkdir -p "$SESSION_DIR" "$LOG_DIR" 2>/dev/null || true

# Extract session_id from input without jq (best-effort).
SESSION_ID=$(printf '%s' "$INPUT" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')
SESSION_ID="${SESSION_ID:-unknown}"
CWD=$(pwd)

# Find the most recent session file whose working_directory matches CWD.
LATEST_SESSION=""
if [ -d "$SESSION_DIR" ]; then
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    if grep -qF "\"working_directory\":\"$CWD\"" "$f" 2>/dev/null; then
      LATEST_SESSION="$f"
      break
    fi
  done < <(ls -t "$SESSION_DIR"/session-*.json 2>/dev/null)
fi

# Find most recent checkpoint.
LATEST_CHECKPOINT=""
if [ -d "$CHECKPOINT_DIR" ]; then
  LATEST_CHECKPOINT=$(ls -t "$CHECKPOINT_DIR"/checkpoint-*.json 2>/dev/null | head -1)
fi

# Small extractor: first value of a flat string field from a JSON file.
extract_field() {
  local key="$1" file="$2"
  grep -oE "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$file" 2>/dev/null | head -1 | sed -E 's/.*"([^"]*)"$/\1/'
}

# Output context for the model to consume.
if [ -n "$LATEST_SESSION" ] && [ -f "$LATEST_SESSION" ]; then
  SESSION_TS=$(extract_field "timestamp" "$LATEST_SESSION")
  SESSION_BRANCH=$(extract_field "branch" "$LATEST_SESSION")
  echo "[session-restore] Previous session: ${SESSION_TS:-unknown}"
  [ -n "$SESSION_BRANCH" ] && [ "$SESSION_BRANCH" != "none" ] && echo "  Branch: $SESSION_BRANCH"
fi

if [ -n "$LATEST_CHECKPOINT" ] && [ -f "$LATEST_CHECKPOINT" ]; then
  CP_TS=$(extract_field "timestamp" "$LATEST_CHECKPOINT")
  echo "[checkpoint] Last compaction: ${CP_TS:-unknown}"
fi

# Append a minimal log line (one-line JSON).
printf '{"timestamp":"%s","session_id":"%s","event":"session_restore","restored_from":"%s","checkpoint":"%s"}\n' \
  "$TIMESTAMP" "$SESSION_ID" "${LATEST_SESSION:-none}" "${LATEST_CHECKPOINT:-none}" \
  >> "${LOG_DIR}/session-metrics.jsonl" 2>/dev/null || true

exit 0
