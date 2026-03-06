#!/bin/bash
# =============================================================================
# Bridge OS — sync.sh
# Connects Design OS export to Agent OS standards and product context.
# Usage: .bridge-os/sync.sh [--tokens-only] [--dry-run] [--section <name>]
# =============================================================================

set -e

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Flags ─────────────────────────────────────────────────────────────────────
DRY_RUN=false
TOKENS_ONLY=false
SECTION=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)      DRY_RUN=true; shift ;;
    --tokens-only)  TOKENS_ONLY=true; shift ;;
    --section)      SECTION="$2"; shift 2 ;;
    *)              shift ;;
  esac
done

# ── Config ────────────────────────────────────────────────────────────────────
CONFIG=".bridge-os/config.yml"
STATE=".bridge-os/state.json"

if [ ! -f "$CONFIG" ]; then
  echo -e "${RED}✗ config.yml not found at .bridge-os/config.yml${RESET}"
  echo -e "  Run ${CYAN}~/.bridge-os/setup/project.sh${RESET} to initialize Bridge OS in this project."
  exit 1
fi

# Parse config (requires yq — fallback to grep/sed if not available)
if command -v yq &>/dev/null; then
  DESIGN_OS_PATH=$(yq '.design_os.path' "$CONFIG")
  EXPORT_DIR=$(yq '.design_os.export_dir' "$CONFIG")
  STANDARDS_DIR=$(yq '.agent_os.standards_dir' "$CONFIG")
  PRODUCT_DIR=$(yq '.agent_os.product_dir' "$CONFIG")
  EXPORT_DEST=$(yq '.bridge.export_dest' "$CONFIG")
else
  DESIGN_OS_PATH=$(grep 'path:' "$CONFIG" | head -1 | awk '{print $2}' | tr -d '"')
  EXPORT_DIR=$(grep 'export_dir:' "$CONFIG" | awk '{print $2}' | tr -d '"')
  STANDARDS_DIR=$(grep 'standards_dir:' "$CONFIG" | awk '{print $2}' | tr -d '"')
  PRODUCT_DIR=$(grep 'product_dir:' "$CONFIG" | awk '{print $2}' | tr -d '"')
  EXPORT_DEST=$(grep 'export_dest:' "$CONFIG" | awk '{print $2}' | tr -d '"')
fi

EXPORT_PATH="$DESIGN_OS_PATH/$EXPORT_DIR"

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}🌉 Bridge OS — Sync${RESET}"
echo -e "────────────────────────────────"
[ "$DRY_RUN" = true ] && echo -e "${YELLOW}[DRY RUN] No files will be written${RESET}\n"

# ── PHASE LOCK: verify Design OS export exists ────────────────────────────────
echo -e "${CYAN}→ Checking Design OS export...${RESET}"

if [ ! -d "$EXPORT_PATH" ]; then
  echo ""
  echo -e "${RED}${BOLD}🚫 PHASE LOCK: Design OS export not found.${RESET}"
  echo ""
  echo -e "   Expected at: ${YELLOW}$EXPORT_PATH${RESET}"
  echo ""
  echo -e "   Complete the design phase first:"
  echo -e "   ${CYAN}1.${RESET} Open your Design OS repo"
  echo -e "   ${CYAN}2.${RESET} Run ${BOLD}/export-product${RESET} in Claude Code"
  echo -e "   ${CYAN}3.${RESET} Re-run this sync"
  echo ""
  exit 1
fi

# ── Verify required export files ─────────────────────────────────────────────
# Real structure produced by Design OS /export-product (product-plan/):
#   design-system/  sections/  shell/  prompts/  product-overview.md
REQUIRED=("design-system" "sections" "shell" "prompts" "product-overview.md")
MISSING=()

for file in "${REQUIRED[@]}"; do
  [ ! -e "$EXPORT_PATH/$file" ] && MISSING+=("$file")
done

if [ ${#MISSING[@]} -gt 0 ]; then
  echo ""
  echo -e "${YELLOW}⚠ Incomplete export. Missing:${RESET}"
  for f in "${MISSING[@]}"; do
    echo -e "   ${RED}✗${RESET} $f"
  done
  echo ""
  echo -e "   Run ${BOLD}/export-product${RESET} again in Design OS."
  echo ""
  exit 1
fi

echo -e "${GREEN}✓ Design OS export verified${RESET}"
echo ""

# ── Sync ──────────────────────────────────────────────────────────────────────

# 1. Copy export to project
if [ "$TOKENS_ONLY" = false ]; then
  echo -e "${CYAN}→ Copying design-export/...${RESET}"
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "./$EXPORT_DEST"
    if [ -n "$SECTION" ]; then
      mkdir -p "./$EXPORT_DEST/sections"
      cp -r "$EXPORT_PATH/sections/$SECTION" "./$EXPORT_DEST/sections/$SECTION"
      echo -e "   ${GREEN}✓${RESET} Section '$SECTION' copied"
    else
      cp -r "$EXPORT_PATH/." "./$EXPORT_DEST/"
      echo -e "   ${GREEN}✓${RESET} Full export copied to $EXPORT_DEST/"
    fi
  else
    echo -e "   [dry-run] Would copy $EXPORT_PATH → ./$EXPORT_DEST/"
  fi
fi

# 2. Generate design-system.md standard for Agent OS
echo -e "${CYAN}→ Generating design-system.md for Agent OS...${RESET}"
if [ "$DRY_RUN" = false ]; then
  mkdir -p "$STANDARDS_DIR"
  node "$(dirname "$0")/generate-standard.js" \
    --export "./$EXPORT_DEST" \
    --output "$STANDARDS_DIR/design-system.md"
  echo -e "   ${GREEN}✓${RESET} $STANDARDS_DIR/design-system.md generated"
else
  echo -e "   [dry-run] Would generate $STANDARDS_DIR/design-system.md"
fi

# 3. Sync product requirements to Agent OS product/
if [ "$TOKENS_ONLY" = false ]; then
  echo -e "${CYAN}→ Syncing product requirements...${RESET}"
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$PRODUCT_DIR"
    cp "./$EXPORT_DEST/product-overview.md" "$PRODUCT_DIR/design-requirements.md"
    echo -e "   ${GREEN}✓${RESET} $PRODUCT_DIR/design-requirements.md updated"
  else
    echo -e "   [dry-run] Would copy product-overview.md → $PRODUCT_DIR/design-requirements.md"
  fi
fi

# 4. Update bridge state
if [ "$DRY_RUN" = false ]; then
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  HASH=$(md5sum "./$EXPORT_DEST/product-overview.md" 2>/dev/null | awk '{print $1}' \
      || md5 -q "./$EXPORT_DEST/product-overview.md" 2>/dev/null || echo "n/a")

  cat > "$STATE" <<EOF
{
  "phase": "agent",
  "last_sync": "$TIMESTAMP",
  "export_hash": "$HASH",
  "section": "${SECTION:-all}",
  "tokens_only": $TOKENS_ONLY
}
EOF
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}✅ Bridge sync complete${RESET}"
echo ""
echo -e "   Phase: ${GREEN}AGENT OS enabled${RESET}"
echo -e "   Next:  Run ${BOLD}/bridge-build${RESET} to inject standards and shape specs"
echo ""