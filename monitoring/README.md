# Claude Code Monitoring

Real-time observability for Claude Code agents. Track tool usage, security events, session metrics, intelligent routing, and session continuity.

## Quick Start

### 1. Enable Monitoring Hooks

Add to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "*",
        "hooks": [{
          "type": "command",
          "timeout": 5,
          "command": "\"$HOME/.claude/monitoring/hooks/task-router.sh\""
        }],
        "description": "Intelligent task routing"
      }
    ],
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [{
          "type": "command",
          "timeout": 5,
          "command": "\"$HOME/.claude/monitoring/hooks/session-restore.sh\""
        }],
        "description": "Restore previous session context"
      }
    ],
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [{
          "type": "command",
          "async": true,
          "timeout": 5,
          "command": "\"$HOME/.claude/monitoring/hooks/security-audit.sh\""
        }],
        "description": "Security audit"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "*",
        "hooks": [{
          "type": "command",
          "async": true,
          "timeout": 5,
          "command": "\"$HOME/.claude/monitoring/hooks/log-tool-use.sh\""
        }],
        "description": "Log tool executions"
      }
    ],
    "PreCompact": [
      {
        "matcher": "*",
        "hooks": [{
          "type": "command",
          "async": true,
          "timeout": 10,
          "command": "\"$HOME/.claude/monitoring/hooks/pre-compact-checkpoint.sh\""
        }],
        "description": "Checkpoint before compaction"
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [{
          "type": "command",
          "async": true,
          "timeout": 10,
          "command": "\"$HOME/.claude/monitoring/hooks/session-metrics.sh\""
        }],
        "description": "Session metrics"
      },
      {
        "matcher": "*",
        "hooks": [{
          "type": "command",
          "async": true,
          "timeout": 10,
          "command": "\"$HOME/.claude/monitoring/hooks/session-persist.sh\""
        }],
        "description": "Auto-save session state"
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

# Task routing decisions
tail -f ~/.claude/logs/task-router.jsonl | jq

# Session metrics
cat ~/.claude/logs/session-metrics.jsonl | jq
```

## Hook Scripts

| Script | Event | Purpose |
|--------|-------|---------|
| `task-router.sh` | UserPromptSubmit | Route prompts to the right agent/workflow |
| `session-restore.sh` | SessionStart | Restore previous session context |
| `security-audit.sh` | PreToolUse | Detect suspicious operations |
| `log-tool-use.sh` | PostToolUse | Log all tool executions |
| `pre-compact-checkpoint.sh` | PreCompact | Checkpoint before context compaction |
| `session-metrics.sh` | Stop | Capture session summary |
| `session-persist.sh` | Stop | Auto-save session state |

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

### task-router.jsonl

```json
{
  "timestamp": "2026-04-05T10:15:30Z",
  "session_id": "abc123",
  "route": "debug",
  "suggested_agent": "tdd-guide",
  "confidence": "high",
  "prompt_preview": "fix the login bug where users get a 500 error..."
}
```

### Checkpoints (Pre-Compaction)

Saved to `~/.claude/checkpoints/checkpoint-<session>-<timestamp>.json`:

```json
{
  "timestamp": "2026-04-05T11:00:00Z",
  "session_id": "abc123",
  "event": "pre_compact_checkpoint",
  "working_directory": "/Users/you/project",
  "git": {
    "branch": "feat/login-fix",
    "modified_files": ["src/auth.ts", "tests/auth.test.ts"],
    "staged_files": []
  },
  "messages_before_compact": 142
}
```

### Session State (Auto-Persisted)

Saved to `~/.claude/sessions/session-<id>.json`:

```json
{
  "timestamp": "2026-04-05T11:30:00Z",
  "session_id": "abc123",
  "working_directory": "/Users/you/project",
  "git": {
    "branch": "feat/login-fix",
    "modified_files": ["src/auth.ts"],
    "staged_files": ["src/auth.ts"],
    "recent_commits": ["a1b2c3d fix: resolve 500 on login"]
  },
  "activity": {
    "tool_count": 47
  }
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
  jq -r 'select(.timestamp | startswith("2026-04-05")) | .tool' | \
  sort | uniq -c | sort -rn

# Security alerts by level
cat ~/.claude/logs/security-audit.jsonl | \
  jq -r '.alert_level' | sort | uniq -c

# Average tools per session
cat ~/.claude/logs/session-metrics.jsonl | \
  jq -s 'if length > 0 then (map(.tool_count) | add / length) else 0 end'

# Most common task routes
cat ~/.claude/logs/task-router.jsonl | \
  jq -r '.route' | sort | uniq -c | sort -rn

# Agent suggestions by confidence
cat ~/.claude/logs/task-router.jsonl | \
  jq -r '[.suggested_agent, .confidence] | join(" ")' | sort | uniq -c | sort -rn

# List saved checkpoints
ls -lt ~/.claude/checkpoints/ | head -10

# Recent sessions
ls -lt ~/.claude/sessions/ | head -10
```

## Log Rotation

Add to crontab for daily rotation:

```bash
0 0 * * * mv ~/.claude/logs/tool-execution.jsonl ~/.claude/logs/tool-execution-$(date +\%Y\%m\%d).jsonl
0 0 * * * mv ~/.claude/logs/security-audit.jsonl ~/.claude/logs/security-audit-$(date +\%Y\%m\%d).jsonl
```
