# /handoff — Session Continuity System

## Trigger
User says: "handoff", "save progress", "I'm ending this session", "continue later", "pass to next session"

## Purpose
Save session state so the next session can pick up EXACTLY where you left off — zero cold start.

## On Handoff (save state)

### Step 1: Capture current state
```bash
# What branch, what changed
git branch --show-current 2>/dev/null
git status --short 2>/dev/null
git diff --stat 2>/dev/null | tail -20
git log --oneline -5 2>/dev/null
```

### Step 2: Write handoff file
Write to `~/.claude/logs/handoff.md`:

```markdown
# Session Handoff — [DATE TIME]
## Branch: [current branch]
## Project: [project name from package.json]
## Working Directory: [pwd]

## What I was doing
[1-2 sentence summary of the task]

## Files touched this session
[list of files modified/created]

## Current status
- [ ] [what's done]
- [ ] [what's in progress]
- [ ] [what's remaining]

## Key decisions made
[any architectural or approach decisions]

## Blockers / Issues
[anything that was failing or needs attention]

## Next steps (for next session)
1. [first thing to do]
2. [second thing]
3. [third thing]

## Important context
[anything the next session needs to know that isn't obvious from the code]
```

### Step 3: Append to NOTES.md (NEVER overwrite)
Get timestamp: `date '+%H:%M %d-%b-%Y'`
Append a new entry to `NOTES.md` in the project root (create if doesn't exist):
```markdown
---
## Session: <TIMESTAMP>

### What was done
- <bullet list of concrete changes made>

### What was learned
- <gotchas, decisions, patterns discovered>

### Key files modified
- <file paths with brief description>

### Handoff context
- <what next session needs to know>
```
CRITICAL: Always APPEND. Never overwrite. This is the permanent project history.

### Step 4: Save to persistent memory
Use claude-mem to save the handoff summary so it's searchable across sessions.

### Step 5: Generate Continuation Prompt (AUTOMATIC)
Print a copy-paste-ready continuation prompt:
```
╔══════════════════════════════════════════════════════╗
║  CONTINUATION PROMPT — copy-paste into next session  ║
╠══════════════════════════════════════════════════════╣

Continue work on <PROJECT_NAME> in `<DIRECTORY>`.
Last session (<DATE>): <1-2 sentence summary>.
Remaining: <specific next steps with file paths>.
Read NOTES.md and handoff at ~/.claude/logs/handoff.md for full context.

╚══════════════════════════════════════════════════════╝
```
Do NOT ask — always generate this automatically.

### Step 6: Confirm
Tell the user: "Handoff saved. NOTES.md updated. Continuation prompt above — copy it for next session."

## On Resume (load state) — triggered by /resume-work or "continue", "pick up"

### Step 1: Load handoff file
```bash
cat ~/.claude/logs/handoff.md
```

### Step 2: Check current state
```bash
git branch --show-current
git status --short
```

### Step 3: Inject context
Read the handoff file and summarize:
- "Last session you were working on [X] on branch [Y]"
- "You had [N] files modified, [M] tasks remaining"
- "Next step was: [first item from next steps]"
- "Shall I continue from there?"

## Rules
- ALWAYS write the handoff file before session ends
- ALWAYS include Next Steps — this is the most valuable part
- Keep handoff under 50 lines — enough to restore context, not reproduce it
- Save to BOTH file and claude-mem for redundancy
