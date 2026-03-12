---
name: init-eureka
description:
  Scan a research project and generate a tailored CLAUDE.md with detected stack,
  research context, and active work state.
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
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

Read the template at `framework/CLAUDE.md.template` (relative to the claude-eureka install, not the target project).

If the template is not found at the expected path, check:
- The directory where this command file lives: `../framework/CLAUDE.md.template`
- Fall back to a sensible default structure if template is missing.

Fill in the auto-generated sections between `<!-- eureka:auto-start -->` and `<!-- eureka:auto-end -->`:

### Identity section
```markdown
- **Project**: {project_name}
- **Stack**: {stack_summary}
- **Description**: {description}
```

### Key Paths table
```markdown
| Path | Purpose |
|------|---------|
| src/models/ | Model definitions |
| configs/ | Training configs (Hydra) |
| scripts/ | SLURM job scripts |
| data/ | Dataset root |
```

### Active Work
```markdown
- Current focus: {summarized from git log}
- Open items: {TODO/FIXME count}
- Recent changes: {last 3 commits summarized}
```

Write the completed CLAUDE.md to the project root.

**Project name**: If not provided as argument and not detectable from `pyproject.toml` or
`setup.py` or directory name, ask the user with AskUserQuestion.

**Description**: If not detectable, ask the user.

Keep the output CLAUDE.md to ~50 lines of high-signal content. No filler.

## Step 5: Create Context Files

Create `.claude/context/` directory and populate starter files:

### `.claude/context/experiments.md`
```markdown
# Experiment Log

Record experiment hypotheses, configs, results, and next steps here.
This file is updated by the agent when experiments complete.

<!-- Entries below -->
```

### `.claude/context/conventions.md`
```markdown
# Project Conventions

Coding standards, naming patterns, config formats, and resolved gotchas.

<!-- Entries below -->
```

### `.claude/context/architecture.md`
```markdown
# Architecture

Key modules, data flow, and design decisions.

<!-- Entries below -->
```

Pre-populate `architecture.md` with the detected model files and entry points from Step 2.

## Step 6: Report

Print a summary:
```
Bootstrap complete.

  CLAUDE.md        — written (N lines)
  context/         — experiments.md, conventions.md, architecture.md
  Stack detected   — {stack_summary}
  Key paths        — {count} entries
  Active work      — {summary}

Run /refresh-context anytime to update auto-generated sections.
```
