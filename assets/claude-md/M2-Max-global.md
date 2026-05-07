# Claude Code Global Rules

## Skill Auto-Discovery (CRITICAL)
You have 567+ installed skills (including gstack), 93+ commands, and 68+ agents. Before starting ANY task, scan the available skills list for relevant matches. DO NOT ask the user to invoke skills manually — proactively use them.

### Skill Matching Rules
1. **Before writing code**: Check if a language/framework-specific skill exists (e.g., `nextjs-developer`, `fastapi-expert`, `react-expert`, `terraform-engineer`, `kubernetes-specialist`).
2. **Before debugging**: Use `systematic-debugging` or `debug-like-expert` skill.
3. **Before security work**: Use Trail of Bits skills (`semgrep`, `codeql`, `supply-chain-risk-auditor`, `insecure-defaults`, etc.).
4. **Before DevOps/Infra**: Use DevOps skills (`terraform-generator`, `dockerfile-generator`, `k8s-yaml-generator`, `helm-generator`, `github-actions-generator`, etc.).
5. **Before UI/UX work**: Use `ui-ux-pro-max`, `frontend-design`, `design-system`, `ui-styling` skills.
6. **Before planning**: Use `writing-plans`, `brainstorming`, or `plan` skill.
7. **Before code review**: Use `code-review`, `security-review`, or language-specific reviewer skills.
8. **Before testing**: Use `test-driven-development`, `tdd-workflow`, `e2e-testing`, or language-specific testing skills.
9. **Before marketing/content**: Match to CRO, SEO, copywriting, email skills as appropriate.
10. **Before deploying**: Use `pre-deploy`, `verification-loop`, `deployment-patterns`.

### How to Use Skills
- Invoke skills via the Skill tool with the skill name (e.g., `skill: "systematic-debugging"`).
- If multiple skills are relevant, invoke the most specific one first.
- You can chain skills: plan → implement → test → review → deploy.
- When unsure which skill applies, briefly mention 2-3 relevant skills to the user and proceed with the best match.

### Skill Categories Quick Reference
- **Languages**: nextjs, react, vue, angular, python, django, fastapi, rails, rust, go, swift, kotlin, java, springboot, laravel, php, cpp, csharp, flutter, typescript
- **DevOps**: terraform, k8s, helm, ansible, docker, jenkins, gitlab-ci, github-actions, azure-pipelines
- **Security**: semgrep, codeql, supply-chain, vulnerability scanners (solana, cairo, algorand, cosmos, substrate), fuzzing (aflpp, libfuzzer, cargo-fuzz)
- **Quality**: code-review, test-driven-development, verification-loop, e2e-testing, property-based-testing
- **Design**: ui-ux-pro-max, frontend-design, design-system, banner-design, brand, liquid-glass-design
- **Thinking**: tree-of-thoughts, root-cause-tracing, kaizen, critique, brainstorming, debate
- **Marketing**: copywriting, seo-audit, page-cro, signup-flow-cro, cold-email, content-strategy, ad-creative

## Environment Variables (Insights 2026-05-07 M2-Max)
<!-- Created: 22:38 07-May-2026 -->
- ALWAYS verify env var names match what's actually in .env before making API calls (e.g., GODADDY_API_KEY_1 not GD_API_KEY_1, SENDGRID_API_KEY_* not Stripe keys)
- If an API call fails with auth errors, FIRST check env var naming conventions in the relevant CLAUDE.md, don't retry blindly
- For Cloudflare/SendGrid multi-account setups, confirm which numbered account (1/2/3) owns the resource before executing

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

### Large File Set Dispatch (>50 files) (Insights 2026-05-07 M2-Max)
<!-- Updated: 22:40 07-May-2026 -->
- For audits/analyses spanning **>50 files** (SEO sweeps, codebase reviews, content libraries), NEVER read sequentially in main context — you will hit "Prompt is too long" mid-stream
- Plan **before reading**: bucket the files into 6-8 groups by category (homepage / blog / platform / podcast / etc.) and dispatch ONE Task agent per bucket
- Each agent returns a **≤2KB summary** with a strict output schema — NOT the full file contents
- Synthesize at the end in the main session from the summaries only
- Existing skills to leverage: `dispatching-parallel-agents`, `do-in-parallel`, `parallel-bugfix`, `parallel-qa`, `seo-audit`, `seo-pipeline` — prefer invoking these over building from scratch
- Reference precedent: 172-file UserEvidence audit succeeded with 8 parallel agents → 11 output files; sequential attempts hit prompt length limits 3+ times

## Bulk/Batch Operations — Use Python Scripts, Not AI
- For ANY task that involves modifying, generating, or processing more than 5 files with a repeatable pattern, **write a Python script** in `/tmp/` and execute it — do NOT make edits file-by-file with AI.
- This applies to: bulk HTML page generation, cross-page find-and-replace, image processing/cropping, data scraping, sitemap updates, adding nav links across many pages, etc.
- Python scripts are faster, more reliable, produce consistent results, and don't consume AI context window.
- Pattern: Write a focused Python script → test on 1-2 files → run on all files → report results.
- Always print progress and a summary (e.g., "Fixed 159/159 pages, 0 errors").
- Save scripts in `/tmp/` with descriptive names (e.g., `/tmp/acpn_fix_buttons.py`).
- For image processing: use OpenCV for detection + Pillow (PIL) for high-quality crops/resizes.
- For HTML manipulation: use regex or string matching — no need for heavy parsers on static HTML.

## File Lifecycle Timestamps (CRITICAL — ALL FILES)
Every file created or updated by Claude MUST have lifecycle timestamps. This creates an append-only audit trail per file. Human-readable format: `HH:MM DD-MMM-YYYY` (e.g., `05:14 14-Apr-2026`).

### Comment Format by File Type
- **JS/TS/TSX/JSX/Java/C/C++/Go/Rust/Swift/Kotlin**: `// Created: HH:MM DD-MMM-YYYY` / `// Updated: HH:MM DD-MMM-YYYY`
- **Python/Ruby/Shell/YAML/TOML**: `# Created: HH:MM DD-MMM-YYYY` / `# Updated: HH:MM DD-MMM-YYYY`
- **HTML/XML/SVG**: `<!-- Created: HH:MM DD-MMM-YYYY -->` / `<!-- Updated: HH:MM DD-MMM-YYYY -->`
- **CSS/SCSS/LESS**: `/* Created: HH:MM DD-MMM-YYYY */` / `/* Updated: HH:MM DD-MMM-YYYY */`
- **Markdown**: `<!-- Created: HH:MM DD-MMM-YYYY -->` / `<!-- Updated: HH:MM DD-MMM-YYYY -->`
- **SQL**: `-- Created: HH:MM DD-MMM-YYYY` / `-- Updated: HH:MM DD-MMM-YYYY`
- **JSON** (config files only): `"_created": "HH:MM DD-MMM-YYYY"` / `"_updated": ["HH:MM DD-MMM-YYYY", ...]` (array, append-only)
- **Plain text / .txt / .env / .cfg / Dockerfile**: `# Created: HH:MM DD-MMM-YYYY` / `# Updated: HH:MM DD-MMM-YYYY`
- **Images (png/jpg/svg/gif/webp)**: Embed timestamp in filename: `name_HHMMSS-DDMMMYYYY.ext` (e.g., `hero_051420-14Apr2026.png`)

### On File CREATE (Write tool)
- Add `Created: HH:MM DD-MMM-YYYY` as the FIRST line (or after shebang/frontmatter), using the file type's comment syntax.
- For files with YAML frontmatter (`---` blocks like MDX/Markdown): place the timestamp as an HTML comment AFTER the closing `---`, before the content body. Never inside the frontmatter block.
- For images: use timestamped filename pattern.
- Get the exact time by running `date '+%H:%M %d-%b-%Y'` ONCE at the start of each session and reuse for all files in that response.

### On File EDIT (Edit tool)
- APPEND a new `Updated: HH:MM DD-MMM-YYYY` line after the last existing timestamp line (Created or previous Updated).
- Never remove or overwrite existing timestamps — this is an append-only log.
- Multiple updates stack chronologically:
  ```
  // Created: 04:53 14-Apr-2026
  // Updated: 09:20 14-Apr-2026
  // Updated: 16:45 15-Apr-2026
  ```
- **20-update cap**: Keep the `Created:` line + the 20 most recent `Updated:` lines. When a 21st update is added, remove the oldest `Updated:` line (not the `Created:` line — that is permanent). This prevents file headers from growing unbounded over months of edits.
- If editing a legacy file with NO `Created:` line, add `Created: [unknown]` then `Updated: HH:MM DD-MMM-YYYY`.
- For JSON config files, append the new timestamp string to the `"_updated"` array (cap at 20 entries, drop oldest).
- For images: when regenerating, create a new file with a new timestamped filename.

### Bulk Script Edits
- When using Python scripts for bulk operations (5+ files), the script MUST add an `Updated:` timestamp line to every file it modifies — same format as manual edits.
- Pattern: read the file, find the last `Created:` or `Updated:` line, insert a new `Updated:` line after it, write the file back.
- Report in the script summary: "Updated timestamps in X/Y files."

### Frontmatter & Parser Safety
- **YAML frontmatter files** (MDX, Jekyll, Hugo, Astro): timestamps go AFTER the closing `---`, never inside the frontmatter block. Placing inside frontmatter can break parsers.
- **Shebang files** (`#!/bin/bash`, `#!/usr/bin/env python`): timestamp goes on line 2, after the shebang.
- **XML with declarations** (`<?xml version="1.0"?>`): timestamp comment goes after the XML declaration.

### Git Merge Conflicts
- Timestamp lines are simple and resolve trivially — keep both sides' timestamps in chronological order.
- If a merge conflict occurs on timestamp lines, accept BOTH sets of `Updated:` entries sorted by date, then enforce the 20-update cap.

### Exceptions (NO timestamps)
- Generated/build output: lockfiles, node_modules, dist/, build/, .next/, compiled assets
- Minified files: `.min.js`, `.min.css`, `.bundle.js` — these are effectively generated output
- Third-party files not authored by Claude
- Binary files that cannot hold comments and aren't images (e.g., .woff, .wasm, .zip)
- Files in .git/ directory
- Package manager files: package-lock.json, pnpm-lock.yaml, yarn.lock, Gemfile.lock, poetry.lock, go.sum

## Response Timestamps (ALL RESPONSES — NO EXCEPTIONS) (Insights 2026-04-11 M2-Max)
- At the **start** of EVERY response, run `date '+%H:%M:%S %d-%b-%Y'` and print: `⏱ Started: HH:MM:SS DD-MMM-YYYY`
- At the **end** of EVERY response, run `date '+%H:%M:%S %d-%b-%Y'` AND `$HOME/bin/context-status.sh`, then print: `⏱ Completed: HH:MM:SS DD-MMM-YYYY (took XmYs) | ctx: ~120K/1M (12%)` — calculate the duration from the start timestamp, and append the context-status output.
- Duration format: if under 60s → `(took 45s)`, if 1-59 min → `(took 3m22s)`, if 1h+ → `(took 1h12m)`
- Context format: append ` | ctx: ` followed by the output of `$HOME/bin/context-status.sh` (e.g., `~120K/1M (12%)`)
- This applies to ALL responses — short answers, conversational replies, task responses, everything. No exceptions.
- This gives the user visibility into how long every interaction takes and how much context is consumed.

## Agent Swarm Monitoring (CRITICAL)
When launching **3 or more parallel agents**:
1. After launching all agents, immediately set a **60-second check timer** using `sleep 60`.
2. After 60 seconds, check each agent's status:
   - Read each agent's output file via `tail -20`
   - Report: which agents completed, which are still running, which appear stuck
3. If any agent has no output after 60s, report it immediately — do NOT wait longer.
4. Repeat the 60-second check cycle until all agents complete or are confirmed stuck.
5. For 10+ agents, use **90-second** intervals. For 15+ agents, use **120-second** intervals.
6. Always report progress: "5/12 agents complete, 6 running, 1 stuck (agent-name)"

## Project Notes File (CRITICAL — EVERY SAVE/HANDOFF)
On every `/save`, `/handoff`, or session end:
1. Append to `NOTES.md` in the project root (create if doesn't exist).
2. **NEVER overwrite** — always append a new entry at the bottom.
3. Format for each entry:
   ```
   ---
   ## Session: HH:MM DD-MMM-YYYY

   ### What was done
   - [bullet list of concrete changes made]

   ### What was learned
   - [gotchas discovered, decisions made, patterns found]

   ### Key files modified
   - [list of files changed with brief description]

   ### Handoff context
   - [what the next session needs to know]
   ```
4. This creates a permanent, append-only project history that survives memory overwrites.
5. When transferring a project to someone, `NOTES.md` gives them the full development story.
6. Also append a short entry (2-3 lines) to `~/.claude/logs/NOTES.md` — the **global** cross-project activity log. Format: `## HH:MM DD-MMM-YYYY — PROJECT_NAME (directory)` followed by bullet summary. This answers "what did I do across all projects this week/month?"

## Session Continuation Prompt (AUTO-GENERATE)
On every `/save` or `/handoff`, automatically generate a **copy-paste-ready continuation prompt** and print it to the user. Format:
```
--- CONTINUATION PROMPT (copy-paste into next session) ---
Continue work on [PROJECT_NAME] in [DIRECTORY].
Last session (DD-MMM-YYYY): [1-2 sentence summary of what was done].
Remaining work: [specific next steps].
Read NOTES.md and the project handoff at ~/.claude/projects/[project-key]/memory/handoff.md for full context.
--- END ---
```
- The user should be able to copy this block and paste it into a new session to resume instantly.
- Do NOT ask "should I generate a continuation prompt?" — always generate it automatically.

## Build & Indexing (Insights 2026-05-07 M2-Max)
<!-- Created: 22:38 07-May-2026 -->

### Working Directory Discipline
- Before running build/index commands (code-review-graph, etc.), verify cwd is the git root, not a parent directory
- Use `git rev-parse --show-toplevel` to confirm before long-running scans
- Never scan node_modules or parent directories — abort if file count exceeds expectation

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

### Session Saving
- When user says 'save' or 'save session', write handoff docs, update NOTES.md, and update session indexes — this is a known recurring workflow
- The `/save` slash command at `~/.claude/commands/save.md` already implements the canonical save flow — invoke it, don't reimplement

## Verification Discipline (Insights 2026-05-07 M2-Max)
<!-- Created: 22:40 07-May-2026 -->

### Verify Before Claiming "Found"
Before reporting success on ANY lookup, audit, or discovery task (domain status, account ownership, user existence, tracker presence, file existence, URL resolution), run a second-pass verification:
1. **Re-grep** for any tools/IDs/identifiers you might have missed (Factors.ai pixel, Clarity ID origin, secondary shareholders, etc.)
2. **Check status fields** explicitly — expired vs active vs deleted vs pending. Don't assume "exists in API response" = "available for use"
3. **Resolve URLs** you reference — `curl -I` any subdomain (demo.*, staging.*, app.*) before recommending it. Non-existent demo subdomains have been referenced in past sessions
4. **Report verification results explicitly** — say "verified via X" or "could not verify, treat as unconfirmed", not bare "found"

Reference precedents (do not repeat):
- Reported expired hidemo.site as "found" — failed to check expiry status
- Misattributed Microsoft Clarity ID origin between two clients
- Missed Factors.ai pixel in tracker audit until user prompted second pass
- Skipped second shareholder's passport files until prompted twice
- Referenced non-existent `demo.<client>.net` subdomain

Existing skills: `verification-before-completion`, `verification-loop`, `/verify`, `/verify-deploy` — invoke before reporting completion on multi-step or audit tasks.

## Recommended Setup — Not Auto-Applied (Insights 2026-05-07 M2-Max)
<!-- Created: 22:40 07-May-2026 -->

These are infrastructure recommendations from the insights report. They are NOT installed automatically because they require user-controlled credentials or are too noisy to apply globally. Install on demand:

### MCP Servers (require API keys — install per-project as needed)
```bash
# Stripe — typed API access instead of curl chains
claude mcp add stripe -- npx -y @stripe/mcp --tools=all --api-key=$STRIPE_SECRET_KEY

# Cloudflare — DNS/zone management
claude mcp add cloudflare -- npx -y @cloudflare/mcp-server-cloudflare
```
Why deferred: each MCP needs the correct numbered account key (per env-var rules above) and adds tool definitions to context. Install only in projects that actively use that provider.

### Project-Scoped TypeScript Hook (DO NOT install globally)
For Next.js / TS projects only, add to `<project>/.claude/settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{"type": "command", "command": "if [ -f tsconfig.json ]; then npx tsc --noEmit 2>&1 | head -20; fi"}]
    }]
  }
}
```
Why not global: would run `tsc` on every Edit/Write in non-TS projects (Python scripts, docs, HTML sites) — pure noise.

### Ambitious Workflows (queued for dedicated sessions)
- **Autonomous SEO audit pipeline** — leverage existing `seo-audit` + `seo-pipeline` skills with 8-agent parallel dispatch, write findings to `audits/<dimension>.md`, synthesize `audits/REPORT.md`
- **`infra-ops` MCP server** — TypeScript wrapper around SendGrid/Cloudflare/GoDaddy/Stripe with credential pre-flight + atomic cross-account migrations + drift detection
- **Self-healing build loop** — `auto-build.sh` running `claude -p` on stderr until green; pair with `/ship` slash command

These are NOT one-shot session work — design and build them in dedicated sessions against a target project.
