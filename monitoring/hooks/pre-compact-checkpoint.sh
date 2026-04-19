#!/bin/bash
# pre-compact-checkpoint.sh - Save state before context compaction
# Zero-dependency: pure bash, no jq required.
# Runs on PreCompact to preserve working context that might be lost.

set -u

INPUT=$(cat 2>/dev/null || true)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
CHECKPOINT_DIR="${HOME}/.claude/checkpoints"
LOG_DIR="${HOME}/.claude/logs"

mkdir -p "$CHECKPOINT_DIR" "$LOG_DIR" 2>/dev/null || true

SESSION_ID=$(printf '%s' "$INPUT" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')
SESSION_ID="${SESSION_ID:-unknown}"

CHECKPOINT_FILE="${CHECKPOINT_DIR}/checkpoint-${SESSION_ID}-$(date +%Y%m%d-%H%M%S).json"

CWD=$(pwd)
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "none")
MODIFIED_FILES=$(git diff --name-only 2>/dev/null | head -20 | tr '\n' ',' | sed 's/,$//')
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null | head -20 | tr '\n' ',' | sed 's/,$//')

printf '{"timestamp":"%s","session_id":"%s","event":"pre_compact_checkpoint","working_directory":"%s","branch":"%s","modified_files":"%s","staged_files":"%s"}\n' \
  "$TIMESTAMP" "$SESSION_ID" "$CWD" "$GIT_BRANCH" "$MODIFIED_FILES" "$STAGED_FILES" \
  > "$CHECKPOINT_FILE"

printf '{"timestamp":"%s","session_id":"%s","event":"pre_compact_checkpoint","file":"%s"}\n' \
  "$TIMESTAMP" "$SESSION_ID" "$CHECKPOINT_FILE" \
  >> "${LOG_DIR}/session-metrics.jsonl" 2>/dev/null || true

# Prune: keep last 20 checkpoints.
ls -t "$CHECKPOINT_DIR"/checkpoint-*.json 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null || true

exit 0
