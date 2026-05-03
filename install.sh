#!/bin/bash
# Install claude-code-config into $HOME/.claude
# Zero runtime dependencies — hooks use pure bash. git is optional for updates.
set -e

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$CLAUDE_DIR/backups/pre-install-$(date +%Y%m%d-%H%M%S)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
  cat <<EOF
Usage: ./install.sh [OPTIONS] [COMPONENTS...]

Components (default: agents, commands, skills, rules, monitoring, mcp):
  agents       30 specialized subagents
  commands     63 slash commands
  skills       64 workflow skills
  rules        66 coding rules
  monitoring   4 zero-dep lifecycle hooks (pure bash)
  mcp          MCP server configs (edit mcp.json for your tokens)
  sounds       Optional macOS notification sounds
  hooks        Node.js quality-gate hooks (requires Node.js + npm) -- OPT-IN
  security     Security framework documentation -- OPT-IN

Options:
  --no-backup   Skip backing up existing config
  --uninstall   Remove installed components
  --dry-run     Show what would be installed
  --minimal     Install only agents, commands, skills, rules (no hooks at all)
  --full        Install everything including the Node.js quality-gate hooks
  -h, --help    Show this help

Examples:
  ./install.sh                    # Default install (zero runtime dependencies)
  ./install.sh --minimal          # Just agents + skills + commands + rules
  ./install.sh --full             # Include Node.js quality-gate hooks
  ./install.sh agents skills      # Pick specific components
  ./install.sh --dry-run          # Preview
  ./install.sh --uninstall        # Remove all components
EOF
}

# Parse options
BACKUP=true
UNINSTALL=false
DRY_RUN=false
MINIMAL=false
FULL=false
COMPONENTS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --no-backup) BACKUP=false; shift ;;
    --uninstall) UNINSTALL=true; shift ;;
    --dry-run)   DRY_RUN=true; shift ;;
    --minimal)   MINIMAL=true; shift ;;
    --full)      FULL=true; shift ;;
    -h|--help)   usage; exit 0 ;;
    full)        FULL=true; shift ;;
    *)           COMPONENTS+=("$1"); shift ;;
  esac
done

# Default: zero runtime dependencies. Node-based 'hooks/' is opt-in.
DEFAULT_COMPONENTS=(agents commands skills rules monitoring mcp)
MINIMAL_COMPONENTS=(agents commands skills rules)
FULL_COMPONENTS=(agents commands skills rules monitoring mcp sounds hooks)
# Used by --uninstall with no args: every component the installer can touch.
ALL_COMPONENTS=(agents commands skills rules monitoring mcp sounds hooks security)

# Valid component names (for input validation). Keep in sync with get_dirs_for_component().
VALID_COMPONENTS=(agents commands skills rules monitoring mcp sounds hooks security)

is_valid_component() {
  local c="$1"
  for v in "${VALID_COMPONENTS[@]}"; do
    [ "$c" = "$v" ] && return 0
  done
  return 1
}

# Validate any components passed as positional args. Warn on unknown and drop them.
if [ ${#COMPONENTS[@]} -gt 0 ]; then
  VALIDATED=()
  for comp in "${COMPONENTS[@]}"; do
    if is_valid_component "$comp"; then
      VALIDATED+=("$comp")
    else
      echo -e "${YELLOW}WARNING${NC}: Unknown component '$comp' — ignored."
      echo "         Valid components: ${VALID_COMPONENTS[*]}"
    fi
  done
  COMPONENTS=("${VALIDATED[@]}")
fi

if [ ${#COMPONENTS[@]} -eq 0 ]; then
  if [ "$MINIMAL" = true ]; then
    COMPONENTS=("${MINIMAL_COMPONENTS[@]}")
  elif [ "$FULL" = true ]; then
    COMPONENTS=("${FULL_COMPONENTS[@]}")
  elif [ "$UNINSTALL" = true ]; then
    # Uninstall with no args → remove EVERY component this installer can place,
    # so opt-in extras (hooks/scripts/sounds/security) don't get orphaned.
    COMPONENTS=("${ALL_COMPONENTS[@]}")
  else
    COMPONENTS=("${DEFAULT_COMPONENTS[@]}")
  fi
fi

# Warn if user picked the Node-dep 'hooks' component without Node installed.
for comp in "${COMPONENTS[@]}"; do
  if [ "$comp" = "hooks" ] && ! command -v node >/dev/null 2>&1; then
    echo -e "\033[1;33mWARNING\033[0m: 'hooks' component requires Node.js, which was not found on PATH."
    echo "         Install Node.js 18+ or omit the 'hooks' component (they're opt-in)."
    echo ""
  fi
done

# Map component names to directories
get_dirs_for_component() {
  case "$1" in
    agents)     echo "agents" ;;
    commands)   echo "commands" ;;
    skills)     echo "skills" ;;
    rules)      echo "rules" ;;
    hooks)      echo "hooks scripts" ;;
    monitoring) echo "monitoring" ;;
    sounds)     echo "sounds" ;;
    mcp)        echo "mcp-configs" ;;
    security)   echo "security" ;;
    *)          echo "" ;;
  esac
}

# --- Preflight: hard requirement = bash 3.2+ (ships with macOS). Soft = git. ---
preflight() {
  if [ -z "${BASH_VERSION:-}" ]; then
    echo -e "${RED}This installer needs bash.${NC}"
    exit 1
  fi
  if ! command -v git >/dev/null 2>&1; then
    echo -e "${YELLOW}Note: git is not installed. It's only needed for updates; core features work without it.${NC}"
  fi
}
preflight

# --- Uninstall ---
if [ "$UNINSTALL" = true ]; then
  echo -e "${YELLOW}Uninstalling claude-code-config from $CLAUDE_DIR${NC}"
  for comp in "${COMPONENTS[@]}"; do
    dirs=$(get_dirs_for_component "$comp")
    for dir in $dirs; do
      if [ -d "$CLAUDE_DIR/$dir" ]; then
        if [ "$DRY_RUN" = true ]; then
          echo -e "  ${BLUE}[dry-run]${NC} Would remove $CLAUDE_DIR/$dir/"
        else
          rm -rf "$CLAUDE_DIR/$dir"
          echo -e "  ${RED}Removed${NC} $dir/"
        fi
      fi
    done
  done
  echo -e "${GREEN}Uninstall complete.${NC}"
  exit 0
fi

# --- Install ---
echo -e "${GREEN}Installing claude-code-config to $CLAUDE_DIR${NC}"
echo ""

mkdir -p "$CLAUDE_DIR"

# Backup existing config if anything overlaps
if [ "$BACKUP" = true ]; then
  HAS_EXISTING=false
  for comp in "${COMPONENTS[@]}"; do
    dirs=$(get_dirs_for_component "$comp")
    for dir in $dirs; do
      [ -d "$CLAUDE_DIR/$dir" ] && HAS_EXISTING=true
    done
  done

  if [ "$HAS_EXISTING" = true ]; then
    if [ "$DRY_RUN" = true ]; then
      echo -e "${BLUE}[dry-run]${NC} Would backup existing config to $BACKUP_DIR"
    else
      mkdir -p "$BACKUP_DIR"
      for comp in "${COMPONENTS[@]}"; do
        dirs=$(get_dirs_for_component "$comp")
        for dir in $dirs; do
          [ -d "$CLAUDE_DIR/$dir" ] && cp -r "$CLAUDE_DIR/$dir" "$BACKUP_DIR/$dir" 2>/dev/null || true
        done
      done
      echo -e "${BLUE}Backed up existing config to:${NC}"
      echo "  $BACKUP_DIR"
      echo ""
    fi
  fi
fi

# Install component directories
INSTALLED=0
for comp in "${COMPONENTS[@]}"; do
  dirs=$(get_dirs_for_component "$comp")
  for dir in $dirs; do
    if [ -d "$SCRIPT_DIR/$dir" ]; then
      count=$(find "$SCRIPT_DIR/$dir" -type f | wc -l | tr -d ' ')
      if [ "$DRY_RUN" = true ]; then
        echo -e "  ${BLUE}[dry-run]${NC} Would install $dir/ ($count files)"
      else
        mkdir -p "$CLAUDE_DIR/$dir"
        cp -r "$SCRIPT_DIR/$dir/"* "$CLAUDE_DIR/$dir/"
        # Ensure shell scripts are executable (tar/zip distributions may lose the bit)
        find "$CLAUDE_DIR/$dir" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
        echo -e "  ${GREEN}Installed${NC} $dir/ ($count files)"
        INSTALLED=$((INSTALLED + count))
      fi
    fi
  done
done

# Install top-level metadata files.
# Note: marketplace.json is NOT installed to ~/.claude/ — it only belongs in the
# plugin repo's .claude-plugin/ directory. Claude Code does not read it from ~/.claude/.
echo ""
for file in AGENTS.md plugin.json; do
  if [ -f "$SCRIPT_DIR/$file" ]; then
    if [ "$DRY_RUN" = true ]; then
      echo -e "  ${BLUE}[dry-run]${NC} Would install $file"
    else
      cp "$SCRIPT_DIR/$file" "$CLAUDE_DIR/$file"
      echo -e "  ${GREEN}Installed${NC} $file"
    fi
  fi
done

# settings.json — don't clobber user customisations
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  echo -e "  ${YELLOW}Skipped${NC} settings.json (already exists — see repo for reference)"
else
  if [ "$DRY_RUN" = false ]; then
    cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
    echo -e "  ${GREEN}Installed${NC} settings.json"
  fi
fi

# mcp.json — never overwrite (may contain tokens)
if [ -f "$CLAUDE_DIR/mcp.json" ]; then
  echo -e "  ${YELLOW}Skipped${NC} mcp.json (already exists — won't overwrite tokens)"
else
  if [ "$DRY_RUN" = false ] && [ -f "$SCRIPT_DIR/mcp.json" ]; then
    cp "$SCRIPT_DIR/mcp.json" "$CLAUDE_DIR/mcp.json"
    echo -e "  ${GREEN}Installed${NC} mcp.json (edit to add tokens if you use GitHub MCP)"
  fi
fi

# --- Post-install verification ---
if [ "$DRY_RUN" = false ]; then
  echo ""
  echo -e "${BLUE}Verifying installation...${NC}"
  ERRORS=0

  check_dir() {
    if [ -d "$CLAUDE_DIR/$1" ] && [ "$(ls -A "$CLAUDE_DIR/$1" 2>/dev/null)" ]; then
      echo -e "  ${GREEN}OK${NC}  $1/ ($(find "$CLAUDE_DIR/$1" -type f | wc -l | tr -d ' ') files)"
    else
      echo -e "  ${RED}FAIL${NC} $1/ is missing or empty"
      ERRORS=$((ERRORS + 1))
    fi
  }

  for comp in "${COMPONENTS[@]}"; do
    dirs=$(get_dirs_for_component "$comp")
    for dir in $dirs; do
      check_dir "$dir"
    done
  done

  # Sanity: if hooks reference monitoring scripts, monitoring must be installed.
  if grep -q "monitoring/hooks" "$CLAUDE_DIR/settings.json" 2>/dev/null; then
    if [ ! -d "$CLAUDE_DIR/monitoring/hooks" ]; then
      echo -e "  ${YELLOW}WARN${NC} settings.json references monitoring/hooks but that directory is missing."
      echo -e "         Re-run with: ./install.sh monitoring"
    fi
  fi

  echo ""
  if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}Installation complete! ($INSTALLED files installed)${NC}"
  else
    echo -e "${RED}Installation completed with $ERRORS error(s).${NC}"
  fi
fi

echo ""
echo "Next steps:"
echo "  1. Restart Claude Code for changes to take effect"
echo "  2. (Optional) Edit ~/.claude/mcp.json to add your GitHub token"
echo "  3. Try: /plan, /tdd, /verify, /code-review"
echo ""
echo -e "Run ${YELLOW}./install.sh --uninstall${NC} to remove."
