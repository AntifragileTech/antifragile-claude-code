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

## Bulk/Batch Operations — Use Python Scripts, Not AI
- For ANY task that involves modifying, generating, or processing more than 5 files with a repeatable pattern, **write a Python script** in `/tmp/` and execute it — do NOT make edits file-by-file with AI.
- This applies to: bulk HTML page generation, cross-page find-and-replace, image processing/cropping, data scraping, sitemap updates, adding nav links across many pages, etc.
- Python scripts are faster, more reliable, produce consistent results, and don't consume AI context window.
- Pattern: Write a focused Python script → test on 1-2 files → run on all files → report results.
- Always print progress and a summary (e.g., "Fixed 159/159 pages, 0 errors").
- Save scripts in `/tmp/` with descriptive names (e.g., `/tmp/acpn_fix_buttons.py`).
- For image processing: use OpenCV for detection + Pillow (PIL) for high-quality crops/resizes.
- For HTML manipulation: use regex or string matching — no need for heavy parsers on static HTML.

## File Creation Timestamp (CRITICAL — ALL FILES)
Every file created via Write tool MUST include a creation timestamp comment as the FIRST line (or after shebang/frontmatter). Format by file type:
- **JS/TS/TSX/JSX/Java/C/C++/Go/Rust/Swift/Kotlin**: `// Created: HH:MM DD-MMM-YYYY`
- **Python/Ruby/Shell/YAML/TOML**: `# Created: HH:MM DD-MMM-YYYY`
- **HTML/XML/SVG**: `<!-- Created: HH:MM DD-MMM-YYYY -->`
- **CSS/SCSS/LESS**: `/* Created: HH:MM DD-MMM-YYYY */`
- **Markdown**: `<!-- Created: HH:MM DD-MMM-YYYY -->`  (first line, before any content)
- **SQL**: `-- Created: HH:MM DD-MMM-YYYY`
- **JSON**: Skip (JSON doesn't support comments) — instead add `"_created"` key if it's a config file
- Get the exact time by running `date '+%H:%M %d-%b-%Y'` ONCE at the start of each session and reuse that timestamp for all files created in that response.
- This applies to NEW files only — never add timestamps when editing existing files.
- Exception: generated files (build output, lockfiles, node_modules) are excluded.

## Response Timestamps (ALL RESPONSES — NO EXCEPTIONS)
- At the **start** of EVERY response, run `date '+%H:%M:%S %d-%b-%Y'` and print: `⏱ Started: HH:MM:SS DD-MMM-YYYY`
- At the **end** of EVERY response, run `date '+%H:%M:%S %d-%b-%Y'` and print: `⏱ Completed: HH:MM:SS DD-MMM-YYYY (took XmYs)` — calculate the duration from the start timestamp.
- Duration format: if under 60s → `(took 45s)`, if 1-59 min → `(took 3m22s)`, if 1h+ → `(took 1h12m)`
- This applies to ALL responses — short answers, conversational replies, task responses, everything. No exceptions.
- This gives the user visibility into how long every interaction takes.

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
