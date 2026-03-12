---
name: debug
description:
  Systematic root-cause debugging for ML/AI research code. Four phases —
  investigate first, fix second.
allowed-tools: [Read, Grep, Glob, Bash]
argument-hint: "<error description or 'last' for most recent traceback>"
---

# Systematic Debugging

## Iron Law

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**

Do not guess. Do not pattern-match to a "common fix." Do not change code until you
can explain exactly why the bug exists and predict what your fix will do.

---

## Phase 1: Root Cause Investigation

### 1.1 Reproduce and Observe

- Get the exact error: traceback, log output, or observed-vs-expected behavior.
- If user said `last`, check the terminal scrollback or most recent log file:
  - `ls -t logs/ outputs/ wandb/latest-run/ 2>/dev/null | head -5`
  - Check `slurm-*.out` files if on a cluster.
- Reproduce with minimal input if possible. Note the exact command that triggers it.

### 1.2 Read the Actual Error

Parse the traceback bottom-up:
1. **Exception type and message** — what Python is actually complaining about.
2. **Failing line** — read that file at that line, plus 20 lines of context.
3. **Call chain** — trace back through the stack frames. Read each file/line referenced.

Do NOT skip frames. The bug is often 2-3 frames above the crash site.

### 1.3 Gather State

Identify the runtime state at the crash point:
- What are the shapes, types, and values of key variables?
- What config was used? Read the config file or Hydra overrides.
- What data was being processed? (batch index, sample ID, file path)
- Was this a training step, eval step, or data loading step?

### 1.4 Timeline

When did this start?
- `git log --oneline -20` — what changed recently?
- `git diff HEAD~3` — review recent changes near the crash site.
- Did it work before? What changed? (code, data, config, environment)

---

## Phase 2: Pattern Analysis

### 2.1 Classify the Bug

| Category | Signals |
|----------|---------|
| Logic error | Wrong output, silent failure, test fails |
| Type/shape error | TypeError, shape mismatch, dimension error |
| State error | Works once then fails, order-dependent |
| Race condition | Intermittent, works in debug mode |
| Environment | Works locally not remotely, import errors |
| Data error | Fails on specific samples, NaN propagation |
| Config error | Wrong hyperparams loaded, missing keys |

### 2.2 Check Red Flags

Before proceeding, verify you are NOT falling into these traps:

| Red Flag | What to Do Instead |
|----------|-------------------|
| "It's probably just X" | Prove it. Show evidence. |
| "Let me just try this quick fix" | Why do you think it will work? |
| "This worked in another project" | This is a different project. Verify. |
| "The error message says X so the problem is X" | Error messages lie. Read the code. |
| "It must be a library bug" | It almost never is. Check your usage. |
| "Let me add a try/except" | That hides bugs, doesn't fix them. |

### 2.3 Common Rationalizations (Reject These)

| Rationalization | Reality |
|-----------------|---------|
| "The code looks right to me" | Then you're missing something. Read it again. |
| "It works on my machine" | Different env, data, or state. Find the delta. |
| "I didn't change anything" | Something changed. `git diff`, `pip freeze`, env vars. |
| "The tests pass" | Tests don't cover this case. Write one that fails. |

---

## Phase 3: Hypothesis and Testing

### 3.1 Form a Hypothesis

State explicitly:
- "The bug is caused by [X] because [evidence]."
- "If I am right, then [testable prediction]."

### 3.2 Test the Hypothesis

- **Read code** to confirm the mechanism. Don't run code blindly.
- If needed, add a **minimal diagnostic** (print statement, assert, breakpoint) — not a fix.
- Predict the output before running. If the output surprises you, your hypothesis is wrong.

### 3.3 Iterate

If the hypothesis was wrong:
- What did you learn? Update your mental model.
- Form a new hypothesis based on the new evidence.
- Do NOT try random things. Each attempt must test a specific hypothesis.

---

## Phase 4: Implementation

### 4.1 Fix Criteria

Only proceed to fix when you can answer ALL of these:
1. What is the root cause? (one sentence)
2. Why does the current code produce the bug? (mechanism)
3. What will your fix change? (specific code change)
4. Why will your fix work? (reasoning, not "let's see")
5. What else could your fix break? (side effects)

### 4.2 Make the Fix

- Minimal change. Fix the root cause, not the symptom.
- If the fix is more than ~20 lines, reconsider — you might be papering over a deeper issue.

### 4.3 Verify

- Reproduce the original error to confirm it's gone.
- Run related tests if they exist: `pytest tests/ -x -q`
- Check for regressions in the immediate area.

### 4.4 Document

Log the root cause and fix in `.claude/context/conventions.md`:
```markdown
### YYYY-MM-DD — {short description}
**Symptom**: {what the user saw}
**Root cause**: {why it happened}
**Fix**: {what was changed}
```

---

## ML-Specific Patterns

When the bug is in ML training or inference, check these domain-specific patterns.

### NaN / Inf Loss

1. **Where does it start?** Check which step produces the first NaN.
   - Add: `torch.autograd.set_detect_anomaly(True)` (slow, but pinpoints the op).
2. **Common causes**:
   - Division by zero in loss (empty denominator, zero-length batch).
   - Log of zero or negative value (`torch.log(x)` where `x <= 0`). Fix: `torch.log(x + eps)`.
   - Exploding gradients — check `grad.norm()` per parameter.
   - Learning rate too high after warmup or scheduler step.
   - Mixed precision underflow — loss scaling issue with AMP.
3. **Diagnostic**: `torch.isnan(loss).any()` and `torch.isinf(loss).any()` before `.backward()`.

### Gradient Explosion / Vanishing

1. Check gradient norms: log `torch.nn.utils.clip_grad_norm_` return value.
2. Vanishing: gradients near zero for early layers. Check initialization, activation functions.
3. Explosion: gradient norm spikes. Check LR, batch size, loss scale.
4. If using gradient clipping, is `max_norm` set correctly for this model scale?

### CUDA OOM

1. **Actual usage**: `nvidia-smi` or `torch.cuda.memory_summary()`.
2. **Common causes**:
   - Batch size too large. Try halving it.
   - Gradient accumulation storing full graph. Check `loss.backward()` vs `(loss / accum_steps).backward()`.
   - Storing tensors on GPU unnecessarily (e.g., appending to a list in a loop without `.detach()`).
   - Model in eval mode but `torch.no_grad()` missing — still building computation graph.
   - Activation checkpointing not enabled for large models.
3. **Quick check**: Does it OOM on the first batch or after N steps? If after N steps, you have a memory leak.

### Data Loader Issues

1. **Hangs/deadlocks**: Set `num_workers=0` to isolate. If it works, the bug is in multiprocessing.
   - `persistent_workers=True` with `num_workers > 0` can cause issues on some systems.
   - File handle exhaustion: `ulimit -n`.
2. **Wrong data**: Print a batch — check shapes, dtypes, value ranges, label distribution.
3. **Slow loading**: Profile with `torch.utils.data.DataLoader` timing. Check if CPU transform is the bottleneck (move to GPU).

### Shape Mismatches

1. Read the full error: it tells you expected vs actual shapes.
2. Print shapes at each transform/layer boundary.
3. Common causes:
   - Missing `unsqueeze`/`squeeze` for batch dimension.
   - Transposed dimensions (channels-first vs channels-last).
   - Variable-length sequences without proper padding/masking.
   - Mismatch between model input size and data preprocessing.

### Reproducibility Failures

1. Check all seeds: `torch.manual_seed`, `np.random.seed`, `random.seed`, `torch.cuda.manual_seed_all`.
2. `torch.use_deterministic_algorithms(True)` — this will crash on non-deterministic ops, revealing the culprit.
3. `CUBLAS_WORKSPACE_CONFIG=:4096:8` environment variable for cuBLAS determinism.
4. DataLoader: set `worker_init_fn` with per-worker seeds, use `generator` arg.
5. Dropout and augmentation are expected sources of variance — disable to isolate.

### Checkpoint Loading

1. **Key mismatches**: `model.load_state_dict(ckpt, strict=False)` then check `missing_keys` and `unexpected_keys`.
2. **Common causes**:
   - Saved with `DataParallel`/`DDP` (keys prefixed with `module.`). Strip prefix.
   - Architecture changed between save and load. Compare key sets.
   - Optimizer state shape mismatch after changing model.
3. **Diagnostic**: `print(set(ckpt.keys()) - set(model.state_dict().keys()))` for unexpected; reverse for missing.

### Mixed Precision (AMP) Issues

1. Loss becomes NaN only with AMP: the `GradScaler` may be scaling to inf.
   - Check `scaler.get_scale()` — if it keeps decreasing, there are overflows.
2. Some ops are unsafe in fp16: softmax on large logits, layer norm, loss computation.
   - Wrap sensitive ops in `torch.cuda.amp.autocast(enabled=False)`.
3. Custom autograd functions need explicit `@custom_fwd` / `@custom_bwd` decorators for AMP.

### W&B Run Log Check

If W&B is configured and the bug might be visible in metrics:
1. Check latest run: `wandb sync --show` or check `wandb/latest-run/`.
2. Look at loss curves for discontinuities, NaN markers, or plateau patterns.
3. Check system metrics (GPU utilization, memory) for resource issues.
4. Compare config between working and broken runs.
