---
description: "Autonomously fix all TypeScript errors across monorepo apps in parallel. No questions asked."
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, TodoWrite, Task
---

Fix all TypeScript errors across this monorepo autonomously.

For each app (api, web, storefront, marketing), use the Task tool to spawn parallel agents. Each agent should:

1. Run `npx tsc --noEmit 2>&1` and capture ALL errors
2. Parse each error: file path, line number, error code, message
3. Read the relevant file(s)
4. Fix each error — use best judgment, do NOT ask questions
5. Re-run `npx tsc --noEmit` to verify the fix
6. Repeat until zero errors or until the same error appears twice (likely a deeper issue — flag it)

Rules for agents:
- Fix the minimal code needed — don't refactor surrounding code
- If an error requires a type import, add it
- If an error is a missing property on a type, extend the type or add the property
- If an error recurs after 2 fix attempts, skip it and flag it in the summary
- Never introduce `any` as a fix unless the existing type is already `any`

When all agents complete, produce a summary table:

| App | Errors Found | Errors Fixed | Remaining | Notes |
|-----|-------------|-------------|-----------|-------|

List any remaining errors with their file:line references so they can be fixed manually.
