---
name: auto-memory
description: "Auto-save context when the agent learns something — triggers on: remember, convention, always do, note for future, learned that, from now on, never do, experiment completion, bug resolution"
---

## When to save

Activate when any of these occur:

- User says to remember something, establishes a convention, or sets a preference
- An experiment completes and results are logged
- A bug is resolved and root cause is identified
- A significant architectural discovery is made about the codebase

## Where to save

Route entries to the appropriate context file:

| Content type | File |
|---|---|
| Conventions, preferences, workflows | `.claude/context/conventions.md` |
| Experiment results, metrics, findings | `.claude/context/experiments.md` |
| Architecture discoveries, code patterns | `.claude/context/architecture.md` |

Create the file if it does not exist. Use a `# Context` heading at the top.

## Entry format

Each entry is a dated, concise line:

```
- **YYYY-MM-DD**: <short description of what was learned or decided>
```

Append new entries under the appropriate section heading. Keep descriptions to one or two sentences.

## Deduplication

Before adding an entry:

1. Read the target context file
2. Search for keywords from the new entry
3. If a substantially similar entry exists, update it in place instead of adding a duplicate
4. If updating, preserve the original date and append the new date: `(updated YYYY-MM-DD)`

## Guidelines

- Be concise — context files are loaded into every conversation
- Only save things with lasting value, not one-off facts
- Never store secrets, tokens, or credentials
- Prefer actionable entries ("use X instead of Y") over observations
