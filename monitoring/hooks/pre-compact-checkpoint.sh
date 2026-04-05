#!/bin/bash
# pre-compact-checkpoint.sh - Save state before context compaction
# Runs on PreCompact to preserve working context that might be lost
# Inspired by ruflo's PreCompact checkpoint pattern (github.com/ruvnet/ruflo)

set -e

INPUT=$(cat)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
CHECKPOINT_DIR="${HOME}/.claude/checkpoints"
LOG_DIR="${HOME}/.claude/logs"

mkdir -p "$CHECKPOINT_DIR" "$LOG_DIR"

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // ""')

# Create checkpoint filename with timestamp
CHECKPOINT_FILE="${CHECKPOINT_DIR}/checkpoint-${SESSION_ID}-$(date +%Y%m%d-%H%M%S).json"

# Gather current working state
CWD=$(pwd)
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "none")
GIT_STATUS=$(git status --porcelain 2>/dev/null | head -20 || echo "")
MODIFIED_FILES=$(git diff --name-only 2>/dev/null | head -30 || echo "")
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null | head -30 || echo "")

# Count messages in transcript if available
MESSAGE_COUNT=0
if [ -f "$TRANSCRIPT_PATH" ]; then
  MESSAGE_COUNT=$(jq -s 'length' "$TRANSCRIPT_PATH" 2>/dev/null || echo 0)
fi

# Save checkpoint
jq -nc \
  --arg ts "$TIMESTAMP" \
  --arg session "$SESSION_ID" \
  --arg cwd "$CWD" \
  --arg branch "$GIT_BRANCH" \
  --arg status "$GIT_STATUS" \
  --arg modified "$MODIFIED_FILES" \
  --arg staged "$STAGED_FILES" \
  --argjson messages "$MESSAGE_COUNT" \
  '{
    timestamp: $ts,
    session_id: $session,
    event: "pre_compact_checkpoint",
    working_directory: $cwd,
    git: {
      branch: $branch,
      status: ($status | split("\n") | map(select(. != ""))),
      modified_files: ($modified | split("\n") | map(select(. != ""))),
      staged_files: ($staged | split("\n") | map(select(. != "")))
    },
    messages_before_compact: $messages
  }' > "$CHECKPOINT_FILE"

# Log the checkpoint event
LOG_ENTRY=$(jq -nc \
  --arg ts "$TIMESTAMP" \
  --arg session "$SESSION_ID" \
  --arg file "$CHECKPOINT_FILE" \
  --argjson messages "$MESSAGE_COUNT" \
  '{
    timestamp: $ts,
    session_id: $session,
    event: "pre_compact_checkpoint",
    checkpoint_file: $file,
    messages_before_compact: $messages
  }')

echo "$LOG_ENTRY" >> "${LOG_DIR}/session-metrics.jsonl"

# Cleanup old checkpoints (keep last 20)
ls -t "$CHECKPOINT_DIR"/checkpoint-*.json 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null || true

exit 0
