# Claude Code Config

Production-ready Claude Code configuration for rapid app development. 29 agents, 60 commands, 60 skills, 65 rules, 7-layer security, real-time monitoring — ready to use.

Built on [everything-claude-code](https://github.com/affaan-m/everything-claude-code) + [obra/superpowers](https://github.com/obra/superpowers).

## Quick Start

```bash
git clone https://github.com/Cyvid7-Darus10/claude-code-config.git
cd claude-code-config
./install.sh
```

Restart Claude Code, then try `/plan` or `/tdd`.

## What's Inside

| Component | Count | Highlights |
|---|---|---|
| **Agents** | 29 | `planner`, `architect`, `code-reviewer`, `security-reviewer`, `tdd-guide`, `typescript-reviewer`, `build-error-resolver`, language-specific reviewers |
| **Commands** | 60 | `/plan`, `/tdd`, `/verify`, `/code-review`, `/save-session`, `/resume-session`, `/devfleet`, `/orchestrate`, `/brainstorm` |
| **Skills** | 60 | Brainstorming, writing-plans, executing-plans, git-worktrees, TDD, systematic-debugging, strategic-compact, continuous-learning |
| **Rules** | 65 | Coding standards, patterns, security, testing — common + TypeScript, Swift, Python, Go, Rust, Kotlin, Java, C++, PHP, C#, Perl |
| **Hooks** | 32 | Quality gates, auto-format, type-checking, git push reminders, session persistence, cost tracking, **security audit**, **monitoring** |
| **Security** | 7-layer | Deny lists, sandboxing, sanitization, prompt injection defense, supply chain protection, credential protection, observability |
| **Monitoring** | 3 hooks | Tool execution logging, security auditing, session metrics |
| **MCP** | 1 | GitHub MCP server (manage repos, PRs, issues via conversation) |
| **Sounds** | 3 | Notification sounds for task completion (macOS) |

## 7-Layer Security

Production-grade security based on [OWASP Agentic Top 10](https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/):

| Layer | Protection |
|-------|------------|
| 1. Attack Surface | Minimize access points, restrict `allowedTools` |
| 2. Sandboxing | Path-based deny lists for `~/.ssh`, `~/.aws`, credentials |
| 3. Sanitization | Audit external links, detect hidden text |
| 4. Prompt Injection | Block malicious skills, rules, hooks, CLAUDE.md |
| 5. Supply Chain | Pin MCP versions, verify packages |
| 6. Credentials | Separate agent accounts, block env harvesting |
| 7. Observability | Real-time monitoring, security audit logs |

**Quick security scan:**

```bash
npx ecc-agentshield scan
```

See [security/SECURITY.md](security/SECURITY.md) for the full guide.

## Real-Time Monitoring

Track all agent activity with monitoring hooks:

```bash
# View tool execution log
tail -f ~/.claude/logs/tool-execution.jsonl | jq

# View security alerts
tail -f ~/.claude/logs/security-audit.jsonl | jq

# View session metrics
cat ~/.claude/logs/session-metrics.jsonl | jq
```

See [monitoring/README.md](monitoring/README.md) for dashboard setup.

## Selective Install

Install only what you need:

```bash
./install.sh agents skills          # Just agents and skills
./install.sh commands               # Just slash commands
./install.sh security monitoring    # Just security and monitoring
./install.sh --dry-run              # Preview what would be installed
./install.sh --uninstall            # Remove everything
./install.sh --uninstall skills     # Remove only skills
```

Available components: `agents`, `commands`, `skills`, `rules`, `hooks`, `sounds`, `mcp`, `security`, `monitoring`

## Key Workflows

### Idea to App

```
/plan → Brainstorming skill refines your idea → Writing-plans creates actionable steps → /tdd builds it
```

### Development Loop

```
/tdd → Write tests first → Implement → /verify → /code-review → Ship
```

### Multi-Agent

```
/devfleet → Parallel agents work on different parts → /orchestrate coordinates them
```

### Session Management

```
/save-session → Persist context → (new conversation) → /resume-session → Continue where you left off
```

## MCP Server Setup

The GitHub MCP server lets Claude manage repos, PRs, and issues directly.

**Prerequisites:** Docker running (`docker ps` to verify)

```bash
# Get your token
gh auth token
# OR create one at https://github.com/settings/tokens
# Required scopes: repo, read:user, read:org

# Add token to config
# Edit ~/.claude/mcp.json and replace <YOUR_GITHUB_TOKEN>
```

## Sound Notifications

Hooks play sounds on task completion. macOS only (uses `afplay`).

| Sound | Event | File |
|---|---|---|
| "Jobs done" | Session stops | `sounds/jobs-done.mp3` |
| "Work work" | Notifications | `sounds/work-work.mp3` |
| "Quest complete" | (Available) | `sounds/quest-complete.mp3` |

**Linux:** Replace `afplay` with `paplay` or `aplay` in `settings.json`.
**Windows/WSL:** Replace with `powershell.exe -c (New-Object Media.SoundPlayer 'path').PlaySync()`.
**Disable:** Remove the `hooks` section from `settings.json`.

## Structure

```
claude-code-config/
├── agents/              # 29 specialized subagents
│   ├── planner.md       # Plans and breaks down tasks
│   ├── architect.md     # System design decisions
│   ├── code-reviewer.md # Code quality review
│   ├── security-reviewer.md # Security analysis
│   ├── tdd-guide.md     # Test-driven development
│   └── ...
├── commands/            # 60 slash commands (/plan, /tdd, /verify, ...)
├── skills/              # 60 workflow skills
│   ├── brainstorming/   # Refine rough ideas into specs
│   ├── writing-plans/   # Create actionable plans
│   ├── executing-plans/ # Execute plans step by step
│   ├── using-git-worktrees/ # Parallel development
│   ├── strategic-compact/   # Context management
│   └── ...
├── rules/               # 65 coding rules
│   ├── common/          # Universal (security, testing, git, patterns)
│   ├── typescript/      # TypeScript-specific
│   ├── swift/           # Swift-specific
│   └── ...              # + python, golang, rust, kotlin, java, cpp, php, csharp, perl
├── security/            # 7-layer security framework
│   └── SECURITY.md      # Full security guide
├── monitoring/          # Real-time observability
│   ├── hooks/           # Monitoring hook scripts
│   │   ├── log-tool-use.sh     # Log all tool executions
│   │   ├── security-audit.sh   # Detect suspicious operations
│   │   └── session-metrics.sh  # Capture session metrics
│   └── README.md        # Monitoring setup guide
├── hooks/               # Hook configurations (hooks.json)
├── scripts/hooks/       # 29 hook scripts (quality gates, formatting, etc.)
├── sounds/              # Notification MP3s
├── mcp-configs/         # Reference MCP server configurations
├── settings.json        # Claude Code settings with security deny lists
├── mcp.json             # GitHub MCP server config (add your token)
├── install.sh           # Installer (supports selective install/uninstall)
├── AGENTS.md            # Agent specifications and usage guide
├── LICENSE              # MIT
└── README.md
```

## Customization

**Add your own command:** Create `~/.claude/commands/my-command.md` with:
```markdown
---
description: What my command does
---
Instructions for Claude when this command is invoked...
```

**Add your own skill:** Create `~/.claude/skills/my-skill/SKILL.md` with:
```markdown
---
name: my-skill
description: When to activate this skill
---
Domain knowledge and instructions...
```

**Add your own agent:** Create `~/.claude/agents/my-agent.md` with:
```markdown
---
name: my-agent
description: What this agent specializes in
tools: ["Read", "Grep", "Glob", "Bash"]
model: sonnet
---
System prompt for the agent...
```

## Credits

- **[everything-claude-code](https://github.com/affaan-m/everything-claude-code)** by Affaan Mustafa — Agents, commands, rules, hooks, scripts, security guide. The foundation.
- **[superpowers](https://github.com/obra/superpowers)** by Jesse Vincent — Brainstorming, planning, git worktrees, TDD skills. The ideation workflow.
- **[claude-code-hooks-multi-agent-observability](https://github.com/disler/claude-code-hooks-multi-agent-observability)** by disler — Monitoring patterns and dashboard inspiration.

## License

MIT - See [LICENSE](LICENSE)

## Author

Cyrus David Pastelero ([@Cyvid7-Darus10](https://github.com/Cyvid7-Darus10))
