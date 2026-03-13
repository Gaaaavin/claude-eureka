#!/bin/bash
set -euo pipefail

# claude-eureka installer
# Installs Claude Code skills for ML/AI researchers
# Usage: curl -fsSL https://raw.githubusercontent.com/Gaaaavin/claude-eureka/main/install.sh | bash

EUREKA_VERSION="0.1.2"
EUREKA_REPO="Gaaaavin/claude-eureka"
EUREKA_BRANCH="main"
TARBALL_URL="https://github.com/${EUREKA_REPO}/archive/${EUREKA_BRANCH}.tar.gz"

# Colors (disabled if not interactive or piped)
if [ -t 1 ]; then
  BOLD="\033[1m"
  DIM="\033[2m"
  GREEN="\033[32m"
  YELLOW="\033[33m"
  CYAN="\033[36m"
  RESET="\033[0m"
else
  BOLD="" DIM="" GREEN="" YELLOW="" CYAN="" RESET=""
fi

info()  { echo -e "${CYAN}${BOLD}>>>${RESET} $1"; }
ok()    { echo -e "${GREEN}${BOLD} ok${RESET} $1"; }
warn()  { echo -e "${YELLOW}${BOLD}  !${RESET} $1"; }

# ─── Download source to temp dir ─────────────────────────────────────────────
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Check if we're running from a local clone (dev mode)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || SCRIPT_DIR=""
if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/commands" ] && [ -d "$SCRIPT_DIR/framework" ]; then
  SRC="$SCRIPT_DIR"
else
  # Download from GitHub
  info "Downloading claude-eureka v${EUREKA_VERSION}..."
  curl -fsSL "$TARBALL_URL" | tar xz -C "$TMPDIR"
  SRC="$TMPDIR/claude-eureka-${EUREKA_BRANCH}"
  if [ ! -d "$SRC/commands" ]; then
    echo "Error: Download failed or archive structure unexpected."
    exit 1
  fi
  ok "downloaded"
fi

# ─── Choose install location ─────────────────────────────────────────────────
echo ""
echo -e "${BOLD}claude-eureka${RESET} v${EUREKA_VERSION}"
echo -e "${DIM}Claude Code skills for ML/AI researchers${RESET}"
echo ""

echo "Where should eureka be installed?"
echo ""
echo "  1) User-level (~/.claude/)    — available in all projects (recommended)"
echo "  2) Project-level (./.claude/) — scoped to this project"
echo ""

# Handle piped input (curl | bash) — need to read from /dev/tty
if [ -t 0 ]; then
  read -rp "Choice [1]: " choice
else
  read -rp "Choice [1]: " choice < /dev/tty
fi
choice="${choice:-1}"

if [ "$choice" = "1" ]; then
  TARGET="$HOME/.claude"
  INSTALL_TYPE="user"
  info "Installing to ~/.claude/ (user-level)"
else
  TARGET="./.claude"
  INSTALL_TYPE="project"
  info "Installing to ./.claude/ (project-level)"
fi

mkdir -p "$TARGET"

# ─── Copy commands ────────────────────────────────────────────────────────────
info "Installing commands..."
mkdir -p "$TARGET/commands"
cp "$SRC"/commands/*.md "$TARGET/commands/"
cmd_count=$(ls "$SRC"/commands/*.md | wc -l | tr -d ' ')
ok "${cmd_count} commands installed"

# ─── Copy skills ──────────────────────────────────────────────────────────────
info "Installing skills..."
skill_count=0
for skill_dir in "$SRC"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  mkdir -p "$TARGET/skills/$skill_name"
  cp "$skill_dir"/* "$TARGET/skills/$skill_name/" 2>/dev/null || true
  skill_count=$((skill_count + 1))
done
ok "${skill_count} skills installed"

# ─── Copy hooks ───────────────────────────────────────────────────────────────
info "Installing hooks..."
mkdir -p "$TARGET/hooks"
cp "$SRC"/hooks/*.sh "$TARGET/hooks/"
chmod +x "$TARGET/hooks/"*.sh
ok "hooks installed"

# ─── Copy framework files ─────────────────────────────────────────────────────
mkdir -p "$TARGET/framework"
cp "$SRC/framework/CLAUDE.md.template" "$TARGET/framework/CLAUDE.md.template"
cp "$SRC/framework/statusline-command.sh" "$TARGET/statusline-command.sh"
chmod +x "$TARGET/statusline-command.sh"

# ─── Merge settings.json ─────────────────────────────────────────────────────
info "Configuring hooks..."
SETTINGS_FILE="$TARGET/settings.json"

# Compute hook path
if [ "$INSTALL_TYPE" = "user" ]; then
  HOOK_PATH="\${HOME}/.claude"
else
  HOOK_PATH=".claude"
fi

if [ -f "$SETTINGS_FILE" ]; then
  if grep -q "skill-discovery" "$SETTINGS_FILE" 2>/dev/null; then
    ok "skill-discovery hook already configured"
  else
    warn "settings.json exists — add the hook manually:"
    echo ""
    echo "  Add to hooks.UserPromptSubmit:"
    echo "  {\"command\": \"$HOOK_PATH/hooks/skill-discovery.sh\", \"timeout\": 5000, \"type\": \"command\"}"
    echo ""
  fi
else
  sed "s|__EUREKA_HOOK_PATH__|$HOOK_PATH|g" \
    "$SRC/framework/settings.json.template" > "$SETTINGS_FILE"
  ok "settings.json created"
fi

# ─── Write eureka config ─────────────────────────────────────────────────────
CONFIG_FILE="$TARGET/eureka-config.json"
INSTALL_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

sed -e "s|__INSTALL_DATE__|$INSTALL_DATE|g" \
    -e "s|__INSTALL_PATH__|$TARGET|g" \
    -e "s|__INSTALL_TYPE__|$INSTALL_TYPE|g" \
    "$SRC/framework/eureka-config.json.template" > "$CONFIG_FILE"
ok "eureka-config.json created"


# ─── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Installation complete!${RESET}"
echo ""
echo "Installed to: $TARGET"
echo ""
echo -e "${BOLD}Next steps:${RESET}"
echo ""
echo "  1. Run /init-eureka in Claude Code to auto-detect your project"
echo "     and generate a tailored CLAUDE.md"
echo ""
echo -e "${DIM}For users on Claude Code with plugin support, the preferred install is:${RESET}"
echo ""
echo "  /plugin marketplace add Gaaaavin/claude-eureka"
echo "  /plugin install claude-eureka@claude-eureka"
echo ""
echo -e "${DIM}(This curl|bash install is the fallback for older Claude Code versions.)${RESET}"
echo ""
echo -e "${BOLD}Recommended MCP servers:${RESET}"
echo ""
echo "  # Weights & Biases (experiment tracking)"
echo "  claude mcp add wandb -- npx -y @anthropic-ai/mcp-wandb@latest"
echo ""
echo "  # GitHub (PRs, issues, code search)"
echo "  claude mcp add github -- npx -y @anthropic-ai/mcp-github@latest"
echo ""
echo -e "${BOLD}Available commands:${RESET}"
echo ""
echo "  /init-eureka        Scan project, generate CLAUDE.md"
echo "  /refresh-context  Update auto-generated context"
echo "  /experiment       Create, launch, track experiments"
echo "  /debug            Systematic root-cause debugging"
echo "  /review           Code review (YAGNI/KISS + research)"
echo "  /scaffold         Generate boilerplate (model, dataset, etc.)"
echo "  /viz              Publication-quality plots"
echo "  /notebook         Analysis notebook generation"
echo "  /submit-job       SLURM job submission & monitoring"
echo "  /create-skill     Author new skills"
echo "  /contribute-skill Package skill → PR to claude-eureka"
echo "  /update-eureka    Update to latest version"
echo ""
