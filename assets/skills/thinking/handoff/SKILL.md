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

### Step 3: Save to persistent memory
Use claude-mem to save the handoff summary so it's searchable across sessions.

### Step 4: Confirm
Tell the user: "Handoff saved. Next session, say 'pick up where I left off' or '/resume-work'."

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
