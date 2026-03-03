---
name: agent-brain
description: "Persistent memory and digital twin brain for Antigravity sessions. Use this skill on EVERY session for: (1) loading cross-session memory at session start, (2) saving session summaries and learnings at session end, (3) syncing memory to pCloud cloud storage, (4) searching historical memory and past decisions, (5) managing per-project context. Triggers on: session start, session end signals (commit, release note, 告一段落, 收工, sync memory, save brain), memory recall requests (上次做了什麼, recall, search memory)."
---

# Agent Brain

Persistent file-first memory system. Every Antigravity session contributes to a growing knowledge base stored as Markdown files locally at `~/.agent-brain/` and synced to pCloud `/agent-brain/`.

## Goal

Build a **digital twin** — an agent that accumulates all session knowledge, user preferences, project context, and decisions over time.

## Memory File Structure

```
~/.agent-brain/
├── .env                    # pCloud credentials (NEVER synced)
├── .sync-state.json        # Sync metadata
├── MEMORY.md               # Long-term persistent facts
├── USER.md                 # User preferences & patterns
├── sessions/
│   └── YYYY-MM-DD.md       # Daily session logs (append-only)
├── projects/
│   └── {project-name}.md   # Per-project accumulated context
└── brain.db                # SQLite FTS5 index
```

### File Roles

| File | Load at Start | Purpose |
|------|:---:|---------|
| `MEMORY.md` | ✅ Full | Cross-session facts, decisions, learnings |
| `USER.md` | ✅ Full | User's coding style, tool preferences |
| `sessions/today.md` | ✅ Full | Today's session summaries |
| `sessions/yesterday.md` | ✅ Full | Yesterday's context for continuity |
| `sessions/older` | ❌ On-demand | Search via grep or brain.db |
| `projects/*.md` | ❌ On-demand | Load when working on that project |
| `brain.db` | ❌ By script | SQLite FTS5 index for memory search |

## Session Start Procedure

Execute on **every** session:

1. **Check bootstrap**: If `~/.agent-brain/` does not exist, run:
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/bootstrap.sh
   ```

2. **Load core memory** — read these files into context:
   - `~/.agent-brain/MEMORY.md` (full)
   - `~/.agent-brain/USER.md` (full)
   - `~/.agent-brain/sessions/YYYY-MM-DD.md` for today (if exists)
   - `~/.agent-brain/sessions/YYYY-MM-DD.md` for yesterday (if exists)

3. **Load project context** (optional): If the current workspace clearly maps to a project, check if `~/.agent-brain/projects/{project-name}.md` exists and load it.

4. Proceed with the user's request, enriched by accumulated memory.

## Session End Procedure

### Trigger Detection

Activate memory flush when the user says or implies session ending:
- **Explicit**: `save brain`, `sync memory`, `記憶同步`, `更新記憶`
- **Implicit**: `commit`, `release note`, `告一段落`, `今天先到這`, `收工`, `結束`, `下班`, `先這樣`

### Memory Flush Steps

1. **Generate session summary** and append to `~/.agent-brain/sessions/YYYY-MM-DD.md`:
   ```markdown
   ## Session HH:MM — {context}
   **Project**: [[projects/{name}]]
   **Workspace**: {repo or directory path}

   ### Summary
   {1-3 sentence summary of what was accomplished}

   ### Key Decisions
   - {decision 1}
   - {decision 2}

   ### Learnings
   - {new knowledge gained}

   ### Next Steps
   - [ ] {unfinished task}
   ```

2. **Update `MEMORY.md`** if new persistent facts emerged:
   - Technical decisions that affect future sessions
   - Cross-project patterns discovered
   - New architecture knowledge
   - Important URLs, credentials locations, environment details
   - Do NOT duplicate session-level detail — only promote **durable facts**

3. **Update `USER.md`** if new user preferences were observed:
   - Coding style, preferred tools, language preferences
   - Communication style, workflow habits

4. **Update `projects/{name}.md`** with cross-link to today's session:
   ```markdown
   - YYYY-MM-DD: {brief description} [[sessions/YYYY-MM-DD#session-hhmm]]
   ```
   Create the file if it doesn't exist, using the format in [memory-format.md](references/memory-format.md).

5. **Run indexer**:
   ```bash
   python3 ~/.gemini/antigravity/skills/agent-brain/scripts/index-memory.py index
   ```

6. **Sync to pCloud**:
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh push
   ```

## Memory Recall Procedure

When user asks about past work, decisions, or history:

1. **Specific project** → Read `~/.agent-brain/projects/{name}.md`
2. **Specific date** → Read `~/.agent-brain/sessions/YYYY-MM-DD.md`
3. **Keyword search** → Use `grep_search` on `~/.agent-brain/`
4. **Broad semantic search** → Run:
   ```bash
   python3 ~/.gemini/antigravity/skills/agent-brain/scripts/index-memory.py search "query"
   ```

## pCloud Sync

- **API Host**: `api.pcloud.com` (US data center)
- **Remote path**: `/agent-brain/`
- **Credentials**: `~/.agent-brain/.env`
- Refer to the `pcloud` skill for API details if needed

### Sync commands

```bash
# Push local changes to pCloud
bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh push

# Pull from pCloud (new device bootstrap)
bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh pull

# Bidirectional sync (pull then push)
bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh sync
```

## Memory Hygiene Rules

1. **MEMORY.md should stay under 500 lines**. If growing too large, compress: remove outdated facts, merge related entries, archive old sections to `projects/`.
2. **Sessions are append-only**. Never edit past session entries.
3. **Projects file per active project**. Archive inactive projects by adding `[ARCHIVED]` prefix.
4. **Cross-link everything**. Sessions reference `[[projects/name]]`, projects reference `[[sessions/date]]`.
5. **No secrets in memory files**. Credentials go in `.env` only.

## Detailed References

- **Memory file format templates**: See [memory-format.md](references/memory-format.md)
- **Session lifecycle details**: See [session-lifecycle.md](references/session-lifecycle.md)
