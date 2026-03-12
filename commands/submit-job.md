---
name: submit-job
description: SLURM job submission, monitoring, and debugging
argument-hint: "[submit|status|debug|cancel] [--config path] [--gpu N] [--time HH:MM:SS]"
allowed-tools: Read, Write, Bash, Glob, Grep
---

# SLURM Job Management

**Input:** $ARGUMENTS

Parse the subcommand from arguments. Default to `status` if none given.

---

## Subcommand: `submit`

### 1. Gather Parameters

Merge from these sources (later overrides earlier):

| Source | Example |
|--------|---------|
| Cluster defaults | Detect via `sinfo`, existing `.sbatch` files, `module avail` |
| Config file (`--config`) | YAML/JSON with train params |
| CLI overrides | `--gpu 4 --time 24:00:00` |
| User prompt | Ask for anything missing |

Required parameters: job name, partition, GPU count, time limit, command to run.

### 2. Detect Cluster Conventions

```bash
# Auto-detect what's available
sinfo -s 2>/dev/null          # partitions and node counts
module avail 2>&1 | head -20  # available modules
which conda mamba 2>/dev/null  # conda or mamba
```

Look for existing `.sbatch` files in the project to match local conventions (partition names, module loads, conda env name).

### 3. Generate .sbatch Script

Write to `slurm/<job_name>.sbatch`. Template:

```bash
#!/bin/bash
#SBATCH --job-name=<name>
#SBATCH --partition=<partition>
#SBATCH --nodes=<N>
#SBATCH --ntasks-per-node=<T>
#SBATCH --gres=gpu:<G>
#SBATCH --cpus-per-task=<C>
#SBATCH --mem=<M>
#SBATCH --time=<HH:MM:SS>
#SBATCH --output=slurm/logs/%x_%j.out
#SBATCH --error=slurm/logs/%x_%j.err

# --- Environment ---
module purge
module load <detected_modules>
conda activate <detected_env>

# --- Multi-node setup (if nodes > 1) ---
export MASTER_ADDR=$(scontrol show hostname $SLURM_NODELIST | head -n1)
export MASTER_PORT=29500

# --- Run ---
srun torchrun --nproc_per_node=$SLURM_GPUS_ON_NODE \
    --nnodes=$SLURM_NNODES \
    --node_rank=$SLURM_NODEID \
    --master_addr=$MASTER_ADDR \
    --master_port=$MASTER_PORT \
    <command>
```

Adjust for single-node (drop srun/torchrun multi-node flags) or single-GPU (plain `python`).

### 4. Submit

```bash
mkdir -p slurm/logs
sbatch slurm/<job_name>.sbatch
```

Print the job ID and expected log paths.

---

## Subcommand: `status`

```bash
squeue -u $USER -o "%.10i %.20j %.8T %.10M %.6D %.4C %.10P %R" --sort=-t
```

Display a formatted table with: Job ID, Name, State, Elapsed Time, Nodes, CPUs, Partition, Reason/Nodelist.

If a specific job ID is in the arguments, also show:
```bash
scontrol show job <JOBID>
sacct -j <JOBID> --format=JobID,Elapsed,MaxRSS,MaxVMSize,State,ExitCode
```

---

## Subcommand: `debug`

### 1. Find Log Files

```bash
ls -t slurm/logs/*.{out,err} 2>/dev/null | head -10
```

If a job ID is given, look for `*_<JOBID>.out` and `*_<JOBID>.err` specifically.

### 2. Diagnose

Read the last 100 lines of `.err` and `.out`. Check for these patterns:

| Pattern | Diagnosis | Fix |
|---------|-----------|-----|
| `Killed` or `oom-kill` | OOM — not enough RAM | Reduce batch size, request more `--mem`, or fewer workers |
| `CANCELLED AT.*DUE TO TIME LIMIT` | Walltime exceeded | Increase `--time` or add checkpointing |
| `ModuleNotFoundError` or `module not found` | Missing module load or pip package | Add `module load` or `pip install` to sbatch |
| `CUDA error: out of memory` | GPU OOM | Reduce batch size, use gradient accumulation, or mixed precision |
| `NCCL.*timeout` or `NCCL.*error` | Multi-node communication failure | Check MASTER_ADDR, network config, NCCL env vars |
| `FileNotFoundError` | Wrong path | Verify paths are absolute or correct relative to SLURM workdir |
| `CalledProcessError.*srun` | srun launch failure | Check ntasks-per-node matches GPU count |

### 3. Report

Print: root cause, relevant log lines, and suggested fix. Offer to regenerate the `.sbatch` with the fix applied.

---

## Subcommand: `cancel`

If a job ID is given, run `scancel <JOBID>`. If `--all` or no ID, list jobs with `squeue -u $USER -o "%i %j %T" --noheader`, confirm with user, then `scancel -u $USER`.

Always confirm before cancelling. Print which jobs were cancelled.
