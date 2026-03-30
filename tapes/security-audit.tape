# Security Audit Logs Demo
# Records: viewing real-time security audit logs

Output images/security-audit.gif
Set FontSize 16
Set Width 1200
Set Height 800
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 50ms
Set Shell "zsh"

# Show the security audit log with formatted JSON
Type "echo 'Viewing security audit logs...'"
Enter
Sleep 1s

Type "cat ~/.claude/logs/security-audit.jsonl 2>/dev/null | tail -20 | jq '.' 2>/dev/null || echo '{\"timestamp\": \"2026-03-30T10:15:23Z\", \"alert_level\": \"warning\", \"event\": \"suspicious_path_access\", \"tool\": \"Read\", \"target\": \"/etc/passwd\", \"session_id\": \"abc123\"}' | jq '.'"
Enter
Sleep 3s

Type "echo ''"
Enter
Type "echo 'Viewing tool execution log...'"
Enter
Sleep 1s

Type "cat ~/.claude/logs/tool-execution.jsonl 2>/dev/null | tail -10 | jq '.' 2>/dev/null || echo '{\"timestamp\": \"2026-03-30T10:14:55Z\", \"tool\": \"Edit\", \"file\": \"src/api/routes.ts\", \"duration_ms\": 45, \"session_id\": \"abc123\"}' | jq '.'"
Enter
Sleep 3s

Type "echo ''"
Enter
Type "echo 'Viewing session metrics...'"
Enter
Sleep 1s

Type "cat ~/.claude/logs/session-metrics.jsonl 2>/dev/null | tail -5 | jq '.' 2>/dev/null || echo '{\"timestamp\": \"2026-03-30T10:20:00Z\", \"session_id\": \"abc123\", \"duration_min\": 12, \"tool_calls\": 47, \"files_modified\": 8, \"tests_passed\": 23}' | jq '.'"
Enter
Sleep 3s
