# Insights from M2-Max
# Auto-extracted from CLAUDE.md

### Memory & Session Continuity (Insights 2026-04-11 M2-Max)
- When asked to save memory, create a handoff, or update progress documentation, ALWAYS produce structured output files (MEMORY.md, HANDOFF.md, CHANGELOG.md) with concrete details — never just acknowledge observations.
- Every structured output MUST include: current status, completed work with specific file paths and counts, remaining work, and blockers.
- Do NOT produce shallow "I've noted the progress" responses — write real files with real data.

### Deployment Verification (Insights 2026-04-11 M2-Max)
- When deploying, ALWAYS check which services (API, web, marketing, etc.) are affected by the changes and deploy ALL of them — never deploy only a subset unless explicitly instructed.
- After deployment, run health checks and verify production functionality before reporting success.
- Never report "deployment complete" until you've confirmed the live URLs return 200 and key features work.

### Package Manager & Build Tools (Insights 2026-04-11 M2-Max)
- ALWAYS use `pnpm` as the package manager (never npm or yarn) unless the project explicitly uses something else
- Before running any CLI command, verify the correct binary/prefix exists in this project (e.g., check `package.json` scripts before assuming a command exists)
- After any build-related change, run `pnpm build` to verify success before reporting completion
- Never assume a CLI flag exists — check `--help` first if unsure

### Task Execution Priority (Insights 2026-04-11 M2-Max)
- When the user asks you to EXECUTE a task (publish, deploy, commit, send), DO that task FIRST before reviewing or refactoring code.
- Do not pivot from explicit action requests to code review or feature implementation without completing the requested action.
- If you see code issues while executing, note them but finish the requested action first, then mention the issues afterward.

## Multi-Machine Sync Protocol (Insights 2026-04-11 M2-Max)
- All Insights-driven CLAUDE.md additions MUST be tagged with `(Insights YYYY-MM-DD HOSTNAME)` — e.g., `(Insights 2026-04-11 M2-Max)`.
- `/sync-push` extracts tagged Insights sections from CLAUDE.md and pushes them to `assets/insights/{hostname}.md` in the shared repo.
- `/sync-pull` reads all `assets/insights/*.md` files and appends any missing sections to local CLAUDE.md — dedup by section header.
- Section headers are merge keys: if the exact header already exists locally, skip it. Never overwrite existing content.
- This enables multiple machines to independently run `/insights`, add learnings to their CLAUDE.md, push, and pull — with the union of all learnings converging on every machine.
- Memory files (`~/.claude/projects/*/memory/`) are NOT synced — they are machine/project-specific. Only CLAUDE.md insights are shared.

## Internationalization & Encoding (Insights 2026-04-11 M2-Max)
- When generating content for non-English locales, ALWAYS use proper UTF-8 characters (umlauts ä/ö/ü, accents é/ñ, CJK characters) — never ASCII escapes like `\u00e4`.
- After batch file generation for translations, spot-check 2-3 files for encoding correctness before reporting completion.
- When doing bulk find/replace operations, check BOTH code imports AND JSX usage patterns — a common failure mode is fixing imports but missing JSX references.
- For Python batch scripts generating multilingual content, always open files with `encoding='utf-8'` explicitly.
- If a batch script produces ASCII-escaped characters instead of proper UTF-8, stop and fix the script before running it on all files — do not generate broken output then fix it in a second pass.

