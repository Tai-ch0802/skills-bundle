---
description: Flush current session memory to agent-brain and sync to pCloud
---

This workflow force-triggers the agent-brain session end procedure.

// turbo-all

1. Generate a session summary and append to `~/.agent-brain/sessions/YYYY-MM-DD.md` (YYYY-MM-DD = today's date). Include: summary, key decisions, learnings, next steps.
2. Extract persistent memory: update `~/.agent-brain/MEMORY.md` with technical decisions or cross-project patterns that affect future sessions (skip if no new facts).
3. User preferences: update `~/.agent-brain/USER.md` if new user preferences were observed (skip if none).
4. Project context: if a specific project was worked on, update `~/.agent-brain/projects/{project-name}.md` with cross-links to today's session.
5. Run the brain indexer:
   ```bash
   python3 ~/.gemini/antigravity/skills/agent-brain/scripts/index-memory.py index
   ```
6. Sync data to pCloud:
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh push
   ```
7. Use notify_user to inform the user: "✅ Memory saved and synced to pCloud!"
