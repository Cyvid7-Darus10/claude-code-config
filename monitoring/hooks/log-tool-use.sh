#!/bin/bash
# log-tool-use.sh - Log all tool usage for observability
# Async hook - runs in background without blocking

set -e

INPUT=$(cat)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_DIR="${HOME}/.claude/logs"
LOG_FILE="${LOG_DIR}/tool-execution.jsonl"

# Create log directory if needed
mkdir -p "$LOG_DIR"

# Extract fields from JSON input
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
AGENT_ID=$(echo "$INPUT" | jq -r '.agent_id // "main"')
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')

# Create log entry
LOG_ENTRY=$(jq -nc \
  --arg ts "$TIMESTAMP" \
  --arg tool "$TOOL_NAME" \
  --arg session "$SESSION_ID" \
  --arg agent "$AGENT_ID" \
  --arg event "$HOOK_EVENT" \
  '{
    timestamp: $ts,
    tool: $tool,
    session_id: $session,
    agent_id: $agent,
    event: $event
  }')

# Append to log file
echo "$LOG_ENTRY" >> "$LOG_FILE"

# Optional: Send to monitoring server if configured
if [ -n "$CLAUDE_MONITORING_URL" ]; then
  curl -s -X POST "$CLAUDE_MONITORING_URL/events" \
    -H "Content-Type: application/json" \
    -d "$LOG_ENTRY" > /dev/null 2>&1 &
fi

exit 0
