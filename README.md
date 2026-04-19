<div align="center">

# Claude Code Config

**Production-ready Claude Code configuration for rapid app development.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Agents](https://img.shields.io/badge/Agents-29-purple)](agents/)
[![Commands](https://img.shields.io/badge/Commands-60-green)](commands/)
[![Skills](https://img.shields.io/badge/Skills-62-orange)](skills/)
[![Rules](https://img.shields.io/badge/Rules-66-red)](rules/)
[![Zero-Dep Hooks](https://img.shields.io/badge/Hooks-Zero--Dep-blueviolet)](monitoring/hooks/)

29 agents · 60 commands · 62 skills · 66 rules · zero-dependency hooks · intelligent routing.

Built on [everything-claude-code](https://github.com/affaan-m/everything-claude-code) + [obra/superpowers](https://github.com/obra/superpowers).

</div>

---

## Install

**One-liner** (clones to `~/.local/share/claude-code-config`, installs the default zero-dep set):

```bash
curl -fsSL https://raw.githubusercontent.com/Cyvid7-Darus10/claude-code-config/main/setup.sh | bash
```

Or pass flags through:

```bash
curl -fsSL https://raw.githubusercontent.com/Cyvid7-Darus10/claude-code-config/main/setup.sh | bash -s -- --minimal
curl -fsSL https://raw.githubusercontent.com/Cyvid7-Darus10/claude-code-config/main/setup.sh | bash -s -- --full
curl -fsSL https://raw.githubusercontent.com/Cyvid7-Darus10/claude-code-config/main/setup.sh | bash -s -- --dry-run
```

**Manual clone** (if you'd rather inspect before running):

```bash
git clone https://github.com/Cyvid7-Darus10/claude-code-config.git
cd claude-code-config
./install.sh
```

Restart Claude Code. Try `/plan`, `/tdd`, `/verify`, or `/code-review`.

**Minimal install** (agents, commands, skills, rules only — no hooks):

```bash
./install.sh --minimal
```

**Full install** (adds Node.js-based quality-gate hooks — requires Node 18+):

```bash
./install.sh --full
```

**Selective install / uninstall**:

```bash
./install.sh agents skills              # Install only these two components
./install.sh --dry-run                  # Preview without touching disk
./install.sh --uninstall                # Remove everything the installer placed
./install.sh --uninstall skills         # Remove just one component
```

Available components: `agents`, `commands`, `skills`, `rules`, `monitoring` (zero-dep lifecycle hooks), `mcp`, `sounds`, `security` (docs), `hooks` (opt-in, needs Node.js).

**Update**: re-run the same one-liner — `setup.sh` pulls the latest commit before installing. Your `settings.json` and `mcp.json` are never overwritten; everything else is backed up to `~/.claude/backups/pre-install-<timestamp>/` before install.

### Requirements

| | Default install | `--full` install |
|---|---|---|
| bash 3.2+ | Required | Required |
| git | Only for `git clone` / updates | Only for `git clone` / updates |
| Node.js 18+ | Not needed | Required (for `hooks/` quality gates) |
| jq / Python | Never | Never |

The default install is **zero runtime dependencies** — the 4 lifecycle hooks are pure bash. The Node-based quality gates in `hooks/` are opt-in.

---

## What You Get

**Default install** (zero runtime dependencies):

| Component | Count | Examples |
|-----------|------:|----------|
| Agents | 29 | `planner`, `architect`, `code-reviewer`, `security-reviewer`, `tdd-guide`, `build-error-resolver`, language-specific reviewers |
| Slash commands | 60 | `/plan`, `/tdd`, `/verify`, `/code-review`, `/brainstorm`, `/save-session`, `/resume-session` |
| Skills | 62 | brainstorming, writing-plans, TDD, systematic-debugging, **systematic-reasoning**, **backend-judgement**, strategic-compact |
| Coding rules | 66 | Common + TypeScript, Python, Go, Rust, Kotlin, Java, C++, Swift, PHP, C#, Perl + **multi-repo-consistency** |
| Lifecycle hooks | 4 | SessionStart restore · UserPromptSubmit router · PreCompact checkpoint · Stop persist — pure bash |
| MCP servers | 4 | `context7` (docs), `playwright`, `magic` (UI), `github` (token + Docker required) |

**Opt-in with `--full`** (requires Node.js 18+):

| Component | Count | Examples |
|-----------|------:|----------|
| Quality hooks | 28 | Formatters, linters, type-checks, git-push reminders, PR logger, build analysis |

---

## Workflows

- **Idea → plan → TDD → ship** — `/plan` uses the brainstorming skill, `/tdd` runs RED-GREEN-REFACTOR.
- **Intelligent routing** — the `task-router` hook analyses every prompt; bug fixes, build errors, security tasks, and refactors get a one-line hint suggesting the right agent.
- **Session continuity** — `session-restore` on start, `pre-compact-checkpoint` before compaction, `session-persist` on stop. Pick up where you left off across restarts.

---

## MCP Servers

Edit `~/.claude/mcp.json` to enable.

| Server | Purpose | Setup |
|--------|---------|-------|
| `context7` | Live library/API docs | None — zero config |
| `playwright` | Browser automation | None — zero config |
| `magic` | Magic UI components | None — zero config |
| `github` | Manage repos/PRs | GitHub token + Docker |

GitHub setup:

```bash
gh auth token    # paste into ~/.claude/mcp.json, replace <YOUR_GITHUB_TOKEN>
```

---

## Security

Deny-list defaults protect credentials and destructive commands — see `settings.json`. Permissions block:

- Reads of `~/.ssh`, `~/.aws`, `.env`, `credentials*`, `secrets*`
- `rm -rf /`, `rm -rf ~`, `rm -rf /*`
- `curl|bash`, `wget|bash`, `curl -d` exfiltration patterns
- `git remote add`, `npm publish`, `nc`/`netcat`

See [security/SECURITY.md](security/SECURITY.md) for the full threat model.

---

## Customisation

<details>
<summary>Add a command</summary>

Create `~/.claude/commands/my-command.md`:

```markdown
---
description: What my command does
---
Instructions for Claude when this command is invoked.
```

</details>

<details>
<summary>Add a skill</summary>

Create `~/.claude/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: When to activate this skill
---
Domain knowledge and instructions.
```

</details>

<details>
<summary>Add an agent</summary>

Create `~/.claude/agents/my-agent.md`:

```markdown
---
name: my-agent
description: What this agent specializes in
tools: ["Read", "Grep", "Glob", "Bash"]
model: sonnet
---
System prompt for the agent.
```

</details>

<details>
<summary>Add / remove lifecycle hooks</summary>

Edit `~/.claude/settings.json` under `hooks.{SessionStart,UserPromptSubmit,PreToolUse,PostToolUse,PreCompact,Stop,Notification}`.

The default config avoids `PreToolUse` and `PostToolUse` because they fire on **every** tool call and can add several seconds of latency per turn. If you add them, keep them small, set `timeout` low, and prefer `async: true`.

</details>

---

## Recommended companion plugins

After installing this config, layer these official marketplaces on top — they're curated, actively maintained, and complement our agents without duplicating them:

```bash
# In Claude Code:
/plugin install superpowers@claude-plugins-official
/plugin marketplace add trailofbits/skills
/plugin marketplace add wshobson/agents
```

| Plugin | Why add it | Source |
|--------|------------|--------|
| **superpowers** | TDD methodology, brainstorming, systematic-debugging — officially accepted into Anthropic marketplace Jan 2026 | [obra/superpowers](https://github.com/obra/superpowers) |
| **Trail of Bits skills** | Pro-grade security auditing: static analysis, variant analysis, differential review, supply-chain risk, constant-time analysis | [trailofbits/skills](https://github.com/trailofbits/skills) |
| **wshobson/agents** | 184 agents across 25 categories — cherry-pick `conductor` (track management), `comprehensive-review` (multi-perspective analysis), `plugin-eval` (anti-pattern detection) | [wshobson/agents](https://github.com/wshobson/agents) |

---

## Troubleshooting

- **Hooks not running** — restart Claude Code (it reloads `settings.json` only on start). Verify scripts are executable: `chmod +x ~/.claude/monitoring/hooks/*.sh`.
- **`settings.json` didn't change after re-install** — expected: the installer never overwrites an existing `settings.json`. Delete or rename your copy, then re-run, or hand-merge from this repo.
- **Node hooks failing** — you installed `--full` without Node 18+. Either install Node or re-run with `./install.sh` (default omits Node hooks).
- **Logs** — `~/.claude/logs/task-router.jsonl` · `~/.claude/logs/session-metrics.jsonl`.

---

## Project Layout

```
claude-code-config/
├── .claude-plugin/
│   └── marketplace.json   # Plugin marketplace entry (Anthropic convention)
├── agents/                # 29 specialized subagents
├── commands/              # 60 slash commands
├── skills/                # 60 workflow skills
├── rules/                 # 65 coding rules (common + per-language)
├── monitoring/hooks/      # 4 zero-dep lifecycle hooks (default)
├── hooks/                 # Opt-in Node quality-gate hooks
├── scripts/hooks/         # Scripts invoked by the opt-in hooks
├── security/              # Security framework docs
├── mcp-configs/           # Reference MCP server configs
├── sounds/                # Optional macOS notification sounds
├── images/                # README demo GIFs
├── docs/                  # Developer docs (PLUGIN_SCHEMA_NOTES.md, tapes/)
├── install.sh             # Zero-dep installer (--minimal / --full / --uninstall / --dry-run)
├── settings.json          # Starter settings (permissions + 4 lifecycle hooks)
├── mcp.json               # MCP server config (add your tokens)
├── plugin.json            # Claude Code plugin manifest
└── AGENTS.md              # Full agent reference
```

---

## Credits

- [everything-claude-code](https://github.com/affaan-m/everything-claude-code) — Agents, commands, rules, hooks, scripts, security guide.
- [superpowers](https://github.com/obra/superpowers) — Brainstorming, planning, TDD skills.
- [claude-code-hooks-multi-agent-observability](https://github.com/disler/claude-code-hooks-multi-agent-observability) — Monitoring patterns.
- [ruflo](https://github.com/ruvnet/ruflo) — Task-router and session-persistence patterns.

## License

MIT — see [LICENSE](LICENSE).

---

<div align="center">

Made by [Cyrus David Pastelero](https://github.com/Cyvid7-Darus10) — if this helped you, consider starring.

</div>
