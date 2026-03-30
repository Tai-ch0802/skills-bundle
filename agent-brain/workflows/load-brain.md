---
description: Load cross-session memory from agent-brain into current context
---

This workflow force-triggers the agent-brain session start procedure, loading persistent memory into the current conversation context from local storage. Use `/download-brain` first if you need the latest data from pCloud.

// turbo-all

1. Check if `~/.agent-brain/` directory exists. If not, run the bootstrap:
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/bootstrap.sh
   ```
2. Check for stale STATE: if `~/.agent-brain/STATE.md` exists and its `Updated:` timestamp is from a previous day, archive its content summary to the corresponding session log, then clear STATE.md.
3. Load core memory — use view_file to read the following files (if they exist):
   - `~/.agent-brain/MEMORY.md` (full)
   - `~/.agent-brain/USER.md` (full)
   - `~/.agent-brain/STATE.md` (full, if exists and non-empty)
   - `~/.agent-brain/sessions/YYYY-MM-DD.md` (today's date, if exists)
   - `~/.agent-brain/sessions/YYYY-MM-DD.md` (yesterday's date, if exists)
4. Load project context (optional): if the current workspace maps to a project, read `~/.agent-brain/projects/{project-name}.md` (if exists).
5. Use notify_user to inform the user: "✅ Memory loaded!" with a brief summary of which files were loaded and key information from memory.
