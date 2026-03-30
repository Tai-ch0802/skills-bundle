---
description: Flush current session memory to agent-brain (local save only)
---

This workflow force-triggers the agent-brain session end procedure. It saves memory locally without syncing to pCloud — use `/upload-brain` to push to cloud or `/sync-brain` for full bidirectional sync.

// turbo-all

1. Generate a session summary and append to `~/.agent-brain/sessions/YYYY-MM-DD.md` (YYYY-MM-DD = today's date). Use `## Session HH:MM:SS` header format. Include: summary, key decisions, learnings, next steps.
2. Extract persistent memory: update `~/.agent-brain/MEMORY.md` with technical decisions or cross-project patterns that affect future sessions (skip if no new facts). Use the ontology: only **KNOWLEDGE** level facts go here.
3. User preferences: update `~/.agent-brain/USER.md` if new user preferences were observed (skip if none). This is **IDENTITY** level data.
4. Working state: overwrite `~/.agent-brain/STATE.md` with current work context — task focus, key variables, scratch notes for next session. This is **STATE** level data.
5. Project context: if a specific project was worked on, update `~/.agent-brain/projects/{project-name}.md` with cross-links to today's session.
6. Check MEMORY.md capacity:
   ```bash
   wc -l ~/.agent-brain/MEMORY.md
   ```
   If over 400 lines, warn the user. If over 500 lines, trigger compression.
7. Run the brain indexer:
   ```bash
   python3 ~/.gemini/antigravity/skills/agent-brain/scripts/index-memory.py index
   ```
8. Use notify_user to inform the user: "✅ Memory saved locally! Use `/upload-brain` to push to cloud or `/sync-brain` for full sync."
