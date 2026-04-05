#!/bin/bash
# session-restore.sh - Restore session context on SessionStart
# Loads the most recent session state to provide continuity across conversations
# Inspired by ruflo's session persistence pattern (github.com/ruvnet/ruflo)

set -e

INPUT=$(cat)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_DIR="${HOME}/.claude/sessions"
CHECKPOINT_DIR="${HOME}/.claude/checkpoints"
LOG_DIR="${HOME}/.claude/logs"

mkdir -p "$SESSION_DIR" "$LOG_DIR"

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
CWD=$(pwd)

# Find the most recent session file for this working directory
LATEST_SESSION=""
if [ -d "$SESSION_DIR" ]; then
  # Check sessions from newest to oldest, match on working directory
  LATEST_SESSION=$(ls -t "$SESSION_DIR"/session-*.json 2>/dev/null | while read -r f; do
    DIR=$(jq -r '.working_directory // ""' "$f" 2>/dev/null)
    if [ "$DIR" = "$CWD" ]; then
      echo "$f"
      break
    fi
  done)

  # No fallback to other projects — restoring unrelated context is worse than no context
fi

# Find most recent checkpoint
LATEST_CHECKPOINT=""
if [ -d "$CHECKPOINT_DIR" ]; then
  LATEST_CHECKPOINT=$(ls -t "$CHECKPOINT_DIR"/checkpoint-*.json 2>/dev/null | head -1)
fi

# Build context summary
CONTEXT_PARTS=()

if [ -n "$LATEST_SESSION" ] && [ -f "$LATEST_SESSION" ]; then
  SESSION_TIMESTAMP=$(jq -r '.timestamp // "unknown"' "$LATEST_SESSION" 2>/dev/null)
  SESSION_BRANCH=$(jq -r '.git.branch // "unknown"' "$LATEST_SESSION" 2>/dev/null)
  SESSION_MODIFIED=$(jq -r '.git.modified_files // [] | join(", ")' "$LATEST_SESSION" 2>/dev/null)
  SESSION_SUMMARY=$(jq -r '.summary // ""' "$LATEST_SESSION" 2>/dev/null)

  CONTEXT_PARTS+=("[session-restore] Previous session: ${SESSION_TIMESTAMP}")
  if [ -n "$SESSION_BRANCH" ] && [ "$SESSION_BRANCH" != "unknown" ] && [ "$SESSION_BRANCH" != "null" ]; then
    CONTEXT_PARTS+=("  Branch: ${SESSION_BRANCH}")
  fi
  if [ -n "$SESSION_MODIFIED" ] && [ "$SESSION_MODIFIED" != "" ]; then
    CONTEXT_PARTS+=("  Modified files: ${SESSION_MODIFIED}")
  fi
  if [ -n "$SESSION_SUMMARY" ] && [ "$SESSION_SUMMARY" != "" ] && [ "$SESSION_SUMMARY" != "null" ]; then
    CONTEXT_PARTS+=("  Summary: ${SESSION_SUMMARY}")
  fi
fi

if [ -n "$LATEST_CHECKPOINT" ] && [ -f "$LATEST_CHECKPOINT" ]; then
  CP_TIMESTAMP=$(jq -r '.timestamp // "unknown"' "$LATEST_CHECKPOINT" 2>/dev/null)
  CP_MESSAGES=$(jq -r '.messages_before_compact // 0' "$LATEST_CHECKPOINT" 2>/dev/null)
  CONTEXT_PARTS+=("[checkpoint] Last compaction: ${CP_TIMESTAMP} (${CP_MESSAGES} messages)")
fi

# Output context if we found anything useful
if [ ${#CONTEXT_PARTS[@]} -gt 0 ]; then
  printf '%s\n' "${CONTEXT_PARTS[@]}"
fi

# Log the restore event
LOG_ENTRY=$(jq -nc \
  --arg ts "$TIMESTAMP" \
  --arg session "$SESSION_ID" \
  --arg restored_from "${LATEST_SESSION:-none}" \
  --arg checkpoint "${LATEST_CHECKPOINT:-none}" \
  '{
    timestamp: $ts,
    session_id: $session,
    event: "session_restore",
    restored_from: $restored_from,
    checkpoint: $checkpoint
  }')

echo "$LOG_ENTRY" >> "${LOG_DIR}/session-metrics.jsonl"

exit 0
