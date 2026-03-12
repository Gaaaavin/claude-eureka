# claude-eureka

**Claude Code skills for ML/AI researchers.**

Stop re-teaching Claude your project. Eureka auto-detects your stack, manages experiments, debugs training, and learns as you work.

---

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/Gaaaavin/claude-eureka/main/install.sh | bash
```

Then in Claude Code:

```
/init-eureka
```

That's it. The installer downloads eureka and copies skills to `~/.claude/`. Then `/init-eureka` scans your project, generates a tailored `CLAUDE.md`, and sets up context files so Claude understands your codebase from the first prompt.

---

## What It Does

### 1. Auto-detects your project

`/init-eureka` scans your repo and generates a `CLAUDE.md` with your stack (PyTorch, Lightning, Hydra, W&B, SLURM, etc.), key paths, active work state, and research context. No manual configuration.

### 2. Research-first commands

Purpose-built commands for ML/AI workflows: run experiments, debug training failures, generate publication-quality plots, scaffold boilerplate, submit SLURM jobs, and more. Every command assumes you know PyTorch and care about research velocity, not boilerplate.

### 3. Self-evolving context

The agent creates and maintains context files (`.claude/context/`) as you work. It records experiment results, conventions, architecture decisions, and resolved gotchas. Your second session is smarter than your first.

---

## Skill Catalog

### Commands

| Command | Description |
|---------|-------------|
| `/init-eureka` | Scan project and generate a tailored `CLAUDE.md` |
| `/refresh-context` | Re-run detection and update auto-generated sections |
| `/experiment` | Create, launch, track, and log experiments |
| `/debug` | Systematic root-cause debugging (investigate first, fix second) |
| `/review` | Code review with YAGNI/KISS focus and ML anti-pattern detection |
| `/scaffold` | Generate boilerplate: model, dataset, trainer, config, SLURM |
| `/viz` | Publication-quality plots from experiment data |
| `/notebook` | Structured Jupyter analysis notebooks |
| `/submit-job` | SLURM job submission, monitoring, and debugging |
| `/create-skill` | Author new skills or commands |
| `/contribute-skill` | Package a local skill and open a PR to claude-eureka |
| `/update-eureka` | Update installed commands and skills to the latest version |

### Passive Skills

These activate automatically -- no slash command needed.

| Skill | Triggers on |
|-------|-------------|
| `research-debugging` | Any error, exception, NaN, OOM, CUDA error, traceback |
| `auto-memory` | "remember", "convention", experiment completion, bug resolution |

---

## How It Works

Eureka uses a tiered context architecture to give Claude the right information without blowing up the context window:

```
CLAUDE.md (~50 lines)
  Project identity, stack, key paths, active work.
  Loaded on every prompt.

.claude/context/*.md
  Detailed context files: experiments, conventions, architecture.
  Loaded when relevant.

Auto-memory
  Agent updates context files as you work.
  Experiment results, resolved bugs, and conventions persist across sessions.
```

`/init-eureka` generates the first two tiers. The `auto-memory` skill maintains them over time. `/refresh-context` re-runs detection to keep auto-generated sections current while preserving your manual additions.

---

## Install Options

The one-liner installs everything. The installer prompts you to choose:

**User-level (`~/.claude/`)** -- available in all your projects. Good default.

**Project-level (`./.claude/`)** -- scoped to one project. Good for team repos.

```bash
# From your project directory, choose option 2 when prompted:
curl -fsSL https://raw.githubusercontent.com/Gaaaavin/claude-eureka/main/install.sh | bash
```

**Selective** -- clone the repo and copy only what you want:

```bash
git clone https://github.com/Gaaaavin/claude-eureka.git /tmp/claude-eureka
cp /tmp/claude-eureka/commands/experiment.md ~/.claude/commands/
cp /tmp/claude-eureka/commands/debug.md ~/.claude/commands/
rm -rf /tmp/claude-eureka
```

**From a local clone** -- if you want to contribute or develop:

```bash
git clone https://github.com/Gaaaavin/claude-eureka.git
cd claude-eureka && ./install.sh
```

---

## Recommended MCP Servers

These are optional but unlock additional capabilities (W&B experiment queries, GitHub PR workflows):

```bash
# Weights & Biases (experiment tracking, trace queries)
claude mcp add wandb -- npx -y @anthropic-ai/mcp-wandb@latest

# GitHub (PRs, issues, code search)
claude mcp add github -- npx -y @anthropic-ai/mcp-github@latest
```

---

## Philosophy

**Opinionated defaults, escapable.** Works great out of the box. Everything is a markdown file you can edit or replace.

**Pure markdown + bash.** No npm, no pip, no runtime dependencies. ML researchers have enough dependency hell. The entire project is `.md` files and one shell script.

**Context is precious.** Skills are concise. Claude is already smart; we just give it your project context. No thousand-line system prompts.

**Research-first.** Every command is designed for ML/AI workflows, not generic software development. `/debug` knows about gradient issues and CUDA errors. `/review` catches research anti-patterns. `/scaffold` generates PyTorch modules, not React components.

---

## Contributing

Contributions welcome. The fastest path:

1. Use `/create-skill` to author a new command or skill locally
2. Test it in your own workflow
3. Use `/contribute-skill` to package it and open a PR

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on skill structure, testing, and review criteria.

---

## License

[Apache 2.0](LICENSE)
