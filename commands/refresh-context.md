---
name: refresh-context
description:
  Re-run project detection and update auto-generated sections of CLAUDE.md
  while preserving user content.
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# Refresh Context

Quick re-scan of the project to update CLAUDE.md auto-sections and compact old context entries.

## Step 1: Validate Existing Setup

Check that CLAUDE.md exists in the project root. If not, tell the user to run `/init-eureka` first.

Read the current CLAUDE.md and identify:
- Content between `<!-- eureka:auto-start -->` and `<!-- eureka:auto-end -->` (will be rewritten)
- Content between `<!-- eureka:user-start -->` and `<!-- eureka:user-end -->` (will be preserved exactly)
- Content outside both marker pairs (will be preserved exactly)

If markers are missing, warn the user and ask whether to proceed (will add markers and may disrupt manual formatting).

## Step 2: Re-run Detection

### Stack detection (same as init-eureka)
- `pyproject.toml`, `setup.py`, `uv.lock`, `requirements.txt`, `Makefile`
- ML framework from imports (torch, jax, tensorflow, lightning)
- W&B / MLflow / TensorBoard
- SLURM scripts, Docker files
- Code quality tools (ruff, pytest, mypy, pre-commit)

### Research context detection (same as init-eureka)
- Experiment directories, config files
- Dataset paths and definitions
- Model files and architectures
- Checkpoint locations
- Entry points (train.py, eval.py, etc.)

### Active state (fresh)
- `git log --oneline -10 --no-decorate`
- `git status --short | head -20`
- TODO/FIXME count in `**/*.py` (just the count, not full listing)

## Step 3: Rebuild Auto Section

Reconstruct the content between `<!-- eureka:auto-start -->` and `<!-- eureka:auto-end -->` using the same format as init-eureka:

```markdown
<!-- eureka:auto-start — DO NOT edit between auto markers; use /refresh-context to update -->

## Identity

- **Project**: {project_name}
- **Stack**: {stack_summary}
- **Description**: {description}

## Key Paths

| Path | Purpose |
|------|---------|
| ... | ... |

## Active Work

- {current focus from git log}
- {open items summary}
- {recent changes}

## Context Files

Detailed context lives in `.claude/context/` — read on demand:

- `.claude/context/experiments.md` — experiment log (hypotheses, results, next steps)
- `.claude/context/conventions.md` — project conventions (naming, config format, logging)
- `.claude/context/architecture.md` — codebase architecture (modules, data flow, key abstractions)

<!-- eureka:auto-end -->
```

Use Edit to replace only the auto section. Do NOT touch user section or content outside markers.

## Step 4: Compact Old Context Entries

For each file in `.claude/context/` (experiments.md, conventions.md, architecture.md):

1. Read the file
2. Look for dated entries (lines starting with `## YYYY-MM-DD` or `### YYYY-MM-DD` or entries with date markers)
3. **Entries older than 2 weeks**: Summarize into a single compact line preserving key facts
4. **Entries older than 1 month**: Move to a `## Archive` section at the bottom of the file
5. **Recent entries (< 2 weeks)**: Leave untouched

Use today's date from `date +%Y-%m-%d` for age calculations.

If a context file does not exist, skip it (do not create — that is init-eureka's job).

If a context file has no dated entries or is a fresh starter file, skip compaction.

## Step 5: Report

```
Context refreshed.

  CLAUDE.md     — auto-section updated ({N} lines)
  User section  — preserved ({M} lines)
  Stack         — {stack_summary}
  Active work   — {summary}
  Compacted     — {count} old entries across context files
```
