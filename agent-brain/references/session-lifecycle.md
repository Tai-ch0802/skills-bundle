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

### Stale STATE Archival

Before loading memory, handle any leftover STATE from a previous session:

```
IF ~/.agent-brain/STATE.md exists AND is non-empty:
  1. Read the "Updated:" timestamp from STATE.md
  2. IF timestamp is from a PREVIOUS DAY (not today):
     a. Generate a brief summary of STATE.md contents
     b. Append to sessions/YYYY-MM-DD.md (using the STATE's date) as:
        ### Archived State
        > Carried over from STATE.md (YYYY-MM-DD HH:MM)
        - {summarized content}
     c. Clear STATE.md (write empty template with current timestamp)
  3. IF timestamp is from TODAY:
     a. Keep STATE.md as-is (continuation of same work session)
  4. IF no timestamp found or file is malformed:
     a. Archive contents to today's session log, then clear
```

### Memory Loading Priority

Load files in this order to manage token budget:

1. `MEMORY.md` — Always load full (should be < 500 lines)
2. `USER.md` — Always load full (should be < 100 lines)
3. `STATE.md` — Always load full if exists and non-empty (should be < 50 lines)
4. `sessions/YYYY-MM-DD.md` (today) — Load full
5. `sessions/(yesterday).md` — Load full
6. `projects/{current-project}.md` — Load if workspace matches a known project

**Token budget target**: Memory loading should consume < 3500 tokens total. If MEMORY.md exceeds this, it needs compression (see Memory Hygiene below).

### Workspace-to-Project Mapping

Detect the current project from the workspace path:
- `/Users/Tai.Tai/Documents/personal/repo/skills-bundle` → `skills-bundle`
- Extract the last path component of the workspace root as the project name
- Check if `~/.agent-brain/projects/{name}.md` exists

## Phase 2: Session Active

During normal session operation, the agent works normally with the user, enriched by loaded memory context.

### STATE Updates

The agent should update STATE.md during the session when:
- **Starting a new task**: Record the task focus and key context variables
- **Making a significant discovery**: Note error codes, file paths, or configuration values being worked with
- **Switching context**: Update the "Current Focus" section
- **Accumulating scratch notes**: Add intermediate findings to "Scratch Pad"

**Important**: STATE updates are silent — do NOT interrupt the user's workflow to announce STATE writes. Simply overwrite STATE.md when context changes significantly.

### Passive Observation

Note any user preferences, decisions, or learnings that should be captured at session end. Do NOT interrupt the user's workflow to write memory.

## Phase 3: Session End (Local Only)

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

> **Important**: Session end saves memory locally only. Cloud sync is a separate action via `/upload-brain` or `/sync-brain`.

### Summary Generation Rules

1. **Be concise**: Each session summary should be 5-15 lines max
2. **Focus on decisions**: What was decided and why, not play-by-play of actions
3. **Note the unexpected**: Bugs found, workarounds used, surprising behaviors
4. **Track continuity**: Always include "Next Steps" for future sessions
5. **Tag the project**: Always include `[[projects/{name}]]` link
6. **Use HH:MM:SS format**: Session headers use `## Session HH:MM:SS` to prevent collision when multiple sessions start in the same minute

### Memory Classification at Save Time

Apply the ontology classification when deciding what to save where:

| Information Type | Route To | Example |
|-----------------|----------|---------|
| User said "I prefer X" | `USER.md` (IDENTITY) | "User prefers tabs over spaces" |
| Discovered API quirk | `MEMORY.md` (KNOWLEDGE) | "pCloud API requires no trailing slash" |
| Currently debugging bug #123 | `STATE.md` (STATE) | "Working on issue #123 in file.ts" |
| Fixed a specific bug today | `sessions/*.md` (EXPERIENCE) | Session summary entry |

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

### STATE.md Update at Session End

Overwrite STATE.md with current work context:
- What was the last task being worked on
- Any unfinished business or open questions
- Key file paths, branch names, or identifiers for resumption

### MEMORY.md Capacity Check

After updating MEMORY.md, check its line count:

```
IF MEMORY.md > 400 lines:
  WARN "⚠ MEMORY.md approaching limit (XXX/500 lines). Consider compression."
IF MEMORY.md > 500 lines:
  1. Remove entries older than 90 days that haven't been referenced
  2. Merge related entries into single concise statements
  3. Move project-specific details to projects/{name}.md
  4. Archive obsolete technical facts
```

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

### STATE.md Hygiene

- STATE.md should remain under 50 lines
- If STATE grows too large, the agent is putting too much in it — promote durable facts to MEMORY.md
- STATE is never synced to pCloud and never indexed in brain.db

## Conflict Resolution (pCloud Sync)

Conflicts occur when both local and remote files have changed since the last sync (detected by comparing current SHA256 with the `.sync-manifest.json` record).

### Resolution Flow

1. **Create staging area**: `~/.agent-brain/tmp/` is created
2. **Download conflicting remote files** to `tmp/`
3. **Merge by file type**:

| File Type | Strategy |
|-----------|----------|
| `sessions/*.md` | Append-only merge: extract session blocks, deduplicate by header fingerprint, combine |
| `MEMORY.md`, `USER.md`, `projects/*.md` | Section-level merge using `##` headings as keys — both sides' unique sections preserved, shared sections keep longer version |
| `STATE.md` | **Never synced** — excluded from all sync operations |
| `brain.db` | Rebuilt from scratch after merge (derived artifact) |
| Other files | Remote version wins |

4. **Clean up**: `tmp/` is removed after merge
5. **Push merged result**: Final state is pushed to pCloud, updating the SHA manifest

### Three-Way SHA Detection

The sync uses a three-way comparison:
- **manifest SHA** = last synced state (from `.sync-manifest.json`)
- **local SHA** = current local file hash
- **remote SHA** = current pCloud file hash (via `checksumfile` API)

| Manifest SHA | Local SHA | Remote SHA | Action |
|:---:|:---:|:---:|--------|
| A | A | A | Skip (no changes) |
| A | A | B | Pull remote (only remote changed) |
| A | B | A | Push local (only local changed) |
| A | B | C | **Conflict** — merge via tmp/ |
| — | B | — | Push (new local file) |
| — | — | B | Pull (new remote file) |

## Error Handling

| Scenario | Action |
|----------|--------|
| pCloud unreachable | Skip sync, log warning, retry next time |
| .env missing/invalid | Prompt user to re-run bootstrap.sh |
| brain.db corrupt | Delete and regenerate with index-memory.py |
| Merge conflict error | Fall back to remote version, log warning |
| Disk full | Warn user, skip brain.db update |
