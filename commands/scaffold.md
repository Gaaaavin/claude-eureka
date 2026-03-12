---
name: scaffold
description: Generate boilerplate for common ML research patterns (model, dataset, trainer, config, slurm)
argument-hint: "[model|dataset|trainer|config|slurm]"
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
---

# Scaffold — ML Boilerplate Generator

You generate minimal, convention-matching boilerplate for ML research projects. Always scan the existing codebase first so generated code fits in naturally.

## Argument Parsing

Extract from `$ARGUMENTS`:
- **subcommand**: one of `model`, `dataset`, `trainer`, `config`, `slurm` (required)
- Any additional context the user provides (e.g., model name, dataset path, cluster name)

If no subcommand is given, list the available options and ask which one they need.

---

## Pre-Generation: Convention Discovery

Before generating anything, scan the project to match existing patterns:

1. **Import style**: Grep for `import torch`, `from torch import`, `import lightning` — match the style used.
2. **Config format**: Glob for `*.yaml`, `*.toml`, `*.json` configs. Check for hydra, omegaconf, argparse, or plain dicts.
3. **Project structure**: Glob for `models/`, `data/`, `datasets/`, `trainers/`, `configs/`, `scripts/` — place files where they belong.
4. **Naming conventions**: Check existing files for snake_case vs CamelCase, file naming patterns.
5. **Read `.claude/context/conventions.md`** if it exists for explicit project conventions.

Report what you found before generating. If conventions conflict, ask the user.

---

## Subcommand: `model`

Generate a PyTorch model skeleton.

**Scan**: Grep for `class.*nn\.Module`, `class.*LightningModule` — detect which base class is used.

**Generate**:
```python
"""<Model description — one line>."""

# Imports matching project style

class ModelName(nn.Module):
    """<Docstring if project uses them>."""

    def __init__(self, config):
        super().__init__()
        # TODO: Define layers

    def forward(self, x):
        # TODO: Implement forward pass
        raise NotImplementedError
```

**Adapt based on findings**:
- If project uses `LightningModule`, use that instead and add `training_step`, `configure_optimizers`.
- If project uses `@dataclass` for config, generate a matching config dataclass.
- If project registers models (registry pattern), add registration.
- Match the docstring style (Google, NumPy, or none).

**Ask the user**: Model name, input/output shapes, key architectural choices.

---

## Subcommand: `dataset`

Generate a PyTorch Dataset and DataLoader setup.

**Scan**: Grep for `class.*Dataset`, `torch.utils.data` — detect existing data loading patterns.

**Generate**:
```python
"""<Dataset description>."""

class DatasetName(torch.utils.data.Dataset):
    def __init__(self, root, split="train", transform=None):
        super().__init__()
        self.root = root
        self.split = split
        self.transform = transform
        # TODO: Load file list / annotations

    def __len__(self):
        raise NotImplementedError

    def __getitem__(self, idx):
        # TODO: Load and return sample
        raise NotImplementedError
```

**Adapt based on findings**:
- If project uses `LightningDataModule`, generate that wrapper too.
- If project has a common transform pipeline, import and reuse it.
- If project uses HuggingFace datasets, generate that style instead.
- If project has a `collate_fn` pattern, include one.
- Match path handling (pathlib vs os.path).

**Ask the user**: Dataset name, data format (images, text, point clouds), split strategy.

---

## Subcommand: `trainer`

Generate a training loop or trainer configuration.

**Scan**: Detect the training approach:
- Grep for `for epoch in`, `for batch in` — raw training loop
- Grep for `Trainer`, `lightning` — Lightning trainer
- Grep for `Accelerator`, `accelerate` — HuggingFace Accelerate
- Check for existing training scripts to match structure

**Generate based on detected pattern**:

**Raw loop**: Generate a training script with:
- Argument parsing (matching project style)
- Device setup, seed setting
- Model, optimizer, scheduler instantiation
- Train/val loop with metric logging
- Checkpoint saving
- W&B or TensorBoard logging (if project uses it)

**Lightning**: Generate a `Trainer` configuration with:
- Callbacks (checkpoint, early stopping, LR monitor)
- Logger setup
- Strategy selection (DDP if multi-GPU)

**Accelerate**: Generate `accelerate` config and launch wrapper.

**Ask the user**: What model/dataset to train, key hyperparameters, logging preference.

---

## Subcommand: `config`

Generate a configuration file.

**Scan**: Detect config format:
- Glob for `configs/`, `conf/`, `*.yaml`, `*.toml`
- Grep for `hydra`, `omegaconf`, `OmegaConf` — Hydra/OmegaConf
- Grep for `argparse`, `ArgumentParser` — argparse
- Grep for `@dataclass` with config-like fields — dataclass config

**Generate based on detected format**:

**YAML (plain or Hydra)**:
```yaml
# Experiment config
model:
  name: ""
  # TODO: model parameters

data:
  root: ""
  batch_size: 32
  num_workers: 4

training:
  epochs: 100
  lr: 1e-4
  weight_decay: 1e-5
  seed: 42

logging:
  project: ""
  entity: ""
```

**Dataclass**: Generate a typed config dataclass with defaults.

**Argparse**: Generate argument definitions matching existing style.

Populate defaults from existing configs when possible. Never hardcode absolute paths — use placeholders or environment variables.

**Ask the user**: What the config is for, any specific parameters needed.

---

## Subcommand: `slurm`

Generate a SLURM batch script.

**Scan**: Detect cluster conventions:
- Glob for `*.sbatch`, `*.slurm`, `scripts/` — existing job scripts
- Grep for `#SBATCH`, `module load`, `conda activate`, `srun`
- Check for `$SLURM_JOB_ID` references in training code

**Generate**:
```bash
#!/bin/bash
#SBATCH --job-name=experiment
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
# TODO: Set partition with #SBATCH --partition=

# Module and environment setup
# TODO: module load cuda/...
# TODO: conda activate ...

# Navigate to project
cd $SLURM_SUBMIT_DIR

# Run experiment
srun python train.py --config configs/experiment.yaml
```

**Adapt based on findings**:
- Copy partition, module, and conda patterns from existing `.sbatch` files.
- Match GPU type requests (A100, V100, etc.).
- If multi-node training is used, set up distributed launch correctly.
- Add `--mail-type` and `--mail-user` if found in existing scripts.
- Create `logs/` directory reminder if it doesn't exist.

**Ask the user**: Partition, GPU count/type, time limit, any special requirements.

---

## Post-Generation

After generating any scaffold:

1. **Print what was created** — file path, brief description.
2. **Highlight TODOs** — list the `TODO` items the user needs to fill in.
3. **Suggest next steps** — e.g., "Fill in the model layers, then run `/experiment create` to set up a training run."
4. Never generate more than what was asked for.
