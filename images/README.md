# Screenshots Guide

Capture these screenshots from your terminal running Claude Code and save them here.
GitHub will render them in the main README automatically.

## Required Screenshots

| Filename | What to Capture |
|----------|----------------|
| `plan-command.png` | Run `/plan` with a project idea — show the planning output |
| `tdd-workflow.png` | Run `/tdd` — show test-first workflow in action |
| `devfleet.png` | Run `/devfleet` — show parallel agents being dispatched |
| `security-audit.png` | Show `tail -f ~/.claude/logs/security-audit.jsonl \| jq` output |
| `session-management.png` | Show `/save-session` then `/resume-session` flow |

## Tips

- Use a clean terminal with a dark theme for contrast
- Terminal width ~120 columns works best
- Crop to just the relevant output (no full desktop)
- PNG format, reasonable resolution (1200-1600px wide)
- Tools like [iTerm2](https://iterm2.com/) on macOS or [Windows Terminal](https://github.com/microsoft/terminal) give clean output

## Optional Screenshots

- Agent orchestration with `/orchestrate`
- Code review output with `/code-review`
- Brainstorming session with the brainstorming skill
- Monitoring dashboard with `jq` formatted logs
- Install script output (`./install.sh`)
