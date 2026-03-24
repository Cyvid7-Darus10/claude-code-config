# Claude Code Config

My personal Claude Code configuration for building apps fast. Open-sourced so others can use it as a starting point.

## What's Inside

| Component | Count | Description |
|---|---|---|
| **Agents** | 29 | Specialized subagents (code review, architecture, security, TDD, language-specific reviewers & build resolvers) |
| **Commands** | 60 | Slash commands (`/plan`, `/tdd`, `/verify`, `/code-review`, `/save-session`, `/devfleet`, etc.) |
| **Skills** | 60 | Workflow skills (brainstorming, strategic-compact, continuous-learning, TDD, git worktrees, debugging, etc.) |
| **Rules** | 65 | Coding standards, patterns, security, and testing rules (common + TypeScript, Swift, and more) |
| **Hooks** | 2 | Sound notifications on task completion and notifications |
| **Sounds** | 3 | Warcraft-inspired notification sounds (jobs-done, work-work, quest-complete) |
| **Scripts** | 29 | Hook scripts and utilities |
| **MCP Configs** | 1 | GitHub MCP server (Docker-based) |

## Sources & Credits

This config is built on top of two excellent open-source projects:

- **[everything-claude-code](https://github.com/affaan-m/everything-claude-code)** by Affaan Mustafa — Agents, commands, skills, rules, hooks, and scripts. The foundation of this setup.
- **[superpowers](https://github.com/obra/superpowers)** by Jesse Vincent — Brainstorming, planning, git worktrees, TDD, and code review skills. The ideation-to-execution workflow.

## Installation

### Quick Install (copy to ~/.claude/)

```bash
git clone https://github.com/Cyvid7-Darus10/claude-code-config.git
cd claude-code-config
./install.sh
```

### Manual Install

Copy the directories you want into `~/.claude/`:

```bash
# Clone
git clone https://github.com/Cyvid7-Darus10/claude-code-config.git
cd claude-code-config

# Copy everything
cp -r agents/ ~/.claude/agents/
cp -r commands/ ~/.claude/commands/
cp -r skills/ ~/.claude/skills/
cp -r rules/ ~/.claude/rules/
cp -r hooks/ ~/.claude/hooks/
cp -r scripts/ ~/.claude/scripts/
cp -r sounds/ ~/.claude/sounds/
cp settings.json ~/.claude/settings.json
cp mcp.json ~/.claude/mcp.json
```

### MCP Server Setup

The GitHub MCP server requires Docker and a GitHub token:

1. Make sure Docker is running
2. Get your GitHub token: `gh auth token` or create one at [github.com/settings/tokens](https://github.com/settings/tokens)
3. Edit `~/.claude/mcp.json` and replace `<YOUR_GITHUB_TOKEN>` with your token

### Sound Notifications

The hooks play sound effects on macOS using `afplay`. The sound paths in `settings.json` point to `~/.claude/sounds/`. If you're on Linux, swap `afplay` for `aplay` or `paplay`.

## Structure

```
claude-code-config/
├── agents/              # 29 specialized subagents
├── commands/            # 60 slash commands
├── skills/              # 60 workflow skills
├── rules/               # 65 coding rules (common + per-language)
│   ├── common/          # Universal rules
│   ├── typescript/      # TypeScript-specific
│   ├── swift/           # Swift-specific
│   └── .../             # Other languages
├── hooks/               # Hook configurations
├── scripts/             # Hook scripts and utilities
├── sounds/              # Notification sound effects
├── mcp-configs/         # MCP server reference configs
├── settings.json        # Claude Code settings (hooks, plugins)
├── mcp.json             # MCP server config (GitHub)
├── AGENTS.md            # Agent specifications
└── README.md
```

## Key Workflows

- `/plan` — Structure an idea into an actionable development plan
- `/tdd` — Test-driven development workflow
- `/verify` — Verification loop before marking work complete
- `/code-review` — Automated code review via subagent
- `/save-session` / `/resume-session` — Persist and restore session context
- `/devfleet` — Multi-agent parallel execution
- **Brainstorming skill** — Refines rough ideas through structured questions
- **Strategic compact skill** — Better context/memory management

## License

MIT

## Author

Cyrus David Pastelero
