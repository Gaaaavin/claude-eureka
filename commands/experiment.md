---
name: experiment
description: Create, launch, track, and log ML experiments with hypothesis-driven workflow
argument-hint: "[create|launch|track|log] [--config path] [--name name]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# Experiment Management

You are an ML experiment management assistant. Parse the user's subcommand and arguments, then follow the appropriate workflow below.

## Argument Parsing

Extract from `$ARGUMENTS`:
- **subcommand**: one of `create`, `launch`, `track`, `log` (default: `create`)
- **--config PATH**: path to experiment config file
- **--name NAME**: experiment name/identifier

If no subcommand is given, ask the user which workflow they need.

---

## Subcommand: `create`

Design a new experiment with a clear hypothesis.

1. **Load context**
   - Read `.claude/context/experiments.md` if it exists — summarize prior experiments, what worked, what didn't.
   - Read `.claude/context/conventions.md` if it exists — follow project naming, config format, and logging conventions.

2. **Gather experiment definition**
   Ask the user (skip any they already provided):
   - **Hypothesis**: What do you expect to happen and why?
   - **Baseline**: What are you comparing against? (prior experiment, published result, etc.)
   - **Key metrics**: What numbers will determine success/failure?
   - **Variables**: What are you changing from the baseline?

3. **Generate config**
   - Detect existing config format by scanning for `*.yaml`, `*.toml`, `*.json` config files, or hydra/omegaconf usage.
   - If `--config` is provided, read it as the base and modify only the changed variables.
   - If no base config exists, generate a minimal YAML config with the experiment parameters.
   - Suggest hyperparameters informed by prior experiments in `experiments.md`.

4. **Output**
   - Print the experiment plan (hypothesis, baseline, metrics, config diff).
   - Write or update the config file.
   - Remind the user to launch with `/experiment launch --config <path>`.

---

## Subcommand: `launch`

Generate and optionally execute the training command.

1. **Detect environment**
   - Check for SLURM: `which sbatch`, look for `*.sbatch` files, check `$SLURM_JOB_ID`.
   - Check for multi-GPU: count GPUs with `nvidia-smi -L 2>/dev/null | wc -l`.
   - Check for launchers: look for `accelerate`, `torchrun`, `deepspeed` in the project.
   - Check for W&B: look for `wandb` in requirements/imports, check `$WANDB_API_KEY` or `~/.netrc`.

2. **Build launch command**
   - **Local single-GPU**: `python train.py --config <path>`
   - **Local multi-GPU**: `torchrun --nproc_per_node=N train.py --config <path>` or `accelerate launch`
   - **SLURM**: Generate or adapt `.sbatch` script with correct partitions, resources, and module loads.
   - Detect the project's training entrypoint by searching for `train.py`, `main.py`, or scripts with argparse/hydra.

3. **W&B integration** (if available)
   - Ensure `wandb.init()` is called with: project name, entity (from `$WANDB_ENTITY` or conventions), tags, config dict.
   - Suggest run name matching the experiment name.

4. **Confirm and run**
   - Print the full command.
   - Ask user to confirm before executing.
   - If user confirms, run in background and report PID / SLURM job ID.

---

## Subcommand: `track`

Check status of running experiments.

1. **Detect what's running**
   - **SLURM**: `squeue -u $USER -o "%.10i %.30j %.8T %.10M %.6D %R"` — show job status.
   - **Local processes**: `ps aux | grep -E "train|python.*config"` — find training processes.
   - **W&B**: If wandb MCP is available, query recent runs for the project. Otherwise check for wandb run directories in `wandb/` or `outputs/`.

2. **Report status**
   - Show: experiment name, status (running/completed/failed), elapsed time, current metrics if available.
   - For completed runs, show final metrics summary.
   - For failed runs, show the last error from logs.

3. **If `--name` is provided**, filter to just that experiment.

---

## Subcommand: `log`

Record experiment results to the persistent experiment log.

1. **Gather results**
   - If `--name` is provided, look for results in W&B, log files, or output directories.
   - Ask the user for any missing information:
     - Key metric values
     - Whether the hypothesis was confirmed or rejected
     - Surprises or unexpected findings
     - Suggested next steps

2. **Write to `.claude/context/experiments.md`**
   - Create the file if it doesn't exist with a header.
   - Append a new entry in this format:

   ```markdown
   ## [Experiment Name] — YYYY-MM-DD

   **Hypothesis**: ...
   **Config**: `path/to/config.yaml` (summary of key params)
   **Results**:
   - metric1: value
   - metric2: value
   **Outcome**: Confirmed / Rejected / Inconclusive
   **Notes**: ...
   **Next steps**: ...
   ```

3. **Cross-reference**
   - If the experiment relates to prior entries, add links.
   - Suggest what to try next based on the result pattern.

---

## General Guidelines

- Always check for existing conventions before generating anything.
- Prefer modifying existing configs over creating new ones from scratch.
- Keep experiment names short but descriptive (e.g., `lr-sweep-cosine`, `augment-v2`).
- Never overwrite experiment logs — always append.
- If something fails, diagnose before retrying.
