# /quick-fix — Minimal Context Fix Skill

## Trigger
User says: "quick-fix", "just fix", "small fix", "one-liner", "typo", "quick change"

## Purpose
Make small targeted fixes WITHOUT exploring the codebase. Minimize tool calls and context usage.

## Rules — STRICT

1. **MAX 3 tool calls total** — grep to find, read the section, edit. Done.
2. **NEVER read entire files** — use grep to find the exact line, then read only 20 lines around it
3. **NEVER explore** — no Glob, no directory listings, no "let me understand the codebase"
4. **NEVER re-read after editing** — trust the edit worked
5. **NEVER explain** what you're about to do — just do it
6. **NEVER echo back** the code you wrote
7. **One response max** — fix it and confirm in under 50 words

## Pattern
```
1. grep -n "search_term" file.ext     → find line number
2. Read file (offset=LINE-10, limit=20) → see context
3. Edit (old_string → new_string)       → make the fix
4. "Fixed [what] on line [N]."          → done
```

## Anti-patterns (NEVER do these for quick fixes)
- "Let me first understand the codebase structure..."
- "I'll read the file to understand the context..."
- "Let me check if there are any other places..."
- Running builds or tests (unless user asks)
- Reading package.json, tsconfig, or config files
