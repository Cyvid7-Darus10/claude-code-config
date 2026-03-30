# Claude Code Monitoring

Real-time observability for Claude Code agents. Track tool usage, security events, and session metrics.

## Quick Start

### 1. Enable Monitoring Hooks

Add to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [{
          "type": "command",
          "async": true,
          "timeout": 5,
          "command": "~/.claude/monitoring/hooks/security-audit.sh"
        }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "*",
        "hooks": [{
          "type": "command",
          "async": true,
          "timeout": 5,
          "command": "~/.claude/monitoring/hooks/log-tool-use.sh"
        }]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [{
          "type": "command",
          "async": true,
          "timeout": 10,
          "command": "~/.claude/monitoring/hooks/session-metrics.sh"
        }]
      }
    ]
  }
}
```

### 2. View Logs

```bash
# Tool execution log
tail -f ~/.claude/logs/tool-execution.jsonl | jq

# Security audit log
tail -f ~/.claude/logs/security-audit.jsonl | jq

# Session metrics
cat ~/.claude/logs/session-metrics.jsonl | jq
```

## Hook Scripts

| Script | Event | Purpose |
|--------|-------|---------|
| `log-tool-use.sh` | PostToolUse | Log all tool executions |
| `security-audit.sh` | PreToolUse | Detect suspicious operations |
| `session-metrics.sh` | Stop | Capture session summary |

## Log Formats

### tool-execution.jsonl

```json
{
  "timestamp": "2026-03-30T10:15:30Z",
  "tool": "Bash",
  "session_id": "abc123",
  "agent_id": "main",
  "event": "PostToolUse"
}
```

### security-audit.jsonl

```json
{
  "timestamp": "2026-03-30T10:15:30Z",
  "tool": "Read",
  "session_id": "abc123",
  "alert_level": "high",
  "reason": "Sensitive file read attempt",
  "input": {"file_path": "~/.ssh/id_rsa"}
}
```

### session-metrics.jsonl

```json
{
  "timestamp": "2026-03-30T10:30:00Z",
  "session_id": "abc123",
  "tool_count": 47,
  "error_count": 2,
  "event": "session_end"
}
```

## Alert Levels

| Level | Examples | Action |
|-------|----------|--------|
| `critical` | `rm -rf`, destructive commands | Warning output to stderr |
| `high` | Credential file access | Logged for review |
| `medium` | Data exfiltration patterns | Logged for review |
| `none` | Normal operations | Not logged to security audit |

## External Monitoring

Send events to an external server:

```bash
export CLAUDE_MONITORING_URL="http://localhost:8080"
```

The hooks will POST events to `$CLAUDE_MONITORING_URL/events`.

## Dashboard Setup

For a full real-time dashboard, see [disler/claude-code-hooks-multi-agent-observability](https://github.com/disler/claude-code-hooks-multi-agent-observability):

```bash
git clone https://github.com/disler/claude-code-hooks-multi-agent-observability
cd claude-code-hooks-multi-agent-observability
just start  # or ./scripts/start-system.sh
# Open http://localhost:5173
```

## Analysis Queries

```bash
# Most used tools today
cat ~/.claude/logs/tool-execution.jsonl | \
  jq -r 'select(.timestamp | startswith("2026-03-30")) | .tool' | \
  sort | uniq -c | sort -rn

# Security alerts by level
cat ~/.claude/logs/security-audit.jsonl | \
  jq -r '.alert_level' | sort | uniq -c

# Average tools per session
cat ~/.claude/logs/session-metrics.jsonl | \
  jq -s 'if length > 0 then (map(.tool_count) | add / length) else 0 end'
```

## Log Rotation

Add to crontab for daily rotation:

```bash
0 0 * * * mv ~/.claude/logs/tool-execution.jsonl ~/.claude/logs/tool-execution-$(date +\%Y\%m\%d).jsonl
0 0 * * * mv ~/.claude/logs/security-audit.jsonl ~/.claude/logs/security-audit-$(date +\%Y\%m\%d).jsonl
```
