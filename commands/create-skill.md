---
name: create-skill
description: Author new Claude Code skills or commands for ML/AI research workflows
allowed-tools: Read, Write, Glob, Grep
---

# Create a New Skill or Command

Guide the user through authoring a Claude Code extension.

## Key Concepts

**Commands** (like this one): Explicit `/slash` invocations. Single `.md` file in `.claude/commands/`. The user types `/command-name` to run it.

**Skills**: Passive capabilities that activate automatically when relevant. Live in `.claude/skills/<name>/SKILL.md`. Triggered by hooks or pattern matching on user prompts — no explicit invocation needed.

### Core Principles

1. **Conciseness** — The skill/command text is injected into the context window alongside user code and conversation. Every line competes for space. Cut ruthlessly. Target: commands < 150 lines, skills < 100 lines.
2. **Degrees of freedom** — Specify *what* to do and *constraints*, not *how*. Let the model choose the implementation. Bad: "Use `os.path.join` to construct the path." Good: "Construct the full path to the config file."
3. **Progressive disclosure** — Start with the minimal instruction set. Add detail only in sections the model reads on-demand (e.g., "If the user asks about X, then...").

---

## Step 1 — Define the Extension

Ask the user:

1. **What should it do?** Get a one-paragraph description.
2. **Skill or command?**
   - Does the user invoke it explicitly? -> **Command**
   - Should it activate automatically in certain contexts? -> **Skill**
3. **What tools does it need?** (Read, Write, Edit, Bash, Glob, Grep, WebFetch, WebSearch, etc.)
4. **What arguments does it accept?** (for commands only)

## Step 2 — Generate the File(s)

### For a Command

Create a single `.md` file:

```
.claude/commands/<name>.md
```

Structure:
```markdown
---
name: <kebab-case-name>
description: <one-line summary>
argument-hint: "<what the user provides>"
allowed-tools: <comma-separated tool list>
---

# <Title>

**Input:** $ARGUMENTS

## Step 1 — <First action>
...

## Step 2 — <Second action>
...
```

### For a Skill

Create a directory with a `SKILL.md`:

```
.claude/skills/<name>/SKILL.md
```

Structure:
```markdown
---
name: <kebab-case-name>
description: <one-line summary>
triggers:
  - <pattern or context that activates this skill>
---

# <Title>

## When to Activate
<Conditions under which this skill should engage>

## Behavior
<What to do when activated>

## Constraints
<Boundaries — what NOT to do>
```

## Step 3 — Install Locally

Copy the generated file(s) to the appropriate location:

```bash
# Command
cp <generated>.md .claude/commands/

# Skill
mkdir -p .claude/skills/<name>
cp SKILL.md .claude/skills/<name>/
```

Verify the file is in place:
```bash
ls -la .claude/commands/<name>.md   # or
ls -la .claude/skills/<name>/SKILL.md
```

## Step 4 — Test

Tell the user:

1. **Start a new Claude Code session** (skills and commands are loaded at session start)
2. For commands: type `/<name>` and verify it appears in autocomplete
3. For skills: describe a scenario that should trigger it and verify activation
4. Iterate — edit the `.md` file and restart to test changes

## Step 5 — Share Back (Optional)

Offer to contribute the skill to the claude-eureka collection:

> Want to share this with other researchers? Run `/contribute-skill` to package it and open a PR to the claude-eureka repo.

## Checklist Before Finishing

- [ ] File is under 150 lines (commands) or 100 lines (skills)
- [ ] Frontmatter has all required fields
- [ ] Instructions use *what/constraints* style, not *how* style
- [ ] No redundant examples — one clear example per concept max
- [ ] Tool list in `allowed-tools` is minimal (don't grant tools you don't need)
