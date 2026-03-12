---
name: update-eureka
description: Update installed claude-eureka commands and skills to the latest version from GitHub
allowed-tools: [Bash]
---

# Update claude-eureka

Pull the latest commands and skills from `Gaaaavin/claude-eureka` and overwrite the installed versions.

## Step 1: Detect install location

Check where eureka is installed:

```bash
if [ -f "$HOME/.claude/eureka-config.json" ]; then
  TARGET="$HOME/.claude"
elif [ -f ".claude/eureka-config.json" ]; then
  TARGET=".claude"
else
  echo "claude-eureka not found. Run the installer first:"
  echo "  curl -fsSL https://raw.githubusercontent.com/Gaaaavin/claude-eureka/main/install.sh | bash"
  exit 1
fi
echo "$TARGET"
```

Read the current version from `$TARGET/eureka-config.json` (the `version` field) to show a before/after comparison.

## Step 2: Download latest

```bash
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

curl -fsSL https://github.com/Gaaaavin/claude-eureka/archive/main.tar.gz \
  | tar xz -C "$TMPDIR"

SRC="$TMPDIR/claude-eureka-main"
```

If the download fails, report the error and stop. Do not modify anything.

## Step 3: Apply update

Overwrite commands, skills, and hooks. Do **not** touch `settings.json` or `eureka-config.json` — those contain user configuration.

```bash
cp "$SRC"/commands/*.md "$TARGET/commands/"
for skill_dir in "$SRC"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  mkdir -p "$TARGET/skills/$skill_name"
  cp "$skill_dir"/* "$TARGET/skills/$skill_name/"
done
cp "$SRC"/framework/hooks/*.sh "$TARGET/hooks/"
chmod +x "$TARGET/hooks/"*.sh
```

Then update the `installedAt` and `version` fields in `$TARGET/eureka-config.json` to reflect the update date and new version.

## Step 4: Report

Print a summary:

```
claude-eureka updated.

  Commands   — N installed
  Skills     — N installed
  Hooks      — updated
  Config     — preserved (settings.json, eureka-config.json)

Restart your Claude Code session to pick up changes.
```

If the version didn't change (already up to date), note that too.
