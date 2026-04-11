# Claude Code Global Instructions

## General Rules
When asked to observe, audit, or inspect - do NOT write code or make changes unless explicitly asked. Provide written analysis only.

## Project Architecture
This is a multi-app monorepo with apps: API, web, storefront, marketing. When fixing bugs, always check if the same issue pattern exists across all apps before submitting.
This is a multi-app monorepo. When fixing bugs, always check for the same pattern across ALL apps (web, storefront, marketing, API, WhatsApp bot). A bug in one app likely exists in others. Primary languages: TypeScript and Python. Always run `tsc --noEmit` after edits.

## Authentication & OAuth
Before starting any observer/memory agent session, verify OAuth token validity first. If token is expired, refresh it immediately before proceeding. Do not attempt repeated API calls with an expired token - fail fast and notify the user.

## Media & Screenshots
When taking screenshots or generating images, always use the project's existing screenshot/image generation framework (e.g., screenshot generator scripts) rather than raw browser captures. Never expose personal browser data, bookmarks, or chrome in screenshots.
- For screenshots, always use the existing screenshot generator framework rather than raw browser screenshots. Never capture browser chrome, bookmarks, or personal data.

## Build Verification
After modifying any frontend component, always run the full build command (e.g., `pnpm build --filter=@ghugharwal-uptime/marketing`) using the CORRECT package filter name. Verify zero TypeScript errors before considering the task complete. Common gotchas: use `@ghugharwal-uptime/marketing` not `marketing` as the filter name.
- When working in the monorepo, the three apps are: marketing, web, admin. Each has its own build command via turborepo package filters.
- Check `package.json` for the exact package name before running any turbo filter command.
- Never end a session without verifying the build passes for all affected apps.

## Monorepo Structure
This is a monorepo with three apps: marketing, web, admin. Package names follow `@ghugharwal-uptime/<app>` convention. When running builds or filters, always use the full scoped package name. All three apps should build successfully before considering any task complete.

## Health Checks & Database Queries
When querying the database, ALWAYS check actual column names first (e.g., `\d table_name` in psql) before writing queries. Common mismatches: `email_logs` uses `sent_at` not `created_at`, `incidents` uses `started_at` not `created_at`. For container health checks, use `docker exec` to run checks INSIDE the container, not localhost from the host.
- Before running any database queries on the production server, first run: `docker exec <postgres-container> psql -U <user> -d <dbname> -c '\dt'` to list tables, then for each table you need to query, run `\d tablename` to get exact column names.
- Public URL checks should use the actual domain, not localhost.
- Never assume column names — always verify schema first.

## Plan Mode Rules
- Do NOT get stuck in plan mode loops. If you need to exit plan mode, write the plan file FIRST, then exit. If plan mode is not productive after one cycle, proceed directly to implementation.
- Never spend more than 2-3 minutes in pure discovery/planning without writing code. Bias toward action.
- If you find yourself reading the same files repeatedly or cycling through planning steps, STOP and start implementing immediately.
- When asked to fix a bug or make a change, start coding within the first 2 tool calls after initial file reads. Do not over-explore.

## Code Modification Rules
When running bulk find-and-replace or scripted refactors, always verify JSX/TSX usage patterns in addition to import statements. Run TypeScript checks immediately after bulk operations before considering them complete.

## Documentation & Config Update Rule (CRITICAL)
When updating CLAUDE.md, memory files, documentation, or configuration: ALWAYS ADD or UPDATE — NEVER overwrite or delete existing content unless explicitly asked. Append new rules, merge new context into existing sections, and preserve all prior decisions and learnings.

## CLAUDE.md Auto-Suggest Rule
During any session, if you discover permanent project knowledge — architecture decisions, gotchas, environment quirks, naming conventions, deployment requirements, or anything a future session would need to know — proactively suggest appending it to the project's CLAUDE.md.
- Say: "This looks like permanent project knowledge. Should I add it to CLAUDE.md?"
- Only suggest for durable facts, not session-level progress
- Examples that belong in CLAUDE.md: port numbers, schema paths, deploy commands, framework quirks, naming conventions, API patterns, known workarounds
- Examples that do NOT belong: "fixed bug today", "3 files uncommitted", "user wants X done next"
- When adding, append to the most relevant existing section — or create a new section if none fits
- NEVER auto-write to CLAUDE.md without asking first

## Code Edit Hygiene
- After applying multi-step edits to a file, re-read the file to verify no duplicate code blocks, unclosed tags, or orphaned fragments were introduced.
- When using React createPortal or SSR guards, always verify the component renders correctly on both server and client.
- After editing TSX/JSX files, do a quick scan for unclosed tags before moving on.

## React/Next.js Patterns
- When fixing z-index/stacking context issues (e.g., mobile menus, overlays), prefer React `createPortal` to document.body rather than z-index wars.
- For Vercel OG / Satori image generation, every parent div with multiple children MUST have `display: 'flex'` explicitly set.
- Do not use Tailwind plugin classes (e.g., `scrollbar-thin`) without verifying the plugin is installed; use native CSS as fallback.
- Always use inline styles (not Tailwind classes) in OG image components.
- Test OG images by checking the build output, not just visual inspection.

## Cross-App Impact Check (BEFORE fixing)
Before fixing ANY bug in a monorepo, FIRST grep for the same pattern across ALL apps. Show every instance. Then fix them all together in one pass. Do NOT fix one app and move on — the same bug almost always exists in multiple places.

## Approach Strategy
- When fixing UI bugs, consider React createPortal early for z-index/stacking context issues instead of trying z-index hacks first.
- For networking issues in Docker, always think container-to-container networking first, not localhost.
- If your first approach doesn't work after 2 attempts, stop and try a fundamentally different approach rather than iterating on the same failing strategy.
- Prefer direct implementation over extensive planning. Write code first, refine later.

## Session Management
For multi-session projects, always save progress state to memory/documentation files at session end and generate a continuation prompt the user can paste into the next session. Include: what was completed, what remains, and any key decisions made.

## Session Handoff
After every significant milestone or session, create a structured handoff document with: current status, what was completed, what remains, environment state, and any gotchas.
- **Project-local handoff (PRIMARY)**: Save to `~/.claude/projects/<project-dir>/memory/handoff.md` — this is the source of truth for that project
- **Global handoff index**: Update `~/.claude/logs/handoff.md` as an index/pointer only — one line per project with timestamp, NOT full handoff content
- When resuming a session, read the **project-local** handoff for the current working directory, NOT the global file
- This prevents Project B's handoff from overwriting Project A's context when switching between projects

### Memory & Session Continuity (Insights 2026-04-11 M2-Max)
- When asked to save memory, create a handoff, or update progress documentation, ALWAYS produce structured output files (MEMORY.md, HANDOFF.md, CHANGELOG.md) with concrete details — never just acknowledge observations.
- Every structured output MUST include: current status, completed work with specific file paths and counts, remaining work, and blockers.
- Do NOT produce shallow "I've noted the progress" responses — write real files with real data.

## Git Commit Discipline
- Commit early and often. Do NOT let 10+ files accumulate uncommitted. After completing each logical unit of work (bug fix, feature, refactor), suggest a commit.
- If a session produces code changes across 5+ files, always remind the user to commit before ending the session.
- Uncommitted work is lost work — treat git commits as checkpoints, not just milestones.

## No Personal Data in Shared Repos (CRITICAL)
When pushing to ANY shared/public repo (especially antifragile-claude-code), NEVER include:
- **Real usernames or full paths**: `/Users/sumitghugharwal/...` → use `/Users/username/...` or `~`
- **Real email addresses**: `monitor@novauptime.com` → use `monitor@yourdomain.com`
- **Project/client names**: `LMSGUM`, `wareone` → use `MyApp`, `MyProject`
- **Personal folder names**: `Vibe Code` → use `Projects` or `Code`
- **API keys, tokens, credentials**: even examples must use `$ENV_VAR` format
- **Cache files, transcripts, scraped data**: add `.cache/` to `.gitignore`
- **Domain names**: `novauptime.com`, `ghugharwal-uptime` → use `yourdomain.com`
Before every `/sync-push`, scan for personal data patterns. If found, replace with generic equivalents before pushing.

## Git Account Preflight (CRITICAL)
Before ANY git push, verify the correct GitHub account:
- Run `git config user.name` and check remote URL with `git remote -v`
- **Perfolio projects** → must use `perfolio-web-mark` account
- **All other projects** → must use `AntifragileTech` account
- If mismatch detected: run `gh auth switch --user <correct-account>` BEFORE pushing
- NEVER push without checking — a global pre-push hook will block mismatches, but Claude should catch it first
- Git `includeIf` in `~/.gitconfig` auto-sets credentials per directory, but always verify on first push of a session

## Self-Verification Rule
Before presenting code changes to the user, always verify your own output:
- Re-read edited files to catch duplicate code blocks, syntax errors, or orphaned fragments.
- Run `tsc --noEmit` (TypeScript) or equivalent type/lint check after edits.
- For UI changes, mentally trace the component tree to catch missing imports, unclosed tags, or broken props.
- Do NOT present code that you haven't verified compiles. If you can't verify, say so explicitly.

## Multi-Bug Session Protocol
When a session involves fixing 3+ bugs or issues:
1. FIRST: Create a TodoWrite checklist of ALL issues before making any code changes.
2. Work through each issue one at a time — fix, verify, mark complete.
3. Do NOT start the next bug until the current one is verified working.
4. After all todos are done, run a final build/test pass to verify nothing regressed.

## Session Discipline
- Keep sessions focused on 1-2 related tasks for highest completion rate. Sessions with 5+ issues consistently end incomplete — scope each session to 1-2 related issues max.
- Do not spend entire sessions on discovery/exploration without producing code output.
- If asked for "comprehensive" audits, produce actionable findings with specific code changes, not just lists of observations.
- Do NOT use observer/memory agent sessions — they fail 40%+ of the time due to OAuth token issues. Use `/checkpoint` at the end of a session instead.
- When batching multiple bug fixes, complete and verify each one before moving to the next.

## UI Notification Rule (ALL PROJECTS)
- **NEVER use browser notifications** — no `window.alert()`, `window.confirm()`, `window.prompt()`, and no browser Notification API (`Notification.requestPermission()`, `new Notification()`).
- All user-facing notifications (errors, success, confirmations, deletions, warnings, yes/no prompts) MUST be **in-app UI components**: toast notifications, inline banners, modal dialogs, or status messages rendered within the application.
- This applies to every project, not just GUM. When building any feature that needs to inform the user of something, use a React component (toast, alert banner, modal), never a browser-native popup.
- For delete confirmations, use a custom modal component (not `window.confirm`).

## Email & Notifications
When sending emails via SendGrid, always use the verified sender address (monitor@novauptime.com for NovaUptime, or the project-specific verified sender). Never use generic/placeholder sender emails. Always route through the app's email service so sends appear in admin logs.
- When sending emails via SendGrid, always use the verified sender address (check project config) and route through the app's email service so sends are logged in admin.

## Deployment
When deploying changes, run a full local test/build verification BEFORE suggesting deployment to production. Never ask user to deploy until all known issues are caught locally.
- When deploying changes, always verify ALL affected apps need redeployment (API, web, marketing, storefront) - never deploy only a subset without explicitly confirming with the user.

### Deployment Verification (Insights 2026-04-11 M2-Max)
- When deploying, ALWAYS check which services (API, web, marketing, etc.) are affected by the changes and deploy ALL of them — never deploy only a subset unless explicitly instructed.
- After deployment, run health checks and verify production functionality before reporting success.
- Never report "deployment complete" until you've confirmed the live URLs return 200 and key features work.

## Deployment & Docker
For Docker deployments: always fix file ownership/permissions BEFORE container start using host-level volume operations, not after via docker exec. The app runs as 'nodeuser', not root.
- When fixing Docker permissions, apply permission fixes BEFORE container start using host-level volume operations, not after via docker exec.

## Local File Dependencies & Docker (CRITICAL)
- **NEVER use `file:../` (parent directory) references** in package.json for projects that deploy via Docker. Docker build context only includes the project directory — parent paths don't exist inside the container.
- When adding a local package dependency: copy the package INTO the project (e.g., `packages/my-package/`) and reference it as `file:packages/my-package`.
- Update the Dockerfile to `COPY packages/ ./packages/` BEFORE `pnpm install` / `npm install`.
- Verify `.dockerignore` does not exclude the `packages/` directory.
- This applies to ALL package managers (pnpm, npm, yarn) and ALL containerized deployments (Docker, Kubernetes, cloud builds).
- **Pre-deploy check**: Before any `docker build`, grep package.json for `file:../` — if found, the build WILL fail.

## Tech Stack & Conventions
This project uses TypeScript as the primary language. When editing code, always maintain TypeScript types and interfaces. Also uses Prisma for database access — always verify schema paths and container contexts before running Prisma commands in production.

### Package Manager & Build Tools (Insights 2026-04-11 M2-Max)
- ALWAYS use `pnpm` as the package manager (never npm or yarn) unless the project explicitly uses something else
- Before running any CLI command, verify the correct binary/prefix exists in this project (e.g., check `package.json` scripts before assuming a command exists)
- After any build-related change, run `pnpm build` to verify success before reporting completion
- Never assume a CLI flag exists — check `--help` first if unsure

## Content Processing
When making PDF extraction or content processing changes, never impose arbitrary character/size limits unless explicitly requested. Default to extracting ALL content. For image-based pages, always consider vision/OCR-based extraction as a fallback.

## Monorepo Context
- Prisma is used for database ORM — import types from the correct package.
- SendGrid is used for emails. Email templates are in the backend.
- Stripe is used for billing. Watch for `tax_id_collection` and `customer_update[address]` configuration requirements.
- Docker Compose is used for production deployment. Do NOT use `version:` key in docker-compose.yml (deprecated).

## Task Completion Standards
When asked to 'test', 'fix', or 'implement' something, always carry through to EXECUTION and VERIFICATION — not just discovery/planning. If running out of context, summarize exactly what's left to do with specific file paths and code snippets for the next session.

### Task Execution Priority (Insights 2026-04-11 M2-Max)
- When the user asks you to EXECUTE a task (publish, deploy, commit, send), DO that task FIRST before reviewing or refactoring code.
- Do not pivot from explicit action requests to code review or feature implementation without completing the requested action.
- If you see code issues while executing, note them but finish the requested action first, then mention the issues afterward.

## WhatsApp Bot Development
When working with WhatsApp bot logic, remember: users are already chatting on WhatsApp — never design flows that ask them for their phone number via chat. Use WhatsApp metadata (pushName, sender ID) for identification. Also note that WhatsApp LIDs and phone numbers are different identifiers and must be handled separately.

## WhatsApp Platform Context
- Users interact via WhatsApp — they are ALREADY on their phone. Never design flows that ask users for information already available from the WhatsApp API (phone number, display name/pushName).
- WhatsApp LIDs (Linked IDs) are different from phone numbers — always handle both formats when comparing user identity.
- When extracting phone numbers from WhatsApp contacts, use the API metadata, not in-chat prompts.
- When working with the production database, always confirm the correct container paths and user IDs with the user before running commands.

## Pre-Deploy Checklist
Before asking the user to deploy, always run through this checklist:
1. **Which apps have changes?** Run `git diff --name-only HEAD`, map to apps, list ALL affected apps. Never deploy a subset without confirming with the user.
2. Check CORS origins in API config match all frontend domains
3. Verify Docker volume permissions use host-level ops before container start (not docker exec)
4. Confirm SendGrid sender matches verified address in project config
5. Run `npx tsc --noEmit` on ALL changed apps and fix all TypeScript errors before suggesting deployment
6. Check all new/changed field names are consistent across frontend, backend, and database schema
7. Test all regex patterns against existing patterns to avoid collisions
8. Verify variable scoping — especially when extracting logic across functions
9. For auth flows: test the full signup AND login path end-to-end
10. Confirm Prisma schema path matches the deployment environment (local vs container)
11. **ALWAYS give full deploy commands** — every deploy command must include `cd` to the project directory and `&&` chain. Never give just `./deploy/deploy-local.sh` — always prefix with the full `cd "/path/to/project" &&`. The user should be able to copy-paste and run in any terminal window

## Session Start Rules
- Never start working from vague inputs like "hi", "login", or single-word messages — ask for a one-line task description or reference to previous session context.
- If memory/documentation files exist, read them at session start to restore context.
- Check for uncommitted changes and current git branch state before making new edits.
- **Auto-generate CLAUDE.md**: If the session-start hook reports "NEW PROJECT DETECTED" (no CLAUDE.md in current directory), immediately generate one BEFORE doing any other work. Scan package.json, requirements.txt, .env*, README, and folder structure. Include: project name, tech stack, key commands (dev/build/test/deploy), env var keys (NOT values), folder structure, and external services. This ensures every project has context from the first session.
- **Auto-create memory directory**: The session-start hook auto-creates the project memory directory at `~/.claude/projects/<project-key>/memory/`. No manual setup needed.

## cPanel / Shared Hosting Zip Deployment
- **NEVER use the macOS `zip` command** to create zips for cPanel shared hosting. It embeds UID/GID and OS metadata that causes **403 Forbidden** errors on shared servers (LiteSpeed/BaseZap).
- **ALWAYS use Python `zipfile` module** to create deployment zips with explicit permissions: `0o40755 << 16` for dirs, `0o100644 << 16` for files. Exclude `.DS_Store` and `._*` files.
- **CRITICAL: Always set `date_time=time.localtime()[:6]`** in `zipfile.ZipInfo()`. The default date is `1980-01-01` — cPanel/LiteSpeed extract may **skip overwriting existing files** if the ZIP entry date is older than the file on disk. This causes "some changes missing" bugs that look like caching issues but are actually extraction issues.
- **Alternative**: use `tar czf` with `--no-xattrs --no-mac-metadata` flags — cPanel can extract `.tar.gz`.
- **Always zip from INSIDE** the source directory (e.g., `cd src && zip ...`), never from the parent — avoids a wrapper folder in the zip.
- **Delete zip files** from the web root after extraction.
- **Debugging "changes not showing" on cPanel**: Check ZIP timestamps FIRST (`unzip -l`). If dates show `01-01-1980`, that's the problem — recreate with current timestamps. Don't waste time chasing Cloudflare/LiteSpeed/browser cache until ZIP timestamps are verified correct.

## Large File Handling Rules
- Always run `wc -l <file>` before reading ANY file.
- If a file is over 300 lines, NEVER read it fully. Use grep, head, tail, or sed to read only the relevant portion.
- Use GrepTool or `grep -n "search term" file` to locate specific content first, then read only that section with `sed -n 'START,ENDp' file`.
- When using the View tool, always use offset and limit parameters for files over 300 lines.
- Prefer targeted edits (str_replace / sed) over rewriting entire files.
- When creating files, if content would exceed 500 lines, split into multiple smaller files.
- Never cat large files. Use `head -100`, `tail -100`, or `less` instead.
- For JSON/config files over 300 lines, use `jq` to extract specific keys instead of reading the whole file.

## Error Handling
- If you get a 500 or API error, retry the same operation once automatically.
- If retrying fails, compact the context with /compact and try again.
- If still failing, suggest I start a fresh session.

## Large File Generation Rules
- NEVER create a single file over 300 lines in one response.
- For HTML pages over 300 lines: split into HTML shell + separate CSS + separate JS files.
- If any file would exceed 300 lines, split further into logical modules.
- For large pages, use a section-by-section build approach:
  1. Create folder structure first
  2. Create HTML shell with placeholder comments for each section (<!-- HEADER -->, <!-- HERO -->, etc.)
  3. Create CSS and JS as separate files
  4. Build each section as a separate partial file in a /sections folder
  5. Insert each section into the main HTML one at a time
  6. Run /compact after every 2-3 file operations
- Never hold more than 300 lines of code in a single response.
- After creating a file, do NOT re-read it unless making a targeted edit.
- Use str_replace or sed for edits — never rewrite full files.
- Never re-output or echo back a file after writing it. Just confirm it was created.
- If assembling a large page from partials, use cat/sed to append sections — don't regenerate.
- Always tell me the total progress: "Section 3/8 complete" so I know where we are.

## Agent Patterns

### Observer/Memory Agent Pattern
Do NOT spawn observer or memory agent sessions unless the OAuth token has been verified as valid within the last 5 minutes. If an observer session encounters an auth error on its first call, immediately terminate rather than retrying dozens of times.

## Sub-Agent / Parallel Task Rules
- Each sub-agent has a LIMITED context window — smaller than the main session.
- NEVER ask a sub-agent to generate more than 200 lines of code in a single task.
- For blog pages or large HTML pages via sub-agents:
  1. Have the sub-agent create ONLY the HTML structure with content — no inline CSS or JS.
  2. Use shared/existing CSS files — don't generate new styles per agent.
  3. Keep each agent's output under 250 lines total.
- If a page needs 500+ lines, do NOT use a sub-agent. Build it in the main session using the section-by-section approach.
- Before launching parallel agents, break the work so each agent's task is small and self-contained.
- After launching agents, check their output files within 2 minutes using `tail -20` on the output file.
- If an agent appears stalled (no output file update for 60+ seconds), report it to me immediately instead of waiting.

### Parallel Agent Task Sizing Guide
- Good for agents: Create a single component (<200 lines), run a test suite, lint a file, generate a config
- Bad for agents: Create a full page (500+ lines), generate long-form content with full markup, multi-file creation
- Borderline: Blog pages — only if using a pre-built template and just filling in content (under 300 lines)

## Session File Hygiene (CRITICAL)
Any file created for session continuity (e.g., `NEXT-SESSION-PROMPT.md`, `TODO.md`, `SESSION-NOTES.md`, task lists) MUST follow these rules:

### On Creation
- Always include a **created timestamp** at the top: `> Created: HH:MM DD-MMM-YYYY` (e.g., `> Created: 04:20 18-MAR-2026`). Time first, then day, month (3-letter abbreviation in caps), then year.
- Always include a **status line**: `> Status: ACTIVE` or `> Status: COMPLETED`

### On Session End
- If all tasks in a session file are done, **mark it completed** — do NOT leave it as active:
  ```
  > ⚠️ STATUS: ALL TASKS COMPLETED — YYYY-MM-DD
  > This file is archived. Do NOT use it to generate new tasks.
  ```
- Do NOT delete session files — archive them so they can be referenced later if needed.

### On Session Start
- If you find any `NEXT-SESSION-PROMPT.md`, `TODO.md`, or similar planning files in the project directory, **check the status header first**.
- If it says `COMPLETED` or `ARCHIVED` — **ignore it entirely**, do not surface those tasks.
- If it has no status header, check the file's modification date (`stat -f %Sm <file>`) — if older than 7 days, treat it as stale and confirm with the user before acting on it.
- The **single source of truth** for current state is `~/.claude/logs/handoff.md` and claude-mem memory, NOT random files in project directories.

### General Rule
- Never treat old planning files as current work without verifying with the user.
- When creating any temporary planning/task file, prefer writing to `~/.claude/logs/` (centralized) over scattering files in project directories.

## Project-Specific Notes

### ACPN Website Project
- Site has 159+ Arabic HTML clinic pages
- Always test .htaccess changes with DirectoryIndex directive
- When creating deployment zips for cPanel, never include a src/ wrapper folder - files must be at the root
- Arabic translation work should use grep/sed scripts for bulk operations across pages

## Assumption Surfacing (CRITICAL)
Before implementing anything non-trivial — especially commands involving production databases, Docker containers, file paths, or environment-specific configs — explicitly state assumptions first:
ASSUMPTIONS I'M MAKING:
1. [assumption about path/env/config]
2. [assumption about behavior/requirement]
→ Correct me now or I'll proceed with these.
- Never silently fill in ambiguous requirements. Surface uncertainty early.
- If a file path, container name, DB credential, or schema location isn't 100% confirmed, ASK — don't guess.
- This applies especially to: Prisma schema paths, Docker container names, production DB user/database, deploy script locations, and domain/URL references.

## Confusion Management
When encountering inconsistencies, conflicting patterns, or unclear specifications:
1. STOP. Do not proceed with a guess.
2. Name the specific confusion: "I see X in file A but Y in file B."
3. Present the tradeoff or ask the clarifying question.
4. Wait for resolution before continuing.
- In a monorepo with multiple apps, conflicting patterns across apps must be flagged, not silently resolved by picking one.
- If a requirement contradicts an existing CLAUDE.md rule, surface the conflict explicitly.

## Anti-Sycophancy Rule
Do not be a yes-machine. When the user's approach has clear problems:
- Point out the issue directly with the concrete downside.
- Propose an alternative.
- Accept their decision if they override — but the pushback must happen first.
- "Of course!" followed by implementing a bad idea helps no one.
- This applies especially to: designs that ignore platform context (e.g., asking WhatsApp users for info already available via API), deploying without testing, skipping type checks, or approaches that have already failed.

## Token Optimization (CRITICAL)
Token consumption is the #1 operational cost. Follow these rules to minimize waste without sacrificing quality:

### Context Hygiene
- Use `/clear` between unrelated tasks. Stale context wastes tokens on every subsequent message.
- Use `/context` periodically to see what's consuming context space — MCP tools, files, conversation history.
- Use `/rename` before clearing so sessions are findable via `/resume` later.
- Disable unused MCP servers via `/mcp` — each adds tool definitions to context even when unused.
- Prefer CLI tools (`gh`, `aws`, `docker`) over MCP equivalents when available — zero per-tool context overhead.

### Prompt Discipline
- Be specific: "fix the auth middleware in src/auth.ts line 45" not "fix the auth issue."
- Vague prompts like "improve this codebase" trigger broad file scanning that burns tokens.
- Include file paths and line numbers when you know them — reduces Claude's search cost.
- Give verification targets: test cases, expected output, or screenshots so Claude self-verifies instead of asking.

### Model Routing
- Use Sonnet for 90% of coding tasks. Reserve Opus for complex architecture or multi-step reasoning.
- Use Haiku for research subagents, documentation, and simple tasks — 3x cheaper than Sonnet.
- Switch models mid-session with `/model` — no need to restart.
- For subagents, specify `model: haiku` when the task is simple (search, lint, format).

### Context Preservation
- Use plan mode (Shift+Tab) for complex tasks — Claude explores and proposes before implementing, preventing expensive re-work.
- Course-correct early: press Escape to stop immediately if Claude heads the wrong direction. Use `/rewind` to restore.
- Test incrementally: write one file, test it, then continue. Catches issues when they're cheap to fix.
- Keep feature branches small — limits scope creep and context bloat.

### Delegate Verbose Work
- Delegate test runs, log analysis, and documentation to subagents — verbose output stays in the subagent's window, only a summary returns.
- Use hooks to preprocess data before Claude sees it. Example: filter test output to show only failures instead of full test logs.
- Use Python scripts for bulk operations (already in CLAUDE.md) — they don't consume AI context at all.

### Extended Thinking Budget
- Default thinking budget is 31,999 tokens per request — this is expensive.
- For simple tasks, lower it: `export MAX_THINKING_TOKENS=8000` or use `/effort` to reduce effort level.
- Toggle thinking with Option+T (macOS) / Alt+T (Windows/Linux).
- Only use full thinking budget for architectural decisions, complex debugging, or multi-file refactors.

# Compact Instructions

When compacting, preserve:
- All code changes and file paths modified in this session
- Test output (pass/fail status, not full logs)
- Current task state and remaining work
- Key decisions made and their rationale
- Error messages that informed debugging direction

When compacting, discard:
- File contents that were read but not modified
- Exploratory searches that led to dead ends
- Verbose command output already summarized
- Repeated tool calls with identical results

## Auto-Context Management (AUTOMATED)
Context is automatically monitored by hooks. The system will:
- At 500KB (~50% full): Suggest finishing current task and running /save
- At 1MB (~75% full): Urgently recommend /save
- At 1.5MB (~90% full): Warn that auto-compact is imminent
- Every 15 messages: Remind to /save if task has switched
- On Stop: Auto-check for uncommitted files and context bloat

When Claude detects a natural task boundary (bug fixed, feature complete, question answered):
1. Proactively suggest: "Task complete. Run /save to save context and reset."
2. Do NOT wait for the user to remember — suggest it immediately after task completion.
3. /save handles: git commit, memory save, handoff doc, then prompts for /clear.

### Effort Auto-Routing
- Simple tasks (typos, single-file edits, questions): use /effort low
- Standard tasks (bug fixes, features, reviews): use /effort medium  
- Complex tasks (architecture, multi-file refactors, debugging): use /effort high
- Claude should suggest the appropriate effort level at task start, not wait to be asked.

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
