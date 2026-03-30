---
description: Download agent-brain memory from pCloud to local (one-way pull, incremental)
---

This workflow pulls the latest agent-brain memory from pCloud cloud storage to local. Only files that have changed on the remote are downloaded. Use this when switching machines or to get the latest cloud state.

// turbo-all

1. Check if `~/.agent-brain/` directory exists. If not, run the bootstrap:
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/bootstrap.sh
   ```
2. Preview what will be downloaded:
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh status
   ```
3. Pull changes from pCloud (incremental — only changed files):
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh pull
   ```
4. Re-index the brain after pulling to keep search up to date:
   ```bash
   python3 ~/.gemini/antigravity/skills/agent-brain/scripts/index-memory.py index
   ```
5. Use notify_user to inform the user: "✅ Brain downloaded from pCloud!" with a summary of how many files were pulled.
