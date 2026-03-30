#!/bin/bash
# security-audit.sh - Security monitoring hook
# Detects and logs potentially dangerous operations

set -e

INPUT=$(cat)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_DIR="${HOME}/.claude/logs"
SECURITY_LOG="${LOG_DIR}/security-audit.jsonl"

mkdir -p "$LOG_DIR"

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // {}')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

# Security patterns to monitor
ALERT_LEVEL="none"
ALERT_REASON=""

case "$TOOL_NAME" in
  "Bash")
    COMMAND=$(echo "$TOOL_INPUT" | jq -r '.command // ""')

    # Check for credential access
    if echo "$COMMAND" | grep -qiE '(\.ssh|\.aws|\.env|credentials|secrets|token|password|api.?key)'; then
      ALERT_LEVEL="high"
      ALERT_REASON="Potential credential access"
    fi

    # Check for data exfiltration
    if echo "$COMMAND" | grep -qiE '(curl.*-d|wget.*--post|nc |netcat)'; then
      ALERT_LEVEL="medium"
      ALERT_REASON="Potential data exfiltration"
    fi

    # Check for destructive commands
    if echo "$COMMAND" | grep -qiE '(rm -rf|format|mkfs|dd if=)'; then
      ALERT_LEVEL="critical"
      ALERT_REASON="Destructive command detected"
    fi
    ;;

  "Read")
    FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // ""')

    if echo "$FILE_PATH" | grep -qiE '(\.ssh|\.aws|\.env|credentials|secrets)'; then
      ALERT_LEVEL="high"
      ALERT_REASON="Sensitive file read attempt"
    fi
    ;;
esac

# Log security events
if [ "$ALERT_LEVEL" != "none" ]; then
  LOG_ENTRY=$(jq -nc \
    --arg ts "$TIMESTAMP" \
    --arg tool "$TOOL_NAME" \
    --arg session "$SESSION_ID" \
    --arg level "$ALERT_LEVEL" \
    --arg reason "$ALERT_REASON" \
    --argjson input "$TOOL_INPUT" \
    '{
      timestamp: $ts,
      tool: $tool,
      session_id: $session,
      alert_level: $level,
      reason: $reason,
      input: $input
    }')

  echo "$LOG_ENTRY" >> "$SECURITY_LOG"

  # Critical alerts: output warning to stderr (visible to agent)
  if [ "$ALERT_LEVEL" = "critical" ]; then
    echo "SECURITY WARNING: $ALERT_REASON" >&2
  fi
fi

exit 0
