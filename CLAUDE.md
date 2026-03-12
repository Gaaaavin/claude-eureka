# claude-eureka — Development Guide

A curated, self-evolving collection of Claude Code skills for ML/AI researchers.

**Repo**: `Gaaaavin/claude-eureka` (public, Apache 2.0)
**Stack**: Pure markdown + bash. Zero runtime dependencies.

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
