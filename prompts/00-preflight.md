# Preflight Check — Run This First If Unsure

> Checks your system has everything needed to install the Antifragile Claude Code. Takes 10 seconds.

## Copy this prompt into Claude Code:

```
Before I install the Antifragile Claude Code, run a quick preflight check on my system:

1. Check if `git` is installed (run `git --version`)
   - If NOT installed: tell me how to install it for my OS
   - macOS: `xcode-select --install` or `brew install git`
   - Windows: download from https://git-scm.com/download/win
   - Linux: `sudo apt install git` or `sudo yum install git`

2. Check if `~/.claude/` directory exists (run `ls ~/.claude/`)
   - If NOT: create it with `mkdir -p ~/.claude`

3. Check if Python 3 is available (run `python3 --version` or `python --version`)
   - If NOT installed: that's OK for individual module installs (they only need git)
   - Only needed for the full install prompt (10-full-install.md)
   - macOS: `brew install python3` or it may already be at /usr/bin/python3
   - Windows: download from https://python.org or `winget install Python.Python.3`
   - Linux: `sudo apt install python3`

4. Check available disk space (the full pack is ~15MB)

Report:
- ✅ or ❌ for each check
- If anything is missing, offer to install it for me
- Confirm which install methods are available (prompt-only needs git, full install needs git + python3)
```

## Why run this?

Most systems already have git installed. But if you're on a fresh machine or a corporate laptop with restricted software, this check saves you from hitting errors mid-install.

**Minimum requirements:**
- **Individual module prompts (01-09)**: Only need `git`
- **Full install prompt (10)**: Needs `git` + `python3`
- **Rollback prompt (11)**: Needs nothing (Claude handles file deletion directly)
