---
description: Sync agent-brain memory to/from pCloud (bidirectional with conflict resolution)
---

This workflow syncs local agent-brain memory with pCloud cloud storage. It uses SHA-based incremental sync to only transfer changed files, and resolves conflicts automatically.

For simpler one-way operations, use `/upload-brain` (push only) or `/download-brain` (pull only).

// turbo-all

1. Check if `~/.agent-brain/` directory exists. If not, run the bootstrap:
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/bootstrap.sh
   ```
2. Preview sync status to show the user what will happen:
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh status
   ```
3. Run bidirectional sync (pulls remote changes, resolves conflicts, pushes local changes):
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh sync
   ```
4. Re-index the brain after sync to keep search up to date:
   ```bash
   python3 ~/.gemini/antigravity/skills/agent-brain/scripts/index-memory.py index
   ```
5. Use notify_user to inform the user: "✅ Brain synced with pCloud!" with a summary of files pushed/pulled and any conflicts resolved.
