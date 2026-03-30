#!/bin/bash
# session-metrics.sh - Track session metrics for monitoring dashboard
# Runs on Stop event to capture session summary

set -e

INPUT=$(cat)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_DIR="${HOME}/.claude/logs"
METRICS_LOG="${LOG_DIR}/session-metrics.jsonl"

mkdir -p "$LOG_DIR"

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // ""')

# Calculate session metrics from transcript
TOOL_COUNT=0
ERROR_COUNT=0
DURATION_SECONDS=0

if [ -f "$TRANSCRIPT_PATH" ]; then
  # Count tool uses
  TOOL_COUNT=$(jq -s '[.[] | select(.type == "tool_result")] | length' "$TRANSCRIPT_PATH" 2>/dev/null || echo 0)

  # Count errors
  ERROR_COUNT=$(jq -s '[.[] | select(.type == "tool_result" and .is_error == true)] | length' "$TRANSCRIPT_PATH" 2>/dev/null || echo 0)
fi

# Create metrics entry
METRICS_ENTRY=$(jq -nc \
  --arg ts "$TIMESTAMP" \
  --arg session "$SESSION_ID" \
  --argjson tools "$TOOL_COUNT" \
  --argjson errors "$ERROR_COUNT" \
  '{
    timestamp: $ts,
    session_id: $session,
    tool_count: $tools,
    error_count: $errors,
    event: "session_end"
  }')

echo "$METRICS_ENTRY" >> "$METRICS_LOG"

exit 0
