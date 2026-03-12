# Contributing to claude-eureka

Guidelines for contributing skills and commands.

## Quick Start

1. **Author a skill or command** using `/create-skill` inside Claude Code. It scaffolds the correct structure for you.
2. **Submit your contribution** using `/contribute-skill`, which opens a PR from your fork.

If you prefer to do it manually, read on.

## Skill Structure

A skill lives in `skills/<skill-name>/` and must contain a `SKILL.md` file.

```
skills/
  my-skill/
    SKILL.md          # Required — main skill definition
    helpers.py        # Optional — reference files for complex logic
    prompts/          # Optional — prompt templates, examples
```

**SKILL.md requirements:**

- YAML frontmatter with at least `name` and `description` (under 200 characters)
- Body under 500 lines — if you need more, split logic into reference files
- Reference files are loaded on demand, not on every invocation

```yaml
---
name: my-skill
description: One-line description of what this skill does
---
```

## Command Structure

A command is a single `.md` file in `commands/`.

```
commands/
  my-command.md
```

**Frontmatter fields:**

| Field | Required | Purpose |
|---|---|---|
| `name` | Yes | Command name (used as `/name`) |
| `description` | Yes | Under 200 characters |
| `argument-hint` | No | Hint shown for expected arguments |
| `allowed-tools` | No | Restrict which tools the command may use |

```yaml
---
name: my-command
description: What this command does
argument-hint: "<experiment-name>"
allowed-tools: ["Bash", "Read", "Write", "Edit"]
---
```

Body should be under 300 lines. Use progressive disclosure: put the critical instructions up front, details later.

## Style Guide

### Conciseness

The context window is shared with the user's conversation. Every line in your skill or command competes for space. Only include information Claude does not already know.

Bad: "Python is a programming language. To run a Python script, use `python script.py`."
Good: "Run the benchmark suite with `--fast` to skip slow integration tests."

### Progressive disclosure

Three layers of loading:

1. **Metadata** (frontmatter) -- always loaded when listing skills/commands
2. **Body** (SKILL.md / command .md) -- loaded when the skill/command is triggered
3. **Reference files** -- loaded on demand within the skill's logic

Design so that most invocations only need layers 1-2.

### Tool constraints

Use `allowed-tools` to limit scope. A command that only reads code should not have Write/Edit access. This prevents accidental side effects.

### Portability

- No hardcoded absolute paths (`/Users/...`, `/home/...`, `/data/...`)
- No secrets or API keys -- use environment variables
- Assume PyTorch, Linux, and `uv` as defaults, but do not break on macOS, conda, or pip

## PR Process

1. Fork the repository
2. Create a branch: `git checkout -b add-my-skill`
3. Add your files under `commands/` or `skills/`
4. Push and open a PR: `gh pr create`
5. CI runs validation checks (frontmatter, line counts, no hardcoded paths)
6. Address any review feedback

## Testing

Before submitting:

1. Install locally: `./install.sh`
2. Start a **new** Claude Code session (skills are loaded at session start)
3. Trigger your skill or command and verify:
   - It activates on the expected input
   - Output is correct and concise
   - No unintended file modifications
   - Works without your specific environment setup

## What Makes a Good Skill

- **Solves a real workflow problem.** If you find yourself repeating the same multi-step process, it is a candidate.
- **Is concise.** A 50-line skill that nails one thing beats a 400-line skill that tries to cover everything.
- **Follows existing patterns.** Look at `commands/` and `skills/` for examples before writing from scratch.
- **Fails gracefully.** Includes error handling or clear messages when preconditions are not met.
- **Is well-scoped.** One skill, one job. Compose multiple skills rather than building monoliths.
