# Memory File Format Reference

Templates and conventions for all memory files in `~/.agent-brain/`.

## Memory Ontology Quick Reference

Use this table when deciding where to store new information:

| Question | If YES → | File |
|----------|----------|------|
| Is this about the user's personal preferences/habits? | **IDENTITY** | `USER.md` |
| Will this fact still be useful in 30+ days? | **KNOWLEDGE** | `MEMORY.md` |
| Is this "what I'm working on right now"? | **STATE** | `STATE.md` |
| Worth recording but none of the above? | **EXPERIENCE** | `sessions/*.md` |

## MEMORY.md Format

```markdown
# Agent Brain — Long-Term Memory

> Last updated: YYYY-MM-DD

## Technical Knowledge
- {Durable technical facts, architecture decisions}
- {API keys location, server configs, deployment patterns}

## Projects Overview
| Project | Repo | Status | Key Tech |
|---------|------|--------|----------|
| {name} | {path/url} | Active/Archived | {stack} |

## Cross-Project Patterns
- {Patterns observed across multiple projects}

## Environment
- {Machine setup, tool versions, paths}
- {Service accounts, deployment targets}

## Important Decisions
- YYYY-MM-DD: {decision and rationale}
```

## USER.md Format

```markdown
# User Profile

## Identity
- Name: {name}
- Timezone: {tz}

## Coding Preferences
- Primary languages: {languages}
- Preferred frameworks: {frameworks}
- Code style: {conventions}

## Communication Style
- Preferred language: {language for communication}
- Level of detail: {concise/verbose}

## Workflow Habits
- {Observed workflow patterns}
- {Tool preferences}

## Pet Peeves
- {Things the user dislikes or wants to avoid}
```

## STATE.md Format

STATE.md is a **short-term scratchpad** for current work context. It is freely overwritable during a session and auto-archived when stale (from a previous day).

**Key rules**:
- STATE is **never synced** to pCloud (ephemeral, local-only)
- STATE is **not indexed** in brain.db
- Durable facts MUST be promoted to MEMORY.md, not left in STATE

```markdown
# Active State

> Updated: YYYY-MM-DD HH:MM

## Current Focus
- {Primary task or goal being worked on}

## Working Context
- {Key variables: active branch, target files, PR number, error codes}
- {Related project: [[projects/{name}]]}

## Scratch Pad
- {Temporary notes, intermediate conclusions, items to verify}
- {Quick references: URLs, command snippets, config values}
```

**Archival format** (when stale STATE is appended to session log):

```markdown
### Archived State
> Carried over from STATE.md (YYYY-MM-DD HH:MM)
- {Summarized content from the archived STATE}
```

## sessions/YYYY-MM-DD.md Format

```markdown
# Sessions — YYYY-MM-DD

## Session HH:MM:SS — {brief context}
**Project**: [[projects/{name}]]
**Workspace**: {repo path or directory}

### Summary
{1-3 sentences of what was accomplished}

### Key Decisions
- {decision with brief rationale}

### Learnings
- {new technical knowledge or insight}

### Problems Solved
- {problem → solution}

### Next Steps
- [ ] {unfinished task or follow-up}

---

## Session HH:MM:SS — {next session}
...
```

## projects/{name}.md Format

```markdown
# Project: {Name}

**Repo**: {path or URL}
**Tech Stack**: {languages, frameworks}
**Status**: Active | Archived

## Context
{Brief description of the project, its purpose, architecture}

## Key Architecture Decisions
- {decision and rationale}

## Timeline
- YYYY-MM-DD: {what happened} [[sessions/YYYY-MM-DD#session-hhmmss]]
- YYYY-MM-DD: {what happened} [[sessions/YYYY-MM-DD#session-hhmmss]]

## Current State
{What's the project's current status, active branches, pending work}

## Known Issues
- {ongoing issues or technical debt}
```

## Cross-Linking Syntax

Use `[[path]]` wiki-link style for cross-references:
- `[[projects/skills-bundle]]` — link to project file
- `[[sessions/2026-03-03]]` — link to session date
- `[[sessions/2026-03-03#session-143022]]` — link to specific session entry

These are human-readable references; the agent resolves them by reading the referenced file.
