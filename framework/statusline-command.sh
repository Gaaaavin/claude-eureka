#!/usr/bin/env bash
# Claude Code status line — single line
# Shows: model | workdir (branch) | context usage | permission mode

input=$(cat)

model_display=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

# Workdir (branch)
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
workdir=""
if [ -n "$cwd" ]; then
  workdir=$(basename "$cwd")
  git_branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
  [ -n "$git_branch" ] && workdir="$workdir ($git_branch)"
fi

# Context
window_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
used_pct=$(echo "$input"    | jq -r '.context_window.used_percentage // empty')

if [ -n "$window_size" ] && [ "$window_size" -gt 0 ] 2>/dev/null; then
  if [ -n "$used_pct" ]; then
    in_k=$(( (used_pct * window_size / 100 + 500) / 1000 ))
    win_k=$(( (window_size + 500) / 1000 ))
    ctx_str="${in_k}k/${win_k}k (${used_pct}%)"
  else
    ctx_str="—"
  fi
else
  ctx_str="—"
fi

# Permission mode — check user-level settings, then project-level
perm_mode=$(jq -r '.defaultMode // empty' ~/.claude/settings.json 2>/dev/null)
[ -z "$perm_mode" ] && perm_mode=$(jq -r '.defaultMode // empty' ~/.claude/settings.local.json 2>/dev/null)
[ -z "$perm_mode" ] && perm_mode=$(jq -r '.defaultMode // empty' .claude/settings.json 2>/dev/null)
[ -z "$perm_mode" ] && perm_mode="default"

case "$perm_mode" in
  bypassPermissions) perm_label="bypass" ;;
  acceptEdits)       perm_label="auto-edit" ;;
  *)                 perm_label="$perm_mode" ;;
esac

# Build line
parts="$model_display"
[ -n "$workdir" ] && parts="$parts | $workdir"
parts="$parts | $ctx_str"

if [ "$perm_mode" = "bypassPermissions" ]; then
  printf "\033[2m%s | \033[0m\033[31mPermission: %s\033[0m\n" "$parts" "$perm_label"
else
  printf "\033[2m%s | Permission: %s\033[0m\n" "$parts" "$perm_label"
fi
