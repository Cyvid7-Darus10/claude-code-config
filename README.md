<div align="center">

# Claude Code Config

**Production-ready Claude Code configuration for rapid app development.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Agents](https://img.shields.io/badge/Agents-12-purple)](agents/)
[![Commands](https://img.shields.io/badge/Commands-16-green)](commands/)
[![Skills](https://img.shields.io/badge/Skills-18-orange)](skills/)
[![Rules](https://img.shields.io/badge/Rules-curated-red)](rules/)
[![Token-Saving Hooks](https://img.shields.io/badge/Hooks-Token--Saving-blueviolet)](hooks/)

12 agents · 16 commands · 18 skills · curated rules · token-saving hooks.

Deliberately lean: skill descriptions, agent definitions, and MCP schemas all consume context in **every** session. This config stays well under the ~10% startup-overhead budget so auto-invocation keeps working and subagents don't blow their context at spawn.

Built on [Everything Claude Code (ECC)](https://github.com/affaan-m/ECC) + [obra/superpowers](https://github.com/obra/superpowers).

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

Available components: `agents`, `commands`, `skills`, `rules`, `mcp`, `sounds`, `security` (docs), `hooks` (token-saving Node hooks, opt-in).

### Updating

Re-run the one-liner at any time — `setup.sh` fetches the latest commit, hard-resets to `origin/main`, and re-runs `install.sh`:

```bash
curl -fsSL https://raw.githubusercontent.com/Cyvid7-Darus10/claude-code-config/main/setup.sh | bash
```

What happens to each file in `~/.claude/`:

| Path | Behaviour on update |
|------|---------------------|
| `settings.json` | **Never overwritten** — your customisations are safe. Diff against the repo's `settings.json` to see new defaults worth merging. |
| `mcp.json` | **Never overwritten** — protects your tokens. |
| `agents/`, `commands/`, `skills/`, `rules/` | Replaced with latest. Previous copy backed up to `~/.claude/backups/pre-install-<timestamp>/` first. |
| `~/.local/share/claude-code-config` (the clone) | Fast-forwarded to `origin/main`. |

**See what changed** before updating:

```bash
cd ~/.local/share/claude-code-config && git fetch && git log --oneline HEAD..origin/main
```

**Pin to a specific version** (useful for reproducible team setups):

```bash
CLAUDE_CODE_CONFIG_REF=v1.0.0 curl -fsSL https://raw.githubusercontent.com/Cyvid7-Darus10/claude-code-config/main/setup.sh | bash
```

**Roll back** to a previous install:

```bash
ls ~/.claude/backups/                    # find the timestamp you want
cp -r ~/.claude/backups/pre-install-<timestamp>/* ~/.claude/
```

**Merge new defaults into your existing `settings.json`** — since the installer won't overwrite it:

```bash
diff ~/.claude/settings.json ~/.local/share/claude-code-config/settings.json
```

Copy over the hook entries or permission rules you want; leave your custom fields alone.

### Requirements

| | Default install | `--full` install |
|---|---|---|
| bash 3.2+ | Required | Required |
| git | Only for `git clone` / updates | Only for `git clone` / updates |
| Node.js 18+ | Not needed | Required (for `hooks/` quality gates) |
| jq / Python | Never | Never |

The default install is **zero runtime dependencies**. The Node-based token-saving hooks in `hooks/` (duplicate-read blocking, output compression) are opt-in.

---

## What You Get

**Default install** (zero runtime dependencies):

| Component | Count | Examples |
|-----------|------:|----------|
| Agents | 12 | `planner`, `architect`, `code-reviewer`, `security-reviewer`, `tdd-guide`, `build-error-resolver`, `typescript-reviewer`, `python-reviewer`, `database-reviewer`, `docs-lookup`, `e2e-runner`, `refactor-cleaner` |
| Slash commands | 16 | `/plan`, `/tdd`, `/verify`, `/code-review`, `/build-fix`, `/e2e`, `/test-coverage`, `/refactor-clean`, `/python-review`, `/docs`, `/ponytail` + 5 ponytail subcommands |
| Skills | 18 | api-design, backend/frontend-patterns, postgres-patterns, database-migrations, security-review, e2e-testing, market-research, ponytail, python + swift/SwiftUI/Foundation Models packs |
| Coding rules | curated | Common (coding style, git workflow, testing, security, multi-repo-consistency) + TypeScript, Python, Swift |
| MCP servers | 2 | `context7` (docs, used by `docs-lookup`), `playwright` (used by `e2e-runner`) — GitHub via `gh` CLI, not MCP |

**Opt-in with `--full`** (requires Node.js 18+):

| Component | Count | Examples |
|-----------|------:|----------|
| Token-saving hooks | 2 | `pre-read.mjs` blocks duplicate file reads · `compress.mjs` compresses noisy tool output and detects command loops |

---

## Workflows

- **Idea → plan → TDD → ship** — `/plan` uses the brainstorming skill, `/tdd` runs RED-GREEN-REFACTOR.
- **Intelligent routing** — the `task-router` hook analyses every prompt and surfaces the right agent or skill as a hint. Routes include: `plan-first`, `architecture`, `debug`, `tdd`, `security`, `review`, `refactor`, `build-fix`, `docs`, `performance`, `backend` (endpoint/migration/queue work → backend-judgement checklist), `reasoning` (ambiguous/cross-cutting prompts → systematic-reasoning).
- **Session continuity** — `session-restore` on start, `pre-compact-checkpoint` before compaction, `session-persist` on stop. Pick up where you left off across restarts.
- **Deliberate thinking** — the `systematic-reasoning` skill forces a four-pass model-building process before non-trivial changes. The `backend-judgement` skill applies a 9-check production-safety list to every endpoint, migration, queue consumer, and job.
- **Multi-repo consistency** — `rules/common/multi-repo-consistency.md` codifies cross-stack invariants (naming, error handling, logging, boundaries, testing) so Claude behaves the same across your Go / TS / Python / Rust / Java / Kotlin / Swift / C++ / PHP / C# / Perl repos.

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

- **Hooks not running** — restart Claude Code (it reloads `settings.json` only on start).
- **`settings.json` didn't change after re-install** — expected: the installer never overwrites an existing `settings.json`. Delete or rename your copy, then re-run, or hand-merge from this repo.
- **Node hooks failing** — you installed `--full` without Node 18+. Either install Node or re-run with `./install.sh` (default omits Node hooks).
- **Skill descriptions being dropped** — run `/doctor` in Claude Code; if skills are shortened or dropped, you've added too many. Run `/context` to see startup overhead.

---

## Project Layout

```
claude-code-config/
├── .claude-plugin/
│   └── marketplace.json   # Plugin marketplace entry (Anthropic convention)
├── agents/                # 12 specialized subagents
├── commands/              # 10 slash commands
├── skills/                # 17 workflow skills
├── rules/                 # Curated coding rules (common + python/swift/typescript)
├── hooks/                 # Opt-in Node token-saving hooks
├── scripts/hooks/         # Scripts invoked by the opt-in hooks
├── security/              # Security framework docs
├── mcp-configs/           # Reference MCP server configs
├── sounds/                # Optional macOS notification sounds
├── images/                # README demo GIFs
├── docs/                  # Developer docs (PLUGIN_SCHEMA_NOTES.md, tapes/)
├── install.sh             # Zero-dep installer (--minimal / --full / --uninstall / --dry-run)
├── settings.json          # Starter settings (permissions + token-saving hooks)
├── mcp.json               # MCP server config (add your tokens)
├── plugin.json            # Claude Code plugin manifest
└── AGENTS.md              # Full agent reference
```

---

## Credits

- [Everything Claude Code (ECC)](https://github.com/affaan-m/ECC) — Agents, commands, rules, hooks, scripts, security guide.
- [superpowers](https://github.com/obra/superpowers) — Brainstorming, planning, TDD skills.
- [claude-code-hooks-multi-agent-observability](https://github.com/disler/claude-code-hooks-multi-agent-observability) — Monitoring patterns.
- [ruflo](https://github.com/ruvnet/ruflo) — Task-router and session-persistence patterns.

## License

MIT — see [LICENSE](LICENSE).

---

<div align="center">

Made by [Cyrus David Pastelero](https://github.com/Cyvid7-Darus10) — if this helped you, consider starring.

</div>
