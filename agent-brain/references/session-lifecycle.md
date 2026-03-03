# Session Lifecycle Reference

Detailed procedures for each phase of the agent-brain session lifecycle.

## Phase 1: Session Start

### Bootstrap Check

```
IF ~/.agent-brain/ does not exist:
  1. Run bootstrap.sh
  2. This creates directory structure + .env + pulls from pCloud if data exists
  3. If bootstrap fails (no network, no pCloud token), create local-only structure
```

### Memory Loading Priority

Load files in this order to manage token budget:

1. `MEMORY.md` — Always load full (should be < 500 lines)
2. `USER.md` — Always load full (should be < 100 lines)
3. `sessions/YYYY-MM-DD.md` (today) — Load full
4. `sessions/(yesterday).md` — Load full
5. `projects/{current-project}.md` — Load if workspace matches a known project

**Token budget target**: Memory loading should consume < 3000 tokens total. If MEMORY.md exceeds this, it needs compression (see Memory Hygiene below).

### Workspace-to-Project Mapping

Detect the current project from the workspace path:
- `/Users/Tai.Tai/Documents/personal/repo/skills-bundle` → `skills-bundle`
- Extract the last path component of the workspace root as the project name
- Check if `~/.agent-brain/projects/{name}.md` exists

## Phase 2: Session Active

During normal session operation, no special brain actions are needed. The agent works normally with the user, enriched by loaded memory context.

**Passive observation**: Note any user preferences, decisions, or learnings that should be captured at session end. Do NOT interrupt the user's workflow to write memory.

## Phase 3: Session End

### Trigger Detection

Monitor for these patterns in user messages:

**High confidence (always trigger)**:
- `save brain`, `sync memory`, `記憶同步`, `更新記憶`
- `brain sync`, `save memory`

**Medium confidence (trigger with confirmation)**:
- `commit`, `幫我 commit`
- `release note`, `生成 release note`
- `告一段落`, `今天先到這`, `先這樣`
- `收工`, `下班`, `結束`
- `部署完成`, `deploy done`

When medium-confidence triggers are detected, include memory flush as a natural part of the workflow. Do not ask "should I save brain?" — just do it seamlessly.

### Summary Generation Rules

1. **Be concise**: Each session summary should be 5-15 lines max
2. **Focus on decisions**: What was decided and why, not play-by-play of actions
3. **Note the unexpected**: Bugs found, workarounds used, surprising behaviors
4. **Track continuity**: Always include "Next Steps" for future sessions
5. **Tag the project**: Always include `[[projects/{name}]]` link

### MEMORY.md Update Rules

Only promote to MEMORY.md if the fact is:
- **Durable**: Will still be relevant in 30+ days
- **Cross-session**: Useful beyond this specific session
- **Not obvious**: The agent couldn't figure this out from code alone

Examples of what TO promote:
- "skills-bundle uses a specific directory structure with i18n/zh-TW mirroring"
- "User prefers Traditional Chinese for UI, English for code comments"
- "pCloud app credentials stored in ~/.agent-brain/.env"

Examples of what NOT to promote:
- "Fixed a typo in line 42 of config.js" (too transient)
- "JavaScript uses const for constants" (obvious knowledge)

### USER.md Update Rules

Update only when observing a **new pattern** not already recorded:
- First time seeing user prefer a specific tool
- Explicit user statement about preferences
- Repeated behavior pattern (3+ times)

## Memory Hygiene

### MEMORY.md Compression

When MEMORY.md exceeds 500 lines:

1. Remove entries older than 90 days that haven't been referenced
2. Merge related entries into single concise statements
3. Move project-specific details to `projects/{name}.md`
4. Archive obsolete technical facts (deprecated tools, completed projects)

### Project Archival

When a project hasn't been referenced in 60+ days:
1. Add `[ARCHIVED]` prefix to the project name in MEMORY.md
2. Keep the `projects/{name}.md` file (do not delete — it's searchable)

## Conflict Resolution (pCloud Sync)

When pulling from pCloud and local file differs:

1. **sessions/*.md**: Append-only, merge by appending remote content not in local
2. **MEMORY.md / USER.md**: If pCloud version is newer, save local as `.local-backup`, use pCloud version
3. **brain.db**: Always regenerate locally after pull by running index-memory.py
4. **projects/*.md**: Same strategy as MEMORY.md

## Error Handling

| Scenario | Action |
|----------|--------|
| pCloud unreachable | Skip sync, log warning, retry next session |
| .env missing/invalid | Prompt user to re-run bootstrap.sh |
| brain.db corrupt | Delete and regenerate with index-memory.py |
| MEMORY.md conflicts | Keep both versions, merge manually |
| Disk full | Warn user, skip brain.db update |
