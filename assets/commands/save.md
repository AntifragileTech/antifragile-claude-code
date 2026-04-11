---
description: "Save session: commit code, save memory, write handoff, then prompt for /clear"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, TodoWrite
---

# Save: Smart Session Reset

You are performing a session save. Execute ALL steps below before telling the user to run /clear.

## Step 1: Determine Project Context
Run `pwd` to get the current working directory.
Derive the project memory path:
- Replace `/` with `-` in the path, prepend with `-Users-`
- The memory dir is: `~/.claude/projects/<derived-path>/memory/`
- Example: `/Users/username/Projects/MyApp` → `~/.claude/projects/-Users-username-Projects-MyApp/memory/`
- If the memory directory doesn't exist, create it with `mkdir -p`

This is the **project-local** path. All handoffs go here.

## Step 2: Check for Code Changes (Git-Aware)
First, check if the current directory is a git repo: `git rev-parse --is-inside-work-tree 2>/dev/null`

**If inside a git repo:**
- Run `git status --short`
- If there are uncommitted changes:
  1. Stage relevant files: `git add <specific files changed this session>` (never `git add -A`)
  2. Create a descriptive commit: `git commit -m "feat/fix/chore: <what was done this session>"`
  3. Report the commit hash to the user
- If changes exist but shouldn't be committed (WIP): run `git stash push -m "auto-clear-stash-$(date +%Y%m%d-%H%M)"`
- If clean: skip — report "working tree clean, no commit needed"

**If NOT a git repo (local files, HTML projects, cPanel sites, etc.):**
- List files modified in this session based on conversation history
- Note their paths in the handoff document so the user knows what changed
- Suggest: "These files were modified but aren't version-controlled. Consider backing up or initializing git."
- Do NOT try to run any git commands — just document what changed

## Step 3: Save Session Learnings to Memory
Review the conversation for:
- Any user preferences or corrections → save as feedback memory
- Any project decisions or context → save as project memory
- Any new external references → save as reference memory
Write memory files to the **project-local** memory directory (from Step 1).

## Step 4: Write Project-Local Handoff
Create/update `handoff.md` in the **project-local** memory directory:
```
# Session Handoff — <DATE> <TIME>
## Directory: <pwd>
## Status: ACTIVE

### What Was Accomplished
- <bullet list of completed work>

### Files Modified
- <full paths of all files changed this session>

### Key Decisions
- <decisions made and their rationale>

### Next Steps
- <specific file paths, line numbers, and what to do>

### Blockers / Open Questions
- <anything unresolved>

### Version Control
- <git: committed/stashed/clean OR non-git: files listed above>
```

## Step 5: Update Global Session Index (APPEND ONLY)
Append ONE row to `~/.claude/logs/handoff.md`. This file is a pure index — no headers, no content, just a table of recent sessions across all projects.

```bash
HANDOFF_FILE="$HOME/.claude/logs/handoff.md"
mkdir -p "$(dirname "$HANDOFF_FILE")"

# Create header ONLY if file doesn't exist or is empty
if [ ! -s "$HANDOFF_FILE" ]; then
  cat > "$HANDOFF_FILE" << 'HEADER'
# Session Index
| Date | Time | Project | Directory | Status | Summary |
|------|------|---------|-----------|--------|---------|
HEADER
fi

# Append one row — NEVER overwrite, NEVER rewrite the header
echo "| <DATE> | <TIME> | <PROJECT_NAME> | <DIRECTORY> | <done/in-progress> | <1-line summary> |" >> "$HANDOFF_FILE"
```

Rules:
- **NEVER overwrite** this file — only append rows
- **NEVER rewrite the header** — it's created once
- Keep last 30 entries max — trim oldest rows (not the header) if over 30
- This is a cross-project index. Full details live in each project's `handoff.md` and `NOTES.md`

## Step 6: Append to Project NOTES.md (NEVER overwrite)
Get timestamp: `date '+%H:%M %d-%b-%Y'`
Append a new entry to `NOTES.md` in the project root (create if doesn't exist):
```markdown
---
## Session: <TIMESTAMP>

### What was done
- <bullet list of concrete changes made this session>

### What was learned
- <gotchas, decisions, patterns discovered>

### Key files modified
- <file paths with brief description of changes>

### Handoff context
- <what the next session needs to know>
```
CRITICAL: Always APPEND — never overwrite existing content. This is the permanent project history.

## Step 6b: Append to Global NOTES.md (NEVER overwrite)
Also append a shorter entry to `~/.claude/logs/NOTES.md` — the cross-project activity log:
```markdown
---
## <TIMESTAMP> — <PROJECT_NAME> (<DIRECTORY>)
- <2-3 bullet summary of what was done>
- Key: <most important file or decision>
```
Rules:
- **NEVER overwrite** — append only, just like project NOTES.md
- Keep entries short (3-5 lines max) — this is a quick-scan log, not a full history
- Full details are in the project's own NOTES.md
- This file answers: "What did I do across all projects this week/month?"

## Step 7: Update Code Review Graph (if present)
If a code-review-graph database exists for this project, run an incremental update:
```bash
if [ -f "$(git rev-parse --show-toplevel 2>/dev/null || pwd)/.code-review-graph/graph.db" ]; then
  export PATH="$HOME/.local/bin:$PATH"
  code-review-graph update --repo "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" 2>/dev/null && echo "✅ Code review graph updated" || echo "⚠️ CRG update skipped (not installed or error)"
fi
```
Skip silently if no graph exists — this is zero-cost for projects without CRG.

## Step 8: Update Todo Status
If TodoWrite was used this session, mark completed items and note pending ones.

## Step 9: Check Background Tasks
Run `ps aux | grep -i claude | grep -v grep` to check for background agents.
If any are running, warn the user before clearing.

## Step 10: Report & Generate Continuation Prompt
Tell the user what was accomplished and what's saved.

Then **automatically** generate and print a copy-paste continuation prompt:
```
╔══════════════════════════════════════════════════════╗
║  CONTINUATION PROMPT — copy-paste into next session  ║
╠══════════════════════════════════════════════════════╣

Continue work on <PROJECT_NAME> in `<DIRECTORY>`.
Last session (<DATE>): <1-2 sentence summary>.
Remaining: <specific next steps with file paths>.
Read NOTES.md and handoff at <memory-path>/handoff.md for full context.

╚══════════════════════════════════════════════════════╝
```
Do NOT ask if the user wants this — always generate it. Then tell them: "Run /clear now — all context has been preserved."
