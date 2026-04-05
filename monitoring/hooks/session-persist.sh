#!/bin/bash
# session-persist.sh - Auto-save session state on Stop
# Persists working context after each response for cross-session continuity
# Inspired by ruflo's session persistence pattern (github.com/ruvnet/ruflo)

set -e

INPUT=$(cat)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_DIR="${HOME}/.claude/sessions"
LOG_DIR="${HOME}/.claude/logs"

mkdir -p "$SESSION_DIR" "$LOG_DIR"

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // ""')

# Gather current state
CWD=$(pwd)
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "none")
MODIFIED_FILES=$(git diff --name-only 2>/dev/null | head -20 || echo "")
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null | head -20 || echo "")
RECENT_COMMITS=$(git log --oneline -5 2>/dev/null || echo "")

# Count session activity
TOOL_COUNT=0
if [ -f "$TRANSCRIPT_PATH" ]; then
  TOOL_COUNT=$(jq -s '[.[] | select(.type == "tool_result")] | length' "$TRANSCRIPT_PATH" 2>/dev/null || echo 0)
fi

# Save session state
SESSION_FILE="${SESSION_DIR}/session-${SESSION_ID}.json"

jq -nc \
  --arg ts "$TIMESTAMP" \
  --arg session "$SESSION_ID" \
  --arg cwd "$CWD" \
  --arg branch "$GIT_BRANCH" \
  --arg modified "$MODIFIED_FILES" \
  --arg staged "$STAGED_FILES" \
  --arg commits "$RECENT_COMMITS" \
  --argjson tools "$TOOL_COUNT" \
  '{
    timestamp: $ts,
    session_id: $session,
    working_directory: $cwd,
    git: {
      branch: $branch,
      modified_files: ($modified | split("\n") | map(select(. != ""))),
      staged_files: ($staged | split("\n") | map(select(. != ""))),
      recent_commits: ($commits | split("\n") | map(select(. != "")))
    },
    activity: {
      tool_count: $tools
    }
  }' > "$SESSION_FILE"

# Cleanup old sessions (keep last 30)
ls -t "$SESSION_DIR"/session-*.json 2>/dev/null | tail -n +31 | xargs rm -f 2>/dev/null || true

# Log persistence event
LOG_ENTRY=$(jq -nc \
  --arg ts "$TIMESTAMP" \
  --arg session "$SESSION_ID" \
  --arg file "$SESSION_FILE" \
  '{
    timestamp: $ts,
    session_id: $session,
    event: "session_persist",
    session_file: $file
  }')

echo "$LOG_ENTRY" >> "${LOG_DIR}/session-metrics.jsonl"

exit 0
