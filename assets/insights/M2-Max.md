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

## Response Timestamps (ALL RESPONSES — NO EXCEPTIONS) (Insights 2026-04-11 M2-Max)
- At the **start** of EVERY response, run `date '+%H:%M:%S %d-%b-%Y'` and print: `⏱ Started: HH:MM:SS DD-MMM-YYYY`
- At the **end** of EVERY response, run `date '+%H:%M:%S %d-%b-%Y'` AND `$HOME/bin/context-status.sh`, then print: `⏱ Completed: HH:MM:SS DD-MMM-YYYY (took XmYs) | ctx: ~120K/1M (12%)` — calculate the duration from the start timestamp, and append the context-status output.
- Duration format: if under 60s → `(took 45s)`, if 1-59 min → `(took 3m22s)`, if 1h+ → `(took 1h12m)`
- Context format: append ` | ctx: ` followed by the output of `$HOME/bin/context-status.sh` (e.g., `~120K/1M (12%)`)
- This applies to ALL responses — short answers, conversational replies, task responses, everything. No exceptions.
- This gives the user visibility into how long every interaction takes and how much context is consumed.

## Environment Variables (Insights 2026-05-07 M2-Max)
<!-- Created: 22:38 07-May-2026 -->
- ALWAYS verify env var names match what's actually in .env before making API calls (e.g., GODADDY_API_KEY_1 not GD_API_KEY_1, SENDGRID_API_KEY_* not Stripe keys)
- If an API call fails with auth errors, FIRST check env var naming conventions in the relevant CLAUDE.md, don't retry blindly
- For Cloudflare/SendGrid multi-account setups, confirm which numbered account (1/2/3) owns the resource before executing

### Large File Set Dispatch (>50 files) (Insights 2026-05-07 M2-Max)
<!-- Updated: 22:40 07-May-2026 -->
- For audits/analyses spanning **>50 files** (SEO sweeps, codebase reviews, content libraries), NEVER read sequentially in main context — you will hit "Prompt is too long" mid-stream
- Plan **before reading**: bucket the files into 6-8 groups by category (homepage / blog / platform / podcast / etc.) and dispatch ONE Task agent per bucket
- Each agent returns a **≤2KB summary** with a strict output schema — NOT the full file contents
- Synthesize at the end in the main session from the summaries only
- Existing skills to leverage: `dispatching-parallel-agents`, `do-in-parallel`, `parallel-bugfix`, `parallel-qa`, `seo-audit`, `seo-pipeline` — prefer invoking these over building from scratch
- Reference precedent: 172-file UserEvidence audit succeeded with 8 parallel agents → 11 output files; sequential attempts hit prompt length limits 3+ times

## Build & Indexing (Insights 2026-05-07 M2-Max)
<!-- Created: 22:38 07-May-2026 -->

### Pre-flight Check for Long-Running Indexers (Insights 2026-05-07 M2-Max)
<!-- Updated: 22:40 07-May-2026 -->
Before launching ANY long-running indexer (code-review-graph / CRG, AST scans, embeddings builds, large repo crawls), run this 30-second pre-flight:
```bash
pwd && \
  git rev-parse --show-toplevel 2>/dev/null && \
  find . -type f -not -path './node_modules/*' -not -path './.git/*' -not -path './dist/*' -not -path './build/*' | wc -l && \
  du -sh . 2>/dev/null && \
  vm_stat 2>/dev/null | head -5  # macOS memory; use `free -h` on Linux
```
Decision rules:
- If file count > 20K → propose chunked or excluded-paths strategy BEFORE starting
- If repo size > 2GB → expect OOM risk on default memory limits; chunk by subdirectory
- If cwd ≠ git root → STOP and `cd` to git root first
- Reference precedent: 25-project CRG batch had OOM kills on a 4.2GB project and an 11GB project (exit 137); the 11GB project also wrong-dir-scanned 38K node_modules files before kill
- Existing skill: `infra-healthcheck` — invoke for pre-deploy/pre-build checks rather than reinventing

## Workflows (Insights 2026-05-07 M2-Max)
<!-- Created: 22:38 07-May-2026 -->

## Verification Discipline (Insights 2026-05-07 M2-Max)
<!-- Created: 22:40 07-May-2026 -->

## Recommended Setup — Not Auto-Applied (Insights 2026-05-07 M2-Max)
<!-- Created: 22:40 07-May-2026 -->

These are infrastructure recommendations from the insights report. They are NOT installed automatically because they require user-controlled credentials or are too noisy to apply globally. Install on demand:

