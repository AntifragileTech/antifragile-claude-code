# /context-save — Context Efficiency Skill

## Trigger
User says: "save context", "context-save", "be efficient", "don't waste context", or at the start of complex tasks

## Purpose
Enforce strict context efficiency rules throughout the session.

## Rules — ACTIVE FOR ENTIRE SESSION

### File Reading
- Run `wc -l` before reading ANY file
- Files > 300 lines: NEVER read fully. Use grep → sed/head/tail
- After writing a file: NEVER re-read it
- After editing: NEVER re-read unless verifying a complex multi-step edit

### Output Discipline
- NEVER echo back code you just wrote
- NEVER repeat file contents in your response
- Confirm writes in under 20 words: "Created [file] ([N] lines)."
- For edits: "Updated [file] line [N]: [what changed]."
- Skip preamble — no "I'll help you with that" or "Let me..."

### Tool Call Efficiency
- Batch parallel reads when possible (multiple Read calls in one turn)
- Batch parallel greps when searching for related things
- Use Glob to find files, not Bash(find ...)
- Use Grep to search content, not Bash(grep ...)
- Prefer Edit over Write (don't rewrite entire files for small changes)

### Session Management
- After every 5 tool calls, mentally check: "Am I being efficient?"
- If you've read the same file twice, you're doing it wrong
- If your response is > 200 words and doesn't contain code, it's too long
- Run /compact after creating 3+ files

### Planning Discipline
- MAX 2 minutes in plan mode. If stuck, start coding immediately.
- No more than 1 round of file exploration before starting implementation
- If asked to fix a bug: grep → read section → fix. Max 3 tool calls.
- If asked for a feature: check 1-2 existing patterns → implement. Max 5 reads.

### Anti-patterns to AVOID
- Reading a 500-line file to find one function → use grep first
- Re-reading a file after every edit → trust your edit
- "Let me explore the project structure..." → check memory first
- Running git status/diff when not asked → wastes a tool call
- Explaining your plan in detail before acting → just act
