---
name: research-debugging
description: "Debugging guidance for research code — triggers on: error, exception, failed, crash, NaN, OOM, CUDA, traceback, bug, broken"
---

## Debugging Protocol

When encountering errors in research code, follow this order strictly.

### 1. Understand before fixing

- Read the **full** error message and traceback, not just the last line.
- Identify the exact line and operation that failed.
- Do NOT guess-and-patch. Reproduce the error first if possible.

### 2. ML debugging order

Check in this sequence — most bugs are data bugs:

1. **Data**: shapes, dtypes, NaN/Inf values, loader output, augmentation correctness
2. **Model**: parameter shapes, forward pass with dummy input, gradient flow
3. **Training loop**: loss computation, optimizer step, scheduler, logging
4. **Infrastructure**: GPU memory, CUDA version, library compatibility

### 3. Check recent changes

```bash
git diff HEAD~3 --stat
git log --oneline -5
```

If it worked before, the bug is in the diff.

### 4. Quick-check lists

**NaN values:**
- Check learning rate (too high?)
- Check loss function inputs (log of zero? division by zero?)
- Check data normalization
- Insert `torch.autograd.set_detect_anomaly(True)` temporarily

**OOM (Out of Memory):**
- Reduce batch size first
- Check for tensor accumulation in loops (missing `.detach()` or `with torch.no_grad()`)
- Profile with `torch.cuda.memory_summary()`

**CUDA errors:**
- Device mismatch: print `.device` for all tensors involved
- Shape mismatch: print `.shape` at each step
- Driver issue: check `nvidia-smi` and `torch.cuda.is_available()`
