#!/bin/bash
# Skill discovery hook - suggests relevant skills when user mentions "skill"
# Exit 0 stdout → added as context for Claude
# No dependencies - pure bash

# Read all stdin
INPUT=$(cat)

# Extract the prompt field (pure bash, no jq)
PROMPT=$(echo "$INPUT" | sed -nE 's/.*"prompt"[[:space:]]*:[[:space:]]*"(([^\\"]|\\.)*)".*/\1/p')

# Match: skill, skills (case-insensitive, word boundary)
if echo "$PROMPT" | grep -iqE '\bskills?\b'; then
  # Check plugin-native, user-level, and project-level skills directories
  SEARCH_DIRS=()
  [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && SEARCH_DIRS+=("${CLAUDE_PLUGIN_ROOT}/skills")
  SEARCH_DIRS+=("${HOME}/.claude/skills" ".claude/skills")

  for SKILLS_DIR in "${SEARCH_DIRS[@]}"; do
    if [ -d "$SKILLS_DIR" ]; then
      output=""
      for d in "$SKILLS_DIR"/*/; do
        [ -d "$d" ] || continue
        name=$(basename "$d")
        skill_file="$d/SKILL.md"
        if [ -f "$skill_file" ]; then
          desc=$(grep -m1 '^description:' "$skill_file" | sed 's/^description: *//')
          output="$output$name: $desc"$'\n'
        else
          output="$output$name"$'\n'
        fi
      done

      if [ -n "$output" ]; then
        echo "<skill-discovery>"
        echo "The user mentioned 'skill'. Available skills in $(basename "$SKILLS_DIR"):"
        echo ""
        echo "$output" | sort
        echo "If relevant to the user's request, read the SKILL.md file to load the skill instructions."
        echo "</skill-discovery>"
      fi
    fi
  done
fi

# Always exit 0 - never block user prompts
exit 0
