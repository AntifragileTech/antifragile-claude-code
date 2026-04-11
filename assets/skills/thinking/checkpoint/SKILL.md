# Session Checkpoint

Write a structured progress summary for this session. This replaces the observer/memory agent pattern — same output, zero overhead, no auth failures.

## Steps

1. Create the session log directory if it doesn't exist: `docs/session-logs/`
2. Generate a markdown file named `session-YYYY-MM-DD-HHMMSS.md`
3. Populate it with the following structure using the TodoWrite list as the primary source of truth:

```markdown
# Session Log — [DATE]

## Working Directory
[Current project path]

## Tasks Completed
- [Each completed todo item with brief details]

## Tasks In Progress / Remaining
- [Any incomplete items]

## Files Changed
- [List every file created, modified, or deleted this session]

## Issues Found
- [Bugs discovered, build failures, gotchas encountered]

## Key Decisions
- [Any architectural or approach decisions made]

## Next Steps
- [Specific actionable items for the next session, with file paths and code references]
```

4. If no TodoWrite list exists, reconstruct from the conversation: what was asked, what was done, what's left.
5. Print the full path to the saved log file when done.
