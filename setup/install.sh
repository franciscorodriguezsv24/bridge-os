#!/bin/bash
# =============================================================================
# Bridge OS — install.sh
# Global installation. Sets up ~/.bridge-os on your system.
# Usage: curl -sSL https://raw.githubusercontent.com/<user>/bridge-os/main/setup/install.sh | bash
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
REPO="https://github.com/franciscorodriguezsv24/bridge-os.git"

echo ""
echo -e "${BOLD}🌉 Bridge OS — Global Installation${RESET}"
echo -e "────────────────────────────────────"
echo ""

# ── Check dependencies ────────────────────────────────────────────────────────
echo -e "${CYAN}→ Checking dependencies...${RESET}"

# Node.js
if ! command -v node &>/dev/null; then
  echo -e "${RED}✗ Node.js is required but not installed.${RESET}"
  echo -e "  Install it from https://nodejs.org and re-run this script."
  exit 1
fi
echo -e "  ${GREEN}✓${RESET} Node.js $(node -v)"

# Git
if ! command -v git &>/dev/null; then
  echo -e "${RED}✗ Git is required but not installed.${RESET}"
  exit 1
fi
echo -e "  ${GREEN}✓${RESET} Git $(git --version | awk '{print $3}')"

# yq (optional but recommended)
if command -v yq &>/dev/null; then
  echo -e "  ${GREEN}✓${RESET} yq $(yq --version 2>/dev/null | head -1)"
else
  echo -e "  ${YELLOW}⚠${RESET} yq not found — Bridge OS will use fallback config parser."
  echo -e "    Install yq for best results: https://github.com/mikefarah/yq"
fi

echo ""

# ── Install or update ─────────────────────────────────────────────────────────
if [ -d "$BRIDGE_OS_HOME" ]; then
  echo -e "${CYAN}→ Existing installation found. Updating...${RESET}"
  cd "$BRIDGE_OS_HOME"
  git pull origin main --quiet
  echo -e "  ${GREEN}✓${RESET} Updated to latest version"
else
  echo -e "${CYAN}→ Installing Bridge OS to $BRIDGE_OS_HOME...${RESET}"
  git clone "$REPO" "$BRIDGE_OS_HOME" --quiet
  echo -e "  ${GREEN}✓${RESET} Cloned to $BRIDGE_OS_HOME"
fi

echo ""

# ── Make scripts executable ───────────────────────────────────────────────────
echo -e "${CYAN}→ Setting permissions...${RESET}"
chmod +x "$BRIDGE_OS_HOME/setup/install.sh"
chmod +x "$BRIDGE_OS_HOME/setup/project.sh"
chmod +x "$BRIDGE_OS_HOME/scripts/sync.sh"
echo -e "  ${GREEN}✓${RESET} Scripts are executable"

echo ""

# ── Done ──────────────────────────────────────────────────────────────────────
echo -e "${GREEN}${BOLD}✅ Bridge OS installed successfully${RESET}"
echo ""
echo -e "  Location: ${CYAN}$BRIDGE_OS_HOME${RESET}"
echo ""
echo -e "${BOLD}Available commands after project setup:${RESET}"
echo -e "  ${CYAN}/bridge-init${RESET}    — Install Design OS + Agent OS + Bridge OS"
echo -e "  ${CYAN}/bridge-design${RESET}  — Start or continue the design phase"
echo -e "  ${CYAN}/bridge-sync${RESET}    — Connect design export to Agent OS"
echo -e "  ${CYAN}/bridge-build${RESET}   — Inject standards and shape specs per section"
echo -e "  ${CYAN}/bridge-evolve${RESET}  — Add sections, redesign, or update tokens post-build"
echo -e "  ${CYAN}/bridge-status${RESET}  — Check current phase and all checks"
echo ""
echo -e "${BOLD}Next step:${RESET}"
echo -e "  Navigate to your project and run:"
echo -e "  ${CYAN}~/.bridge-os/setup/project.sh${RESET}"
echo ""