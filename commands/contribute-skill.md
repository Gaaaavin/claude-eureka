---
name: contribute-skill
description: Package a local skill or command and open a PR to claude-eureka
allowed-tools:
  - Read
  - Bash(git:*, gh:*)
  - Glob
  - Grep
---

## Step 1: Discover local skills

Find all available skills and commands the user has locally.

```bash
echo "=== Commands (.claude/commands/) ==="
ls .claude/commands/*.md 2>/dev/null || echo "(none)"
echo ""
echo "=== Skills (.claude/skills/) ==="
find .claude/skills -name "SKILL.md" 2>/dev/null || echo "(none)"
```

Present the list and ask the user which one they want to contribute. Wait for selection before proceeding.

## Step 2: Validate the selected skill

Read the selected file and verify:

1. **Frontmatter exists** with at least `name` and `description` fields.
2. **No hardcoded paths** — grep for absolute user/system paths. Fail if found.
3. **No secrets or API keys** — grep for patterns like `sk-`, `key=`, `token=`, `secret`, `password`. Warn if found.
4. **Description length** — must be under 200 characters.

If validation fails, report all issues and stop. Let the user fix them first.

## Step 3: Fork the repo

```bash
gh repo fork Gaaaavin/claude-eureka --clone=false 2>/dev/null || true
```

If already forked, this is a no-op. Determine the fork remote name for later use.

## Step 4: Create a contribution branch

```bash
SKILL_NAME="<name-from-frontmatter>"
git checkout -b "contrib/${SKILL_NAME}"
```

## Step 5: Copy skill files

Determine the destination based on file origin:
- Files from `.claude/commands/` go to `commands/` in the fork
- Files from `.claude/skills/` go to `skills/<skill-name>/` in the fork

Copy the file(s) to the appropriate location and stage them.

## Step 6: Open the PR

Commit and push the branch, then open a PR:

```bash
git add .
git commit -m "contrib: add ${SKILL_NAME} skill"
git push -u origin "contrib/${SKILL_NAME}"
```

```bash
gh pr create \
  --repo Gaaaavin/claude-eureka \
  --title "Add skill: ${SKILL_NAME}" \
  --body "## Skill: ${SKILL_NAME}

**Description:** <description from frontmatter>

### What it does
<one-paragraph summary of the skill's purpose>

### How to use it
<example invocation or trigger conditions>

### Testing done
- [ ] Tested locally in a project
- [ ] Passes validation (no hardcoded paths, no secrets)
- [ ] Frontmatter is complete

---
*Submitted via contribute-skill command*"
```

Report the PR URL to the user when done.
