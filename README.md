<div align="center">

# Claude Code Config

**Production-ready Claude Code configuration for rapid app development.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Agents](https://img.shields.io/badge/Agents-29-purple)](agents/)
[![Commands](https://img.shields.io/badge/Commands-60-green)](commands/)
[![Skills](https://img.shields.io/badge/Skills-60-orange)](skills/)
[![Rules](https://img.shields.io/badge/Rules-65-red)](rules/)
[![Security](https://img.shields.io/badge/Security-7_Layer-critical)](security/SECURITY.md)

29 agents, 60 commands, 60 skills, 65 rules, 7-layer security, intelligent routing, real-time monitoring — ready to use.

Built on [everything-claude-code](https://github.com/affaan-m/everything-claude-code) + [obra/superpowers](https://github.com/obra/superpowers).

</div>

---

## Why This Exists

Claude Code is powerful out of the box, but configuring it for real production work — agents, slash commands, TDD workflows, security, monitoring — takes hours of setup and experimentation.

This repo gives you a **battle-tested configuration** so you can skip the setup and start building:

- **Idea to app in one session** — brainstorm, plan, TDD, review, ship
- **Intelligent routing** — auto-suggests the right agent/workflow based on your prompt
- **Multi-language support** — TypeScript, Python, Go, Rust, Kotlin, Java, C++, Swift, PHP, C#, Perl
- **Security by default** — 7-layer protection based on OWASP Agentic Top 10
- **Real-time visibility** — every tool call logged, security events audited
- **Session continuity** — auto-persists and restores context across conversations

---

## Demo

### Install
![Install Demo](images/install-demo.gif)

### Planning with `/plan`
![Planning](images/plan-command.gif)

### TDD Workflow with `/tdd`
![TDD](images/tdd-workflow.gif)


---

## Quick Start

```bash
git clone https://github.com/Cyvid7-Darus10/claude-code-config.git
cd claude-code-config
./install.sh
```

Restart Claude Code, then try `/plan` or `/tdd`.

---

## What's Inside

| Component | Count | Highlights |
|-----------|-------|------------|
| **Agents** | 29 | `planner`, `architect`, `code-reviewer`, `security-reviewer`, `tdd-guide`, `typescript-reviewer`, `build-error-resolver`, language-specific reviewers |
| **Commands** | 60 | `/plan`, `/tdd`, `/verify`, `/code-review`, `/save-session`, `/resume-session`, `/devfleet`, `/orchestrate`, `/brainstorm` |
| **Skills** | 60 | Brainstorming, writing-plans, executing-plans, git-worktrees, TDD, systematic-debugging, strategic-compact, continuous-learning |
| **Rules** | 65 | Coding standards, patterns, security, testing — common + TypeScript, Swift, Python, Go, Rust, Kotlin, Java, C++, PHP, C#, Perl |
| **Hooks** | 32 | Quality gates, auto-format, type-checking, git push reminders, session persistence, cost tracking, security audit, monitoring |
| **Security** | 7-layer | Deny lists, sandboxing, sanitization, prompt injection defense, supply chain protection, credential protection, observability |
| **Monitoring** | 7 hooks | Tool execution logging, security auditing, session metrics, task routing, session persistence, compaction checkpoints |
| **MCP** | 1 | GitHub MCP server (manage repos, PRs, issues via conversation) |
| **Sounds** | 3 | Notification sounds for task completion (macOS) |

---

## Architecture

```mermaid
graph TB
    subgraph Input["User Input"]
        CMD["/plan, /tdd, /verify, ..."]
        CHAT["Natural language"]
    end

    subgraph Router["Intelligent Routing"]
        TR["Task Router"]
        SR["Session Restore"]
    end

    subgraph Core["Claude Code Engine"]
        direction TB
        AGENTS["29 Agents"]
        SKILLS["60 Skills"]
        RULES["65 Rules"]
    end

    subgraph Quality["Quality Gates"]
        direction TB
        HOOKS["32 Hooks"]
        SEC["7-Layer Security"]
        MON["Real-Time Monitoring"]
    end

    subgraph Persistence["Session Continuity"]
        CP["Compaction Checkpoints"]
        SP["Session Persistence"]
    end

    subgraph Output["Output"]
        CODE["Code"]
        TESTS["Tests"]
        DOCS["Docs"]
        PR["PRs"]
    end

    CMD --> Router
    CHAT --> Router
    Router --> Core
    Core --> Quality
    Quality --> Output
    Quality --> Persistence
    AGENTS <--> SKILLS
    AGENTS <--> RULES
    HOOKS --> MON
    HOOKS --> SEC
```

---

## Key Workflows

### Idea to App

```mermaid
graph LR
    A["/plan"] --> B["Brainstorming Skill"]
    B --> C["Writing-Plans Skill"]
    C --> D["/tdd"]
    D --> E["Ship"]

    style A fill:#6366f1,color:#fff
    style B fill:#8b5cf6,color:#fff
    style C fill:#a78bfa,color:#fff
    style D fill:#6366f1,color:#fff
    style E fill:#22c55e,color:#fff
```

### Development Loop

```mermaid
graph LR
    A["/tdd"] --> B["Write Tests"]
    B --> C["Implement"]
    C --> D["/verify"]
    D --> E["/code-review"]
    E --> F["Ship"]
    F -.-> A

    style A fill:#6366f1,color:#fff
    style F fill:#22c55e,color:#fff
```

### Multi-Agent

```mermaid
graph LR
    A["/devfleet"] --> B["Agent 1: Frontend"]
    A --> C["Agent 2: Backend"]
    A --> D["Agent 3: Tests"]
    B --> E["/orchestrate"]
    C --> E
    D --> E
    E --> F["Merge & Ship"]

    style A fill:#6366f1,color:#fff
    style E fill:#f59e0b,color:#000
    style F fill:#22c55e,color:#fff
```

### Intelligent Task Routing

Prompts are automatically analyzed and routed to the best agent/workflow:

```mermaid
graph LR
    A["User Prompt"] --> B["Task Router"]
    B -->|"build me..."| C["/plan → planner"]
    B -->|"fix this bug..."| D["/tdd → tdd-guide"]
    B -->|"review my code..."| E["code-reviewer"]
    B -->|"security audit..."| F["security-reviewer"]
    B -->|"build error..."| G["build-error-resolver"]

    style A fill:#f59e0b,color:#000
    style B fill:#6366f1,color:#fff
    style C fill:#22c55e,color:#fff
    style D fill:#22c55e,color:#fff
    style E fill:#22c55e,color:#fff
    style F fill:#22c55e,color:#fff
    style G fill:#22c55e,color:#fff
```

Routes detected: `plan-first`, `architecture`, `debug`, `tdd`, `security`, `review`, `refactor`, `build-fix`, `docs`, `performance`

### Session Continuity

Sessions are automatically persisted and restored — no manual `/save-session` needed:

```mermaid
graph LR
    A["Session Start"] --> B["session-restore.sh"]
    B --> C["Load Previous Context"]
    C --> D["Work..."]
    D --> E["Context Compaction"]
    E --> F["pre-compact-checkpoint.sh"]
    F --> D
    D --> G["Session End"]
    G --> H["session-persist.sh"]

    style B fill:#3b82f6,color:#fff
    style F fill:#f59e0b,color:#000
    style H fill:#22c55e,color:#fff
```

### Session Management

```mermaid
graph LR
    A["/save-session"] --> B["Persist Context"]
    B --> C["New Conversation"]
    C --> D["/resume-session"]
    D --> E["Continue Where You Left Off"]

    style A fill:#6366f1,color:#fff
    style D fill:#6366f1,color:#fff
```

---

## 7-Layer Security

Production-grade security based on [OWASP Agentic Top 10](https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/):

| Layer | Protection | What It Does |
|:-----:|------------|--------------|
| 1 | **Attack Surface** | Minimize access points, restrict `allowedTools` |
| 2 | **Sandboxing** | Path-based deny lists for `~/.ssh`, `~/.aws`, credentials |
| 3 | **Sanitization** | Audit external links, detect hidden text |
| 4 | **Prompt Injection** | Block malicious skills, rules, hooks, CLAUDE.md |
| 5 | **Supply Chain** | Pin MCP versions, verify packages |
| 6 | **Credentials** | Separate agent accounts, block env harvesting |
| 7 | **Observability** | Real-time monitoring, security audit logs |

```bash
# Quick security scan
npx ecc-agentshield scan
```

See [security/SECURITY.md](security/SECURITY.md) for the full guide.

---

## Real-Time Monitoring

Track all agent activity with structured JSONL logs:

```bash
# Live tool execution log
tail -f ~/.claude/logs/tool-execution.jsonl | jq

# Live security alerts
tail -f ~/.claude/logs/security-audit.jsonl | jq

# Task routing decisions
tail -f ~/.claude/logs/task-router.jsonl | jq

# Session summary metrics
cat ~/.claude/logs/session-metrics.jsonl | jq
```

```mermaid
graph LR
    A["User Prompt"] --> R["task-router.sh"]
    A --> B["Tool Call"]
    B --> C["log-tool-use.sh"]
    B --> D["security-audit.sh"]
    E["Compaction"] --> F["pre-compact-checkpoint.sh"]
    G["Session End"] --> H["session-metrics.sh"]
    G --> I["session-persist.sh"]
    J["Session Start"] --> K["session-restore.sh"]

    R --> L["task-router.jsonl"]
    C --> M["tool-execution.jsonl"]
    D --> N["security-audit.jsonl"]
    H --> O["session-metrics.jsonl"]
    F --> P["checkpoints/"]
    I --> Q["sessions/"]

    style L fill:#f59e0b,color:#000
    style M fill:#3b82f6,color:#fff
    style N fill:#ef4444,color:#fff
    style O fill:#22c55e,color:#fff
    style P fill:#8b5cf6,color:#fff
    style Q fill:#8b5cf6,color:#fff
```

See [monitoring/README.md](monitoring/README.md) for dashboard setup.

---

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

---

## MCP Servers

Pre-configured MCP servers are installed to `~/.claude/mcp.json`:

| MCP | What it does | Setup |
|-----|-------------|-------|
| **context7** | Live docs lookup for any library | None — works immediately |
| **playwright** | Browser automation & testing | None — works immediately |
| **magic** | Magic UI components for React | None — works immediately |
| **github** | Manage repos, PRs, issues | GitHub token + Docker |

### GitHub MCP

**Prerequisites:** Docker running (`docker ps` to verify)

```bash
# Get your token
gh auth token
# OR create one at https://github.com/settings/tokens
# Required scopes: repo, read:user, read:org

# Add token to config
# Edit ~/.claude/mcp.json and replace <YOUR_GITHUB_TOKEN>
```

<details>
<summary><b>Optional: Claude Mission Control (real-time agent dashboard)</b></summary>

[Claude Mission Control](https://github.com/Cyvid7-Darus10/claude-mission-control) is a Palantir-style command center that shows what your Claude Code agents are doing in real-time. It connects via hooks — every tool call, file edit, and bash command is streamed to the dashboard.

**Use it when you need:**
- See all active agents and what they're working on at a glance
- Assign missions with dependency tracking ("tests wait on API")
- Send instructions to running agents from the dashboard
- Activity timeline with stuck agent and loop detection
- Mission history that survives conversation restarts

```bash
# 1. Clone and install
git clone https://github.com/Cyvid7-Darus10/claude-mission-control.git ~/claude-mission-control
cd ~/claude-mission-control && npm install && npm rebuild better-sqlite3

# 2. Install hooks into Claude Code
npx tsx src/index.ts install

# 3. Start the dashboard
npx tsx src/index.ts
# Open http://localhost:4280
```

Requires Node.js 18+. No Python, no Docker.

</details>

---

## Sound Notifications

Hooks play sounds on task completion. macOS only (uses `afplay`).

| Sound | Event | File |
|-------|-------|------|
| "Jobs done" | Session stops | `sounds/jobs-done.mp3` |
| "Work work" | Notifications | `sounds/work-work.mp3` |
| "Quest complete" | (Available) | `sounds/quest-complete.mp3` |

<details>
<summary><b>Cross-platform setup</b></summary>

- **Linux:** Replace `afplay` with `paplay` or `aplay` in `settings.json`
- **Windows/WSL:** Replace with `powershell.exe -c (New-Object Media.SoundPlayer 'path').PlaySync()`
- **Disable:** Remove the `hooks` section from `settings.json`

</details>

---

## Project Structure

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
│   └── SECURITY.md
├── monitoring/          # Real-time observability
│   ├── hooks/           # 7 monitoring hooks
│   │   ├── task-router.sh         # Intelligent prompt → agent routing
│   │   ├── session-restore.sh     # Restore context on SessionStart
│   │   ├── session-persist.sh     # Auto-save state on Stop
│   │   ├── pre-compact-checkpoint.sh # Checkpoint before compaction
│   │   ├── log-tool-use.sh        # Tool execution logging
│   │   ├── security-audit.sh      # Security event detection
│   │   └── session-metrics.sh     # Session summary metrics
│   └── README.md
├── hooks/               # Hook configurations (hooks.json)
├── scripts/hooks/       # 29 hook scripts (quality gates, formatting, etc.)
├── sounds/              # Notification MP3s
├── mcp-configs/         # Reference MCP server configurations
├── images/              # Screenshots and diagrams
├── settings.json        # Claude Code settings with security deny lists
├── mcp.json             # GitHub MCP server config (add your token)
├── install.sh           # Installer (supports selective install/uninstall)
├── AGENTS.md            # Agent specifications and usage guide
├── LICENSE              # MIT
└── README.md
```

---

## Customization

<details>
<summary><b>Add your own command</b></summary>

Create `~/.claude/commands/my-command.md`:

```markdown
---
description: What my command does
---
Instructions for Claude when this command is invoked...
```

</details>

<details>
<summary><b>Add your own skill</b></summary>

Create `~/.claude/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: When to activate this skill
---
Domain knowledge and instructions...
```

</details>

<details>
<summary><b>Add your own agent</b></summary>

Create `~/.claude/agents/my-agent.md`:

```markdown
---
name: my-agent
description: What this agent specializes in
tools: ["Read", "Grep", "Glob", "Bash"]
model: sonnet
---
System prompt for the agent...
```

</details>

---

## Credits

- **[everything-claude-code](https://github.com/affaan-m/everything-claude-code)** by Affaan Mustafa — Agents, commands, rules, hooks, scripts, security guide. The foundation.
- **[superpowers](https://github.com/obra/superpowers)** by Jesse Vincent — Brainstorming, planning, git worktrees, TDD skills. The ideation workflow.
- **[claude-code-hooks-multi-agent-observability](https://github.com/disler/claude-code-hooks-multi-agent-observability)** by disler — Monitoring patterns and dashboard inspiration.
- **[ruflo](https://github.com/ruvnet/ruflo)** by RuvNet — Intelligent task routing, session persistence, and pre-compaction checkpoint patterns.

---

## License

MIT — See [LICENSE](LICENSE)

---

<div align="center">

Made by [Cyrus David Pastelero](https://github.com/Cyvid7-Darus10)

If this helped you, consider giving it a star!

</div>
