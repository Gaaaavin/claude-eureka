<div align="center">

# claude-eureka

**Claude Code skills for ML/AI researchers.**

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/Gaaaavin/claude-eureka)](https://github.com/Gaaaavin/claude-eureka/releases)
[![GitHub stars](https://img.shields.io/github/stars/Gaaaavin/claude-eureka?style=social)](https://github.com/Gaaaavin/claude-eureka/stargazers)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

Stop re-teaching Claude your project every session. Eureka auto-detects your stack, manages experiments, debugs training, and learns as you work.

```
/plugin marketplace add Gaaaavin/claude-eureka
/plugin install claude-eureka@claude-eureka
```

Then inside Claude Code: `/init-eureka`

</div>

---

## What Is This?

**Claude Code** is Anthropic's AI coding agent. **Skills** extend it with slash commands and passive triggers. `claude-eureka` is a curated skill pack built specifically for ML/AI research workflows.

Out of the box you get commands for experiments, debugging, code review, SLURM job submission, and publication-quality plots — all assuming you know PyTorch and care about research velocity, not boilerplate.

```
Before eureka:        After /init-eureka:

"Here's my project    Claude already knows:
 structure..."        ✓ PyTorch + Lightning + Hydra
"I use Hydra for      ✓ experiment layout in runs/
 config..."           ✓ SLURM cluster + GPU types
"My runs go in..."    ✓ active branches and open TODOs
"Oh, and I'm         ✓ NaN bug you fixed last week
 working on..."
```

---

## Quick Start

**1. Install (30 seconds)**

Inside Claude Code:

```
/plugin marketplace add Gaaaavin/claude-eureka
/plugin install claude-eureka@claude-eureka
```

This registers the eureka marketplace and installs the plugin. No npm, no pip — it's markdown files and one shell script.

**2. Initialize your project**

Open Claude Code in your project directory and run:

```
/init-eureka
```

This scans your repo, detects your stack (PyTorch, Lightning, Hydra, W&B, SLURM, etc.), and writes a tailored `CLAUDE.md`. Claude reads it on every prompt. Your context is set.

**3. Get to work**

```
/experiment baseline --lr 1e-4 --batch 64
/debug                     ← training loss exploded
/viz runs/                 ← generate paper-quality figures
/submit-job train.py       ← SLURM submission
```

---

## Skill Catalog

### Commands (explicit `/slash` invocations)

| Command | What it does |
|---------|-------------|
| `/init-eureka` | Scan project → generate tailored `CLAUDE.md` |
| `/refresh-context` | Re-detect stack, update auto-sections, keep your edits |
| `/experiment` | Create, launch, track, and log experiments |
| `/debug` | Root-cause debugging — investigate first, patch second |
| `/review` | Code review with YAGNI/KISS + ML anti-pattern detection |
| `/scaffold` | Boilerplate: model, dataset, trainer, config, SLURM script |
| `/viz` | Publication-quality figures from experiment outputs |
| `/notebook` | Structured Jupyter analysis notebooks |
| `/submit-job` | SLURM submission, status monitoring, log tailing |
| `/create-skill` | Author new skills or commands (guided) |
| `/contribute-skill` | Package a skill and open a PR to this repo |
| `/update-eureka` | Pull latest commands and skills from GitHub |

### Passive Skills (trigger automatically)

| Skill | Activates on |
|-------|-------------|
| `research-debugging` | Errors, exceptions, NaN, OOM, CUDA errors, tracebacks |
| `auto-memory` | "remember", conventions, experiment completions, bug resolutions |

---

## How It Works

Eureka uses a tiered context architecture so Claude gets exactly what it needs without wasting tokens:

```
CLAUDE.md  (~50 lines, loaded every prompt)
│  Project identity, stack, key paths, active work state.
│
└── .claude/context/*.md  (loaded on demand)
       Experiments, architecture decisions, resolved bugs,
       team conventions. Claude loads relevant files per query.
       |
       └── auto-memory  (agent-maintained)
              Results and learnings written back automatically.
              Your second session is smarter than your first.
```

`/init-eureka` populates tiers 1 and 2. The `auto-memory` skill fills tier 3 over time. `/refresh-context` re-runs detection to keep auto-generated sections current while preserving your manual edits.

---

## Install Options

**Plugin install** — recommended, native Claude Code integration:

```
/plugin marketplace add Gaaaavin/claude-eureka
/plugin install claude-eureka@claude-eureka
```

Update anytime with:

```
/plugin update claude-eureka@claude-eureka
```

**Alternatively (older Claude Code versions)**:

```bash
curl -fsSL https://raw.githubusercontent.com/Gaaaavin/claude-eureka/main/install.sh | bash
```

Choose user-level (`~/.claude/`, recommended) or project-level (`./.claude/`) when prompted.

**Selective** — cherry-pick only the commands you want:

```bash
git clone https://github.com/Gaaaavin/claude-eureka.git /tmp/ce
cp /tmp/ce/commands/experiment.md ~/.claude/commands/
cp /tmp/ce/commands/debug.md ~/.claude/commands/
rm -rf /tmp/ce
```

**From a local clone** — for contributors:

```bash
git clone https://github.com/Gaaaavin/claude-eureka.git
cd claude-eureka && ./install.sh
```

---

## Recommended MCP Servers

Optional, but unlock deeper capabilities:

```bash
# Weights & Biases — query experiments, runs, traces
claude mcp add wandb -- npx -y @anthropic-ai/mcp-wandb@latest

# GitHub — PRs, issues, code search
claude mcp add github -- npx -y @anthropic-ai/mcp-github@latest
```

---

## Philosophy

**Opinionated defaults, fully escapable.** Works great out of the box. Every skill is a markdown file you can edit or replace.

**Zero runtime dependencies.** No npm, no pip, no Docker. ML researchers have enough dependency hell. The entire project is `.md` files and one shell script.

**Context is precious.** Skills are concise by design. Claude is already smart — we give it your project's specific context, not a thousand-line system prompt.

**Research-first, always.** `/debug` knows about gradient explosions and CUDA OOM. `/review` catches research anti-patterns like data leakage and metric p-hacking. `/scaffold` generates PyTorch modules, not React components.

---

## Contributing

The fastest path to contributing:

1. Use `/create-skill` to author a command or skill locally
2. Test it in your own workflow for a few days
3. Use `/contribute-skill` to open a PR — it handles the packaging

See [CONTRIBUTING.md](CONTRIBUTING.md) for structure requirements, style guide, and CI checks.

---

## License

[Apache 2.0](LICENSE) — use freely, attribution appreciated.
