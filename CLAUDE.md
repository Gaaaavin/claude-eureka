# claude-eureka — Development Guide

<!-- eureka:auto-start — DO NOT edit between auto markers; use /refresh-context to update -->

## Identity

- **Project**: claude-eureka
- **Stack**: Markdown + Bash | Zero runtime dependencies
- **Description**: Self-evolving collection of Claude Code skills for ML/AI researchers. Developed using eureka itself (dogfooding).

## Key Paths

| Path | Purpose |
|------|---------|
| `commands/*.md` | Slash commands — one file per command |
| `skills/*/SKILL.md` | Passive skills — auto-triggered by keyword |
| `framework/CLAUDE.md.template` | Template installed into user projects |
| `framework/hooks/skill-discovery.sh` | UserPromptSubmit hook bundled with install |
| `install.sh` | curl\|bash installer (also runs from local clone) |
| `.github/workflows/validate-skills.yml` | CI: frontmatter + line count validation |
| `.claude/context/` | Agent context files (not for humans) |

## Active Work

- Current focus: Post v0.1.0 — bootstrapping eureka for this repo (CLAUDE.md updated, context files initialized)
- Recent commits: add gitignore, update install script, README overhaul, initial v0.1.0 release
- Open items: 0 Python TODOs (no .py files); CLAUDE.md has uncommitted changes

## Context Files

Detailed context lives in `.claude/context/` — read on demand:

- `.claude/context/experiments.md` — experiment log (command variants tested, quality results)
- `.claude/context/conventions.md` — project conventions (frontmatter rules, naming, CI behavior)
- `.claude/context/architecture.md` — codebase architecture (install flow, hook system, marker protocol)

<!-- eureka:auto-end -->

<!-- eureka:user-start — Your additions below are preserved across /refresh-context -->

## Self-Evolving Workflow

**This repo is developed using eureka itself.** When working on claude-eureka, apply the same tools you're building:

| Task | Use |
|------|-----|
| Drafting a new command or skill | `/create-skill` |
| Shipping a new command or skill | `/contribute-skill` |
| Reviewing changed `.md` files | `/review` |
| Debugging `install.sh` or hook behavior | `/debug` |
| Iterating on command output quality | `/experiment` to track variants |
| Updating auto-sections of this file | `/refresh-context` |

**Dogfooding rule**: Before shipping a new skill, run it on a real task inside this repo. If it doesn't help you work on eureka, it needs revision.

**Self-evolution loop**:
1. Identify friction in the development workflow
2. `/create-skill` → draft a command/skill that addresses it
3. Test: `./install.sh` locally → new Claude Code session → invoke the skill
4. `/review` the skill file itself
5. `/contribute-skill` → open a PR

---

## Repository Structure

```
claude-eureka/
├── install.sh                       # curl|bash installer (downloads tarball, copies files)
├── framework/                       # Templates copied during install
│   ├── CLAUDE.md.template           # Tiered CLAUDE.md for user projects
│   ├── settings.json.template       # Hook config (skill-discovery)
│   ├── eureka-config.json.template  # Install metadata
│   └── hooks/
│       └── skill-discovery.sh       # UserPromptSubmit hook
├── commands/                        # /slash commands (each = one .md file)
│   ├── init-eureka.md               # Scan repo → generate CLAUDE.md
│   ├── refresh-context.md           # Regenerate auto-sections
│   ├── experiment.md                # Create/launch/track/log experiments
│   ├── debug.md                     # Root-cause debugging (ML-adapted)
│   ├── review.md                    # Code review (YAGNI/KISS + research)
│   ├── scaffold.md                  # Boilerplate: model, dataset, trainer, config, slurm
│   ├── viz.md                       # Publication-quality plots
│   ├── notebook.md                  # Analysis notebook generation
│   ├── submit-job.md                # SLURM job submission & monitoring
│   ├── create-skill.md              # Agent-assisted skill authoring
│   ├── contribute-skill.md          # Package skill → PR to this repo
│   └── update-eureka.md             # Pull latest from GitHub, overwrite commands/skills
├── skills/                          # Auto-triggered passive skills
│   ├── research-debugging/SKILL.md  # Triggers on errors/exceptions
│   └── auto-memory/SKILL.md         # Triggers on "remember", conventions, etc.
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/validate-skills.yml
├── README.md
├── CONTRIBUTING.md
└── LICENSE
```

## Key Architecture Decisions

- **Commands (explicit) over skills (passive)**: 11 commands, 2 skills. Research workflows are deliberate actions. Over-using passive skills pollutes context on every prompt.
- **`<!-- eureka:auto -->` markers in CLAUDE.md**: `/refresh-context` rewrites auto-generated sections without destroying user edits.
- **Context files in `.claude/context/`**: For the agent, not humans. Keeps project root clean.
- **Tiered context**: CLAUDE.md (~50 lines, always loaded) → context files (loaded on demand) → auto-memory (agent-maintained).
- **No auto-update**: Users control when to update (re-run install.sh). Deterministic environments matter for research.
- **`curl | bash` install**: Users don't clone the repo. `install.sh` downloads a tarball to a temp dir, copies files, cleans up. Also works from a local clone for contributors.

## Conventions

### Command files (`commands/*.md`)

- YAML frontmatter: `name` (required), `description` (required, <200 chars), `argument-hint`, `allowed-tools`
- Body: under 300 lines
- Assume familiarity with PyTorch, Linux, uv, standard ML tooling
- No hardcoded absolute paths
- Use `$ARGUMENTS` to reference user-provided arguments

### Skill files (`skills/*/SKILL.md`)

- YAML frontmatter: `name` (required), `description` (required, <200 chars — include trigger keywords here)
- Body: under 500 lines (ideally under 100 for passive skills)
- Description is always loaded; body only loads when triggered

### install.sh

- Must work as `curl | bash` (stdin is piped, read user input from `/dev/tty`)
- Must also work from a local clone (detects `commands/` and `framework/` next to script)
- Downloads `archive/main.tar.gz` from GitHub, extracts to temp dir, copies to target, cleans up
- Two install modes: user-level (`~/.claude/`) or project-level (`./.claude/`)

### CI (`.github/workflows/validate-skills.yml`)

Runs on PRs touching `commands/**` or `skills/**`. Checks:
1. Required frontmatter (name, description)
2. No hardcoded absolute paths
3. Description under 200 chars
4. Line count limits (commands: 300, skills: 500)

## When Editing

- Keep command bodies concise. Claude is already smart — only add what it doesn't know.
- Test changes by running `./install.sh` locally, then starting a new Claude Code session.
- The `framework/CLAUDE.md.template` uses marker comments (`<!-- eureka:auto-start -->` etc.) — preserve these exactly.
- `install.sh` uses `sed` for template substitution — placeholders use `__DOUBLE_UNDERSCORE__` format.

<!-- eureka:user-end -->
