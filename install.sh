#!/bin/bash
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
  echo "Usage: ./install.sh [OPTIONS] [COMPONENTS...]"
  echo ""
  echo "Components (default: all):"
  echo "  agents      29 specialized subagents"
  echo "  commands    60 slash commands"
  echo "  skills      60 workflow skills"
  echo "  rules       65 coding rules"
  echo "  hooks       Hook configurations + scripts"
  echo "  sounds      Notification sound effects"
  echo "  mcp         MCP server configs"
  echo ""
  echo "Options:"
  echo "  --no-backup   Skip backing up existing config"
  echo "  --uninstall   Remove installed components"
  echo "  --dry-run     Show what would be installed"
  echo "  -h, --help    Show this help"
  echo ""
  echo "Examples:"
  echo "  ./install.sh                    # Install everything"
  echo "  ./install.sh agents skills      # Install only agents and skills"
  echo "  ./install.sh --dry-run          # Preview installation"
  echo "  ./install.sh --uninstall        # Remove all installed components"
}

# Parse options
BACKUP=true
UNINSTALL=false
DRY_RUN=false
COMPONENTS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --no-backup)  BACKUP=false; shift ;;
    --uninstall)  UNINSTALL=true; shift ;;
    --dry-run)    DRY_RUN=true; shift ;;
    -h|--help)    usage; exit 0 ;;
    *)            COMPONENTS+=("$1"); shift ;;
  esac
done

# Default: install all components
ALL_COMPONENTS=(agents commands skills rules hooks sounds mcp)
if [ ${#COMPONENTS[@]} -eq 0 ]; then
  COMPONENTS=("${ALL_COMPONENTS[@]}")
fi

# Map component names to directories
declare -A COMPONENT_DIRS=(
  [agents]="agents"
  [commands]="commands"
  [skills]="skills"
  [rules]="rules"
  [hooks]="hooks scripts"
  [sounds]="sounds"
  [mcp]="mcp-configs"
)

declare -A COMPONENT_FILES=(
  [agents]="AGENTS.md"
  [hooks]="hooks"
)

# --- Uninstall ---
if [ "$UNINSTALL" = true ]; then
  echo -e "${YELLOW}Uninstalling claude-code-config from $CLAUDE_DIR${NC}"
  for comp in "${COMPONENTS[@]}"; do
    dirs=${COMPONENT_DIRS[$comp]}
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

# Ensure ~/.claude exists
mkdir -p "$CLAUDE_DIR"

# Backup existing config
if [ "$BACKUP" = true ]; then
  HAS_EXISTING=false
  for comp in "${COMPONENTS[@]}"; do
    dirs=${COMPONENT_DIRS[$comp]}
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
        dirs=${COMPONENT_DIRS[$comp]}
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

# Install components
INSTALLED=0
for comp in "${COMPONENTS[@]}"; do
  dirs=${COMPONENT_DIRS[$comp]}
  for dir in $dirs; do
    if [ -d "$SCRIPT_DIR/$dir" ]; then
      count=$(find "$SCRIPT_DIR/$dir" -type f | wc -l | tr -d ' ')
      if [ "$DRY_RUN" = true ]; then
        echo -e "  ${BLUE}[dry-run]${NC} Would install $dir/ ($count files)"
      else
        mkdir -p "$CLAUDE_DIR/$dir"
        cp -r "$SCRIPT_DIR/$dir/"* "$CLAUDE_DIR/$dir/"
        echo -e "  ${GREEN}Installed${NC} $dir/ ($count files)"
        INSTALLED=$((INSTALLED + count))
      fi
    fi
  done
done

# Install associated top-level files
echo ""
for file in AGENTS.md plugin.json marketplace.json PLUGIN_SCHEMA_NOTES.md; do
  if [ -f "$SCRIPT_DIR/$file" ]; then
    if [ "$DRY_RUN" = true ]; then
      echo -e "  ${BLUE}[dry-run]${NC} Would install $file"
    else
      cp "$SCRIPT_DIR/$file" "$CLAUDE_DIR/$file"
      echo -e "  ${GREEN}Installed${NC} $file"
    fi
  fi
done

# Handle settings.json — merge hooks, don't overwrite
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  echo -e "  ${YELLOW}Skipped${NC} settings.json (already exists — see settings.json in repo for reference)"
else
  if [ "$DRY_RUN" = false ]; then
    cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
    echo -e "  ${GREEN}Installed${NC} settings.json"
  fi
fi

# Handle mcp.json — don't overwrite (may contain tokens)
if [ -f "$CLAUDE_DIR/mcp.json" ]; then
  echo -e "  ${YELLOW}Skipped${NC} mcp.json (already exists — won't overwrite tokens)"
else
  if [ "$DRY_RUN" = false ]; then
    cp "$SCRIPT_DIR/mcp.json" "$CLAUDE_DIR/mcp.json"
    echo -e "  ${GREEN}Installed${NC} mcp.json (edit to add your GitHub token)"
  fi
fi

# --- Post-install validation ---
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
    dirs=${COMPONENT_DIRS[$comp]}
    for dir in $dirs; do
      check_dir "$dir"
    done
  done

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
echo "  2. Edit ~/.claude/mcp.json to add your GitHub token"
echo "  3. Try: /plan, /tdd, /verify, /code-review"
echo ""
echo -e "Run ${YELLOW}./install.sh --uninstall${NC} to remove."
