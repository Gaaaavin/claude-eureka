---
name: notebook
description: Generate structured Jupyter analysis notebooks for experiment comparison
argument-hint: "[--experiments exp1,exp2] [--compare]"
allowed-tools: Read, Write, Bash, Glob
---

# Analysis Notebook Generation

**Input:** $ARGUMENTS

## Step 1 — Identify Experiments

Resolve which experiments to analyze:

1. **From `--experiments`**: Parse comma-separated names or W&B run IDs
2. **From context**: Read `.claude/context/experiments.md` for recent entries
3. **From W&B**: If `wandb` is configured, list recent runs in the project
4. **From filesystem**: Glob `results/`, `outputs/`, `checkpoints/` for experiment dirs

If `--compare` is set, ensure at least two experiments are identified. Confirm selection with the user if ambiguous.

## Step 2 — Gather Metadata

For each experiment, collect:
- Config/hyperparameters (from YAML, JSON, or W&B config)
- Available metrics (loss, accuracy, custom metrics)
- Checkpoint paths
- Log file locations

## Step 3 — Generate .ipynb

Build the notebook as a JSON structure using nbformat conventions. The notebook must contain these cell groups:

### Cell 1: Setup
```python
import pandas as pd, numpy as np, matplotlib.pyplot as plt, seaborn as sns
from pathlib import Path
# W&B init (if applicable)
# Path definitions for each experiment
```

### Cell 2: Data Loading
One cell per experiment. Read CSVs, JSON logs, or pull from W&B API. Normalize column names across experiments.

### Cell 3: Summary Statistics
Compute per-experiment: mean, std, min, max for each metric. If multiple seeds, run paired t-test or Wilcoxon signed-rank test between methods.

### Cell 4: Training Curves
Plot loss and primary metric over training steps. Use consistent colors per experiment. Show mean +/- std band for multi-seed runs.

### Cell 5: Comparison Plots (if `--compare`)
- Bar chart of final metrics across experiments
- Scatter plot of metric trade-offs (e.g., speed vs accuracy)
- Per-sample delta analysis if predictions available

### Cell 6: LaTeX Table
Generate a `\begin{tabular}` string with results formatted for direct paper inclusion. Bold the best result per column. Include +/- std.

### Cell 7: Key Findings
Markdown cell template:
```markdown
## Key Findings
- **Best method**: (fill in)
- **Statistically significant**: (yes/no, p-value)
- **Takeaway**: (fill in)
- **Next steps**: (fill in)
```

## Step 4 — Write and Validate

1. Write the notebook to `notebooks/<descriptive_name>.ipynb`
2. Validate JSON structure: `python -c "import nbformat; nbformat.read('...', as_version=4)"`
3. Print the output path and suggest: `jupyter lab notebooks/<name>.ipynb`

## Notebook Conventions

- Use `nbformat` v4 cell structure: `{"cell_type": "code"|"markdown", "source": [...], "metadata": {}, "outputs": []}`
- Markdown cells for section headers — never print headers from code
- Every code cell should be independently runnable after the setup cell
- Pin random seeds (`np.random.seed(42)`) for reproducibility
