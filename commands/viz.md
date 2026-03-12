---
name: viz
description: Generate publication-quality plots from experiment data
argument-hint: "[curves|compare|qualitative] [--source wandb|csv|json]"
allowed-tools: Read, Write, Bash, Glob
---

# Publication-Quality Visualization

**Input:** $ARGUMENTS

## Step 1 — Determine What to Visualize

Ask the user if not clear from arguments:

- **curves**: Training/validation curves over time (loss, accuracy, etc.)
- **compare**: Side-by-side metric comparison across runs or methods
- **qualitative**: Sample predictions, attention maps, retrieval results
- **ablation**: Ablation study tables or grouped bar charts

## Step 2 — Detect Data Source

Check in this order:

1. **Explicit `--source`** in arguments
2. **W&B**: Look for `.claude/context/experiments.md` or `wandb/` dir — use `wandb.Api()` to pull runs
3. **CSV**: Glob for `*.csv` in `results/`, `outputs/`, `logs/`, experiment dirs
4. **JSON**: Glob for `*.json` metric logs, training logs
5. **Context files**: Parse `.claude/context/experiments.md` for logged metrics

If multiple sources exist, ask which to use.

## Step 3 — Generate Plotting Script

Create a self-contained Python script. Apply these paper-quality defaults:

```python
# Required style preamble for every generated script
import matplotlib
matplotlib.rcParams.update({
    "font.size": 10,
    "axes.labelsize": 12,
    "axes.titlesize": 12,
    "xtick.labelsize": 10,
    "ytick.labelsize": 10,
    "legend.fontsize": 9,
    "figure.figsize": (6, 4),
    "figure.dpi": 150,
    "savefig.dpi": 300,
    "savefig.bbox_inches": "tight",
    "savefig.pad_inches": 0.05,
    "text.usetex": False,  # set True if LaTeX available
    "font.family": "serif",
    "axes.grid": True,
    "grid.alpha": 0.3,
})
# Colorblind-safe palette (Tol bright)
COLORS = ["#4477AA", "#EE6677", "#228833", "#CCBB44", "#66CCEE", "#AA3377"]
```

### Plot-type specifics

- **curves**: x = step/epoch, y = metric. Show mean +/- std if multiple seeds. Use `fill_between` for confidence bands.
- **compare**: Grouped bar chart or scatter. Add significance markers if p-values available.
- **qualitative**: Grid layout via `plt.subplots`. Consistent sizing, shared colorbars.
- **ablation**: `pandas` DataFrame rendered as LaTeX table, or grouped horizontal bars.

## Step 4 — Save Outputs

1. Write the script to `plots/<descriptive_name>.py`
2. Run it to produce the figure
3. Save as both PDF (vector) and PNG (preview):
   - `plots/<name>.pdf` — for paper inclusion
   - `plots/<name>.png` — for quick preview
4. Print the output paths

## Conventions

- Never use default matplotlib colors — always use the colorblind-safe palette
- Axis labels must have units where applicable (e.g., "Loss (CE)", "Time (s)")
- Legend outside the plot area if more than 4 entries
- No titles on figures intended for papers (caption goes in LaTeX)
- Grid lines: light gray, behind data
