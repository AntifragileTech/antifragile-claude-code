# Module 13: Templates

> Battle-tested configuration templates: CLAUDE.md (with timestamps, NOTES.md, swarm monitoring, CRG integration), settings.json (with skill security scanner hook), and hooks script.

## Copy this prompt into Claude Code:

```
Install configuration templates from the antifragile-claude-code pack.

Templates to install:

1. **CLAUDE.md template** — Generic project instructions with auto-discovery rules, coding standards, git workflow, session management, and deployment patterns. Install to ~/.claude/templates/CLAUDE.md.template (does not overwrite your existing CLAUDE.md).

2. **settings.json template** — Hooks configuration with session-start, post-tool-use, and stop handlers. Install to ~/.claude/templates/settings.json.template (does not overwrite your existing settings.json).

3. **claude-hooks.sh** — Universal hook handler script with OAuth token staleness check, session logging, and event routing. Install to ~/bin/claude-hooks.sh and make executable.

For each template, read the file from the repo's assets/ directory and write it to the target location. Skip any file that already exists at the target.

After installation, confirm: "Installed 3 configuration templates."
```
