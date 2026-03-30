---
description: Upload local agent-brain changes to pCloud (one-way push, incremental)
---

This workflow pushes local agent-brain memory changes to pCloud cloud storage. Only files that have changed since the last sync are uploaded. Use this after `/save-brain` to back up your latest memory to the cloud.

// turbo-all

1. Check if `~/.agent-brain/` directory exists. If not, run the bootstrap:
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/bootstrap.sh
   ```
2. Preview what will be uploaded:
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh status
   ```
3. Push local changes to pCloud (incremental — only changed files):
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh push
   ```
4. Use notify_user to inform the user: "✅ Brain uploaded to pCloud!" with a summary of how many files were pushed.
