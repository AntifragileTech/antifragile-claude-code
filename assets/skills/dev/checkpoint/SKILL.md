# Session Checkpoint

Write a structured progress summary for this session. This replaces the observer/memory agent pattern — same output, zero overhead, no auth failures.

## Steps

1. Gather current state by running these commands:
   - `git log --oneline -10` — recent commits
   - `git diff --name-only HEAD` — uncommitted changed files
   - `git branch --show-current` — active branch
   - `git status --short` — working tree state
   - Check for any open `TODO.md`, `NEXT-SESSION-PROMPT.md`, or `*.todo` files in the project root

2. Create the checkpoint directory if needed: `~/.claude/memory/`
3. Generate a markdown file named `checkpoint-YYYY-MM-DD-HHMMSS.md` in `~/.claude/memory/`
4. Populate it with the following structure — use TodoWrite list as primary source, git data as supplement:

```markdown
# Checkpoint — [DATE TIME]

## Project
[Current project path] | Branch: [branch name]

## Changes Made (this session)
- [Each completed todo item with brief details]

## Files Modified
- [From git diff --name-only HEAD, grouped by app if monorepo]

## Recent Commits
- [From git log --oneline -10]

## Blockers
- [Any build failures, auth issues, unresolved errors]

## Key Decisions
- [Architectural or approach decisions made]

## Next Steps
- [Specific actionable items with file paths and line numbers where possible]

## Resume Prompt
"Continue from checkpoint [DATE]. Last work: [one-line summary]. Next: [first next step]."
```

5. If no TodoWrite list exists, reconstruct from the conversation: what was asked, what was done, what's left.
6. Print the full path to the saved checkpoint file when done.
