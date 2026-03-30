# Demo GIFs

Generated with [VHS](https://github.com/charmbracelet/vhs) from tape files in `tapes/`.

## Generate All Demos

```bash
# Install VHS (one-time)
brew install vhs

# Generate all GIFs
for tape in tapes/*.tape; do
  vhs "$tape"
done
```

## Individual Demos

| Tape File | Output | What It Shows |
|-----------|--------|---------------|
| `tapes/plan-command.tape` | `plan-command.gif` | `/plan` creating an implementation plan |
| `tapes/tdd-workflow.tape` | `tdd-workflow.gif` | `/tdd` test-first development flow |
| `tapes/devfleet.tape` | `devfleet.gif` | `/devfleet` dispatching parallel agents |
| `tapes/security-audit.tape` | `security-audit.gif` | Security + tool execution + session logs |
| `tapes/session-management.tape` | `session-management.gif` | `/save-session` and `/resume-session` |
| `tapes/install.tape` | `install-demo.gif` | Installer with `--dry-run` and selective install |

## Tips

- Edit tape files in `tapes/` to adjust timing, theme, or commands
- Re-run `vhs tapes/<name>.tape` to regenerate after changes
- VHS supports themes: Dracula (default), Monokai, Solarized, etc.
- Adjust `Sleep` durations if Claude takes longer to respond
- Set `Set FontSize 16` for readable GIFs on GitHub
