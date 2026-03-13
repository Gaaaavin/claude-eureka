---
name: init-eureka
description:
  Scan a research project and generate a tailored CLAUDE.md with detected stack,
  research context, and active work state.
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion]
argument-hint: "(optional) project name"
---

# Bootstrap Research Project

Scan the current project and generate a CLAUDE.md tailored for ML/AI research.

## Step 1: Detect Stack

Run these checks to identify the project's tooling:

### Package management
- `pyproject.toml` — check for build system (setuptools, flit, hatch, poetry)
- `setup.py` or `setup.cfg`
- `uv.lock` or `.python-version` — uv
- `requirements.txt`, `requirements/*.txt`, `environment.yml` — pip/conda
- `Makefile` — build targets

### ML/AI framework
- Search imports in `**/*.py` for: torch, tensorflow, jax, flax, keras, lightning
- Check for `accelerate` config, `deepspeed` config
- Look for mixed precision config (AMP, bf16, fp16 references)

### Experiment tracking
- `.wandb/` or `wandb/` directories, `WANDB_PROJECT` in env/config
- `mlflow/` or MLflow references
- `tensorboard/` or TensorBoard references
- `sacred/` config files

### Compute
- `*.sbatch` or `*.slurm` files — SLURM cluster
- `Dockerfile`, `docker-compose.yml`
- Check for CUDA version references, `nvidia-smi` availability

### Code quality
- `.pre-commit-config.yaml`, `ruff.toml`, `.flake8`, `mypy.ini`
- `pytest.ini`, `conftest.py`, `tox.ini`

Collect results into a stack summary like:
```
Python 3.11 | PyTorch 2.x | Lightning | uv | W&B | SLURM | ruff + pytest
```

## Step 2: Detect Research Context

### Experiment structure
- Glob for directories named: `experiments/`, `exp/`, `runs/`, `outputs/`, `logs/`, `results/`
- Glob for config files: `configs/**/*.yaml`, `conf/**/*.yaml`, `**/*.json` (Hydra, OmegaConf patterns)
- Check for Hydra: `.hydra/`, `hydra` in imports, `@hydra.main` decorator

### Data
- Look for data paths in configs and code: `data/`, `datasets/`, `DATA_ROOT`, `data_dir`
- Check for dataset class definitions (subclasses of `Dataset`, `IterableDataset`)
- Note any referenced public datasets (ImageNet, COCO, MSLS, etc.)

### Model architecture
- Glob `**/model*.py`, `**/network*.py`, `**/backbone*.py`, `**/arch*.py`
- Identify model definitions (classes inheriting `nn.Module`)
- Note key model files and what they define

### Checkpoints
- Glob for: `checkpoints/`, `ckpt/`, `*.ckpt`, `*.pth`, `*.pt`, `*.safetensors`
- Note checkpoint naming patterns

### Key entry points
- Look for `train.py`, `eval.py`, `test.py`, `main.py`, `run.py`
- Check `pyproject.toml` for `[project.scripts]` entry points
- Check `Makefile` for common targets (train, eval, test)

Collect into a key paths table.

## Step 3: Detect Active State

### Recent git activity
Run: `git log --oneline -10 --no-decorate`
Summarize the current work direction from commit messages.

### Open work
Run: `git status --short | head -20`
Search for `TODO`, `FIXME`, `HACK`, `XXX` in Python files (limit to 10 results).

### W&B state (if detected)
Check for recent W&B runs in config or environment.

Summarize as 2-3 bullet points of current focus.

## Step 4: Generate CLAUDE.md

First, check whether `CLAUDE.md` already exists in the project root.

### Case A — CLAUDE.md exists with eureka markers

If the file contains `<!-- eureka:auto-start -->` and `<!-- eureka:auto-end -->`:
- Use Edit to replace **only** the content between those markers with the new auto section.
- Preserve everything outside the markers exactly — do not touch user content.
- Do not ask for confirmation; this is a safe, targeted update.

### Case B — CLAUDE.md exists without eureka markers

If the file exists but has no eureka markers:
- Read the full existing content.
- Prepend the new auto section (wrapped in markers) at the top.
- Wrap the original content in `<!-- eureka:user-start -->` / `<!-- eureka:user-end -->` markers.
- Inform the user what was done. Their original content is preserved verbatim inside the user block.

### Case C — CLAUDE.md does not exist

Locate the eureka template using this priority order:
1. If `$CLAUDE_PLUGIN_ROOT` is set, try `$CLAUDE_PLUGIN_ROOT/framework/CLAUDE.md.template`
2. Read `~/.claude/eureka-config.json` with Bash (`cat ~/.claude/eureka-config.json 2>/dev/null`), extract `installPath`, then read `{installPath}/framework/CLAUDE.md.template`
3. Try `~/.claude/framework/CLAUDE.md.template`
4. Try `.claude/framework/CLAUDE.md.template`
5. Fall back to the inline default structure below if none found

Write the completed file to the project root.

---

### Auto section content (all cases)

Fill in the content between `<!-- eureka:auto-start -->` and `<!-- eureka:auto-end -->`:

```markdown
## Identity

- **Project**: {project_name}
- **Stack**: {stack_summary}
- **Description**: {description}

## Key Paths

| Path | Purpose |
|------|---------|
| {detected paths} | {purpose} |

## Active Work

- Current focus: {summarized from git log}
- Open items: {TODO/FIXME count}
- Recent changes: {last 3 commits summarized}

## Context Files

Detailed context lives in `.claude/context/` — read on demand:

- `.claude/context/experiments.md` — experiment log
- `.claude/context/conventions.md` — project conventions
- `.claude/context/architecture.md` — codebase architecture
```

**Project name**: Detect from `pyproject.toml`, `setup.py`, or directory name. If not detectable, ask with AskUserQuestion.

**Description**: If not detectable, ask the user.

Keep the auto section concise — ~30 lines. No filler.

## Step 5: Create Context Files

Create `.claude/context/` directory if it doesn't exist. For each file below, **skip if it already exists** — never overwrite existing context.

### `.claude/context/experiments.md` (create if missing)
```markdown
# Experiment Log

Record experiment hypotheses, configs, results, and next steps here.
This file is updated by the agent when experiments complete.

<!-- Entries below -->
```

### `.claude/context/conventions.md` (create if missing)
```markdown
# Project Conventions

Coding standards, naming patterns, config formats, and resolved gotchas.

<!-- Entries below -->
```

### `.claude/context/architecture.md` (create if missing)
```markdown
# Architecture

Key modules, data flow, and design decisions.

<!-- Entries below -->
```

Pre-populate `architecture.md` (only if newly created) with the detected model files and entry points from Step 2.

## Step 6: Status Line Setup (optional)

Check if the eureka status line is already configured:

```bash
jq -e '.statusLine' ~/.claude/settings.json 2>/dev/null
```

Locate `statusline-command.sh` using this priority order:
1. `$CLAUDE_PLUGIN_ROOT/framework/statusline-command.sh` (plugin install)
2. `~/.claude/statusline-command.sh` (curl|bash install)

If the statusLine key is absent **and** the statusline script is found at one of those paths, ask the user:

> "Would you like to enable the eureka status line? It shows model, context usage, git branch, and permission mode in the terminal."

If the user says yes:
1. Use whichever path was found above (plugin root first, then `~/.claude/`): `STATUSLINE="<found path>"`
2. Merge into `~/.claude/settings.json` using jq:
   ```bash
   jq --arg cmd "bash $STATUSLINE" '. + {statusLine: {type: "command", command: $cmd}}' \
     ~/.claude/settings.json > /tmp/_eureka_settings.json \
     && mv /tmp/_eureka_settings.json ~/.claude/settings.json
   ```
3. Note: requires `jq`. If jq is unavailable, print the JSON snippet to add manually.

If neither statusline path exists, skip silently.

## Step 7: Report

Print a summary:
```
Bootstrap complete.

  CLAUDE.md        — written (N lines)
  context/         — experiments.md, conventions.md, architecture.md
  Stack detected   — {stack_summary}
  Key paths        — {count} entries
  Active work      — {summary}
  Status line      — enabled  (or: skipped)

Run /refresh-context anytime to update auto-generated sections.
```
