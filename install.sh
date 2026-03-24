#!/bin/bash
set -e

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing Claude Code config to $CLAUDE_DIR"

# Directories to copy
dirs=(agents commands skills rules hooks scripts sounds mcp-configs)

for dir in "${dirs[@]}"; do
  if [ -d "$SCRIPT_DIR/$dir" ]; then
    mkdir -p "$CLAUDE_DIR/$dir"
    cp -r "$SCRIPT_DIR/$dir/"* "$CLAUDE_DIR/$dir/" 2>/dev/null || true
    count=$(find "$SCRIPT_DIR/$dir" -type f | wc -l | tr -d ' ')
    echo "  Installed $dir/ ($count files)"
  fi
done

# Copy top-level config files (don't overwrite mcp.json if it exists with a real token)
for file in settings.json AGENTS.md marketplace.json plugin.json PLUGIN_SCHEMA_NOTES.md; do
  if [ -f "$SCRIPT_DIR/$file" ]; then
    cp "$SCRIPT_DIR/$file" "$CLAUDE_DIR/$file"
    echo "  Installed $file"
  fi
done

if [ -f "$CLAUDE_DIR/mcp.json" ]; then
  echo "  Skipped mcp.json (already exists — edit manually if needed)"
else
  cp "$SCRIPT_DIR/mcp.json" "$CLAUDE_DIR/mcp.json"
  echo "  Installed mcp.json (replace <YOUR_GITHUB_TOKEN> with your token)"
fi

echo ""
echo "Done! Restart Claude Code for changes to take effect."
