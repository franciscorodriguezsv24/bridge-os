#!/bin/bash
# =============================================================================
# Bridge OS — project.sh
# Installs Bridge OS into the current project.
# Usage: ~/.bridge-os/setup/project.sh
# =============================================================================

set -e

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

BRIDGE_OS_HOME="$HOME/.bridge-os"
PROJECT_DIR="$(pwd)"

echo ""
echo -e "${BOLD}🌉 Bridge OS — Project Installation${RESET}"
echo -e "─────────────────────────────────────"
echo ""
echo -e "  Project: ${CYAN}$PROJECT_DIR${RESET}"
echo ""

# ── Check global installation ─────────────────────────────────────────────────
if [ ! -d "$BRIDGE_OS_HOME" ]; then
  echo -e "${RED}✗ Bridge OS is not installed globally.${RESET}"
  echo -e "  Run the global installer first:"
  echo -e "  ${CYAN}curl -sSL https://raw.githubusercontent.com/franciscorodriguezsv24/bridge-os/main/setup/install.sh | bash${RESET}"
  exit 1
fi

# ── Check for Design OS and Agent OS ─────────────────────────────────────────
echo -e "${CYAN}→ Checking for Design OS and Agent OS...${RESET}"

# Agent OS
if [ -d "$PROJECT_DIR/agent-os" ]; then
  echo -e "  ${GREEN}✓${RESET} Agent OS found at ./agent-os"
else
  echo -e "  ${YELLOW}⚠${RESET} Agent OS not found at ./agent-os"
  echo -e "    Bridge OS will still install, but sync won't work until Agent OS is set up."
fi

# Design OS (check project dir first, then parent)
DESIGN_OS_FOUND=false
for candidate in "./bridge-design" "./*design*" "../*design*" "../*design-os*"; do
  for dir in $candidate; do
    if [ -d "$dir" ] && [ -f "$dir/package.json" ]; then
      DESIGN_OS_FOUND=true
      DESIGN_OS_SUGGESTED="$dir"
      break 2
    fi
  done
done

if [ "$DESIGN_OS_FOUND" = true ]; then
  echo -e "  ${GREEN}✓${RESET} Design OS found at $DESIGN_OS_SUGGESTED"
else
  echo -e "  ${YELLOW}⚠${RESET} Design OS not found nearby."
  echo -e "    You'll need to set the path manually in .bridge-os/config.yml"
fi

echo ""

# ── Detect --update flag ──────────────────────────────────────────────────────
UPDATE_MODE=false
for arg in "$@"; do
  [ "$arg" = "--update" ] && UPDATE_MODE=true
done

if [ "$UPDATE_MODE" = true ]; then
  echo -e "${CYAN}→ Update mode — refreshing scripts and commands only...${RESET}"
  echo -e "  ${YELLOW}config.yml and state.json will not be touched${RESET}"
  echo ""
fi

# ── Create .bridge-os/ folder in project ─────────────────────────────────────
echo -e "${CYAN}→ Creating .bridge-os/ in project...${RESET}"
mkdir -p "$PROJECT_DIR/.bridge-os"

# Copy scripts (always overwrite in update mode)
cp "$BRIDGE_OS_HOME/scripts/sync.sh" "$PROJECT_DIR/.bridge-os/sync.sh"
cp "$BRIDGE_OS_HOME/scripts/generate-standard.js" "$PROJECT_DIR/.bridge-os/generate-standard.js"
chmod +x "$PROJECT_DIR/.bridge-os/sync.sh"
echo -e "  ${GREEN}✓${RESET} sync.sh and generate-standard.js copied"

# ── Write config.yml ──────────────────────────────────────────────────────────
CONFIG="$PROJECT_DIR/.bridge-os/config.yml"

if [ "$UPDATE_MODE" = true ]; then
  echo -e "  ${YELLOW}⚠${RESET} Skipping config.yml (update mode)"
elif [ -f "$CONFIG" ]; then
  echo -e "  ${YELLOW}⚠${RESET} config.yml already exists — skipping to preserve your settings"
else
  SUGGESTED_PATH="${DESIGN_OS_SUGGESTED:-../my-project-design}"
  cat > "$CONFIG" <<EOF
# Bridge OS — Project Configuration
# Adjust paths to match your local setup.

design_os:
  path: "$SUGGESTED_PATH"     # path to your Design OS repo
  export_dir: "product-plan"    # export folder inside Design OS

agent_os:
  path: "./"                   # this project (current directory)
  standards_dir: "agent-os/standards/global"
  product_dir: "agent-os/product"

bridge:
  export_dest: "design-export" # where Bridge copies the Design OS export
  enforce_phase_lock: true     # blocks sync if Design OS export is missing
EOF
  echo -e "  ${GREEN}✓${RESET} config.yml created"
fi

# ── Write state.json ──────────────────────────────────────────────────────────
STATE="$PROJECT_DIR/.bridge-os/state.json"
if [ ! -f "$STATE" ]; then
  cat > "$STATE" <<EOF
{
  "phase": "design",
  "last_sync": null,
  "export_hash": null,
  "section": null,
  "tokens_only": false
}
EOF
  echo -e "  ${GREEN}✓${RESET} state.json initialized (phase: design)"
fi

echo ""

# ── Install Claude Code commands ──────────────────────────────────────────────
echo -e "${CYAN}→ Installing Bridge OS Claude Code commands...${RESET}"
mkdir -p "$PROJECT_DIR/.claude/commands"

for cmd in bridge-init bridge-design bridge-build bridge-status bridge-sync; do
  SRC="$BRIDGE_OS_HOME/commands/${cmd}.md"
  DEST="$PROJECT_DIR/.claude/commands/${cmd}.md"
  if [ -f "$SRC" ]; then
    cp "$SRC" "$DEST"
    echo -e "  ${GREEN}✓${RESET} /${cmd} installed"
  else
    echo -e "  ${YELLOW}⚠${RESET} ${cmd}.md not found in Bridge OS — skipping"
  fi
done

echo ""

# ── Install Agent OS Claude Code commands ─────────────────────────────────────
echo -e "${CYAN}→ Installing Agent OS Claude Code commands...${RESET}"

AGENT_OS_COMMANDS="$HOME/agent-os/commands/agent-os"

if [ ! -d "$AGENT_OS_COMMANDS" ]; then
  echo -e "  ${YELLOW}⚠${RESET} Agent OS commands not found at $AGENT_OS_COMMANDS"
  echo -e "    Run /bridge-init to install Agent OS first, then re-run this script."
else
  for cmd_file in "$AGENT_OS_COMMANDS"/*.md; do
    [ -f "$cmd_file" ] || continue
    cmd_name=$(basename "$cmd_file")
    cp "$cmd_file" "$PROJECT_DIR/.claude/commands/$cmd_name"
    echo -e "  ${GREEN}✓${RESET} ${cmd_name} installed"
  done
fi

echo ""

# ── Install Design OS Claude Code commands ────────────────────────────────────
echo -e "${CYAN}→ Installing Design OS Claude Code commands...${RESET}"

DESIGN_OS_COMMANDS="$PROJECT_DIR/bridge-design/.claude/commands/design-os"

if [ ! -d "$DESIGN_OS_COMMANDS" ]; then
  echo -e "  ${YELLOW}⚠${RESET} Design OS commands not found at $DESIGN_OS_COMMANDS"
  echo -e "    Run /bridge-init to install Design OS first, then re-run this script."
else
  mkdir -p "$PROJECT_DIR/.claude/commands/design-os"
  for cmd_file in "$DESIGN_OS_COMMANDS"/*.md; do
    [ -f "$cmd_file" ] || continue
    cmd_name=$(basename "$cmd_file" .md)
    cp "$cmd_file" "$PROJECT_DIR/.claude/commands/design-os/$(basename "$cmd_file")"
    echo -e "  ${GREEN}✓${RESET} /${cmd_name} installed"
  done
fi

echo ""

# ── Update CLAUDE.md ──────────────────────────────────────────────────────────
echo -e "${CYAN}→ Updating CLAUDE.md...${RESET}"
CLAUDE_MD="$PROJECT_DIR/CLAUDE.md"
BRIDGE_SECTION_MARKER="## 🌉 Bridge OS"

if [ -f "$CLAUDE_MD" ] && grep -q "$BRIDGE_SECTION_MARKER" "$CLAUDE_MD"; then
  echo -e "  ${YELLOW}⚠${RESET} Bridge OS section already in CLAUDE.md — skipping"
else
  TEMPLATE="$BRIDGE_OS_HOME/template/claude-md-section.md.tpl"
  if [ -f "$TEMPLATE" ]; then
    echo "" >> "$CLAUDE_MD"
    cat "$TEMPLATE" >> "$CLAUDE_MD"
    echo -e "  ${GREEN}✓${RESET} Bridge OS section appended to CLAUDE.md"
  else
    echo -e "  ${YELLOW}⚠${RESET} Template not found — add Bridge OS section to CLAUDE.md manually"
  fi
fi

echo ""

# ── Update .gitignore ─────────────────────────────────────────────────────────
echo -e "${CYAN}→ Updating .gitignore...${RESET}"
GITIGNORE="$PROJECT_DIR/.gitignore"
ENTRIES=("bridge-design/" "design-export/" ".bridge-os/state.json" ".bridge-os/config.yml")

for entry in "${ENTRIES[@]}"; do
  if [ -f "$GITIGNORE" ] && grep -qF "$entry" "$GITIGNORE"; then
    echo -e "  ${GREEN}✓${RESET} $entry already in .gitignore"
  else
    echo "$entry" >> "$GITIGNORE"
    echo -e "  ${GREEN}✓${RESET} $entry added to .gitignore"
  fi
done

echo ""

# ── Done ──────────────────────────────────────────────────────────────────────
echo -e "${GREEN}${BOLD}✅ Bridge OS installed in this project${RESET}"
echo ""
echo -e "${BOLD}Next steps:${RESET}"
echo -e "  ${CYAN}1.${RESET} Open Claude Code: ${BOLD}claude${RESET}"
echo -e "  ${CYAN}2.${RESET} Run ${BOLD}/bridge-init${RESET} to install Design OS and Agent OS"
echo -e "  ${CYAN}3.${RESET} Run ${BOLD}/bridge-design${RESET} to start the design phase"
echo -e "  ${CYAN}4.${RESET} Run ${BOLD}/bridge-sync${RESET} to connect design with Agent OS"
echo -e "  ${CYAN}5.${RESET} Run ${BOLD}/bridge-build${RESET} to inject standards and shape specs"
echo ""