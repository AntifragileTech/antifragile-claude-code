# Antifragile Claude Code

> Turn Claude Code from a basic assistant into a fully-equipped engineering, security, DevOps, and marketing powerhouse — with one prompt at a time.

**570 skills** · **69 agents** · **97 commands** · **32 rules** · **7 bin scripts** · **16 prompt modules** · **Multi-machine sync** · **Zero scripting required**

---

## How It Works

1. Pick a module from the table below
2. Open the prompt file
3. Copy the prompt
4. Paste it into Claude Code and hit Enter
5. Done. Claude installs everything for you.

Every prompt is **safe merge** — it never overwrites your existing setup. Run any prompt twice and nothing breaks.

---

## Modules

| # | Module | What You Get | Prompt File |
|---|--------|-------------|-------------|
| Pre | **Preflight Check** | Verify git, python3, disk space — auto-installs missing deps | [00-preflight.md](prompts/00-preflight.md) |
| 0 | **Core Setup** | Global CLAUDE.md with auto-discovery rules so Claude proactively uses all your skills | [00-core-setup.md](prompts/00-core-setup.md) |
| 1 | **Coding Rules** | 32 rule files: immutability, testing (80% coverage), security, git workflow, patterns | [01-rules.md](prompts/01-rules.md) |
| 2 | **Agents** | 69 specialized agents: architect, planner, TDD guide, security reviewer, and more | [02-agents.md](prompts/02-agents.md) |
| 3 | **Commands** | 97 slash commands: /plan, /tdd, /code-review, /brainstorm, /debug, and more | [03-commands.md](prompts/03-commands.md) |
| 4 | **Dev Skills** | 226 framework & language skills: React, Next.js, Django, FastAPI, Rails, Rust, Go, Swift... | [04-skills-dev.md](prompts/04-skills-dev.md) |
| 5 | **Security Skills** | 41 security skills from Trail of Bits: semgrep, codeql, fuzzing, vulnerability scanners | [05-skills-security.md](prompts/05-skills-security.md) |
| 6 | **DevOps Skills** | 46 infra skills: Terraform, Kubernetes, Helm, Docker, Ansible, CI/CD generators | [06-skills-devops.md](prompts/06-skills-devops.md) |
| 7 | **GTM Skills** | 86 go-to-market skills: SEO, ads, outreach, competitor intel, content creation | [07-skills-gtm.md](prompts/07-skills-gtm.md) |
| 8 | **Marketing Skills** | 39 marketing/CRO skills: copywriting, email sequences, pricing, A/B testing | [08-skills-marketing.md](prompts/08-skills-marketing.md) |
| 9 | **Thinking Skills** | 115 reasoning & meta skills: kaizen, tree-of-thoughts, debate, agent orchestration | [09-skills-thinking.md](prompts/09-skills-thinking.md) |
| 10 | **Ops Skills** | 9 operational workflow skills: parallel bug-fix, staged deploy, localization, QA | [10a-skills-ops.md](prompts/10a-skills-ops.md) |
| 12 | **Learning Skills** | 1 learning & teaching skill: Feynman technique for concept mastery | [12-skills-learning.md](prompts/12-skills-learning.md) |
| 13 | **Templates** | CLAUDE.md template, settings.json template, hooks script, bin scripts | [13-templates.md](prompts/13-templates.md) |
| All | **FULL INSTALL** | Everything above in one shot | [14-full-install.md](prompts/14-full-install.md) |
| Undo | **ROLLBACK** | Remove any module or everything | [15-rollback.md](prompts/15-rollback.md) |

---

## Quick Start

### Full Install (Everything)

Copy the prompt from [prompts/14-full-install.md](prompts/14-full-install.md) and paste it into a new Claude Code session.

**Estimated time**: ~5 minutes. Claude clones this repo, copies all assets, sets up CLAUDE.md, and reports final counts.

### Script Install (Mac/Linux)

```bash
git clone --depth 1 https://github.com/AntifragileTech/antifragile-claude-code.git /tmp/ccpp
bash /tmp/ccpp/install.sh              # install everything
bash /tmp/ccpp/install.sh --module 4   # install only dev skills
bash /tmp/ccpp/install.sh --module 2 3 # install modules 2 and 3
bash /tmp/ccpp/install.sh --list       # see available modules
bash /tmp/ccpp/install.sh --status     # check what's installed
rm -rf /tmp/ccpp
```

---

## Skill Categories

| Category | Count | What's Inside |
|----------|-------|---------------|
| **dev** | 226 | React, Next.js, Vue, Angular, Django, FastAPI, Rails, Rust, Go, Swift, Kotlin, Java, Spring Boot, Laravel, PHP, C++, C#, Flutter, TypeScript, CLI tools, API design, database patterns, testing, debugging |
| **security** | 41 | Semgrep, CodeQL, fuzzing (AFL++, libFuzzer, cargo-fuzz), vulnerability scanners (Solana, Cairo, Algorand, Cosmos, Substrate, TON), supply chain audit, YARA rules, constant-time analysis |
| **devops** | 46 | Terraform, Kubernetes, Helm, Docker, Ansible, Jenkins, GitLab CI, GitHub Actions, Azure Pipelines, Fluent Bit, Loki, PromQL, Makefiles, Dockerfiles |
| **gtm** | 86 | ICP builders, competitor intel, LinkedIn/Twitter/Reddit scrapers, ad campaign builders (Google, Meta), email sequences, conference speaker scrapers, funding signal monitors, champion trackers |
| **marketing** | 39 | Copywriting, SEO audit, page/form/popup/signup CRO, email sequences, paid ads, content strategy, pricing strategy, referral programs, A/B testing |
| **thinking** | 115 | Kaizen (root cause, PDCA, fishbone), tree-of-thoughts, debate, brainstorming, FPF reasoning, reflexion, multi-agent patterns, sub-agent orchestration |
| **ops** | 9 | Parallel bugfix, staged deploy, parallel QA, localization pipeline, cross-app audit, infra healthcheck, cPanel deploy |
| **media** | 6 | FFmpeg video/audio, AI music (ACE-Step), AI video (LTX-2), AI image editing (Qwen), voice cloning (ElevenLabs), cloud GPU (RunPod) |
| **learning** | 1 | Feynman learning coach |
| **seo** | 1 | Google Search Console regex patterns |

---

## What Each Module Does

### Module 0: Core Setup
Adds a `Skill Auto-Discovery` section to your global `~/.claude/CLAUDE.md`. This makes Claude **proactively use** all installed skills instead of waiting for you to invoke them manually. Install this first.

### Module 1: Coding Rules
Installs 32 rule files into `~/.claude/rules/` organized by:
- **common/** — Universal: immutability, error handling, testing (80% min), security, git workflow, SEO methodology, development workflow, agent orchestration
- **typescript/** — TS-specific patterns, hooks, testing
- **python/** — Python-specific patterns, hooks, testing
- **golang/** — Go-specific patterns, hooks, testing
- **swift/** — Swift-specific patterns, hooks, testing

### Module 2: Agents (69)
Specialized AI personas Claude delegates to:
- `architect` / `planner` — System design and implementation planning
- `tdd-guide` — Test-driven development enforcement
- `code-reviewer` / `security-reviewer` — Automated code and security review
- `build-error-resolver` — Fixes build failures with minimal changes
- `performance-oracle` — Performance bottleneck analysis
- `e2e-runner` — End-to-end testing with Playwright
- `refactor-cleaner` — Dead code removal and consolidation
- `tech-lead` / `business-analyst` — Task breakdown and acceptance criteria
- `bug-hunter` / `bug-reproduction-validator` — Bug detection and reproduction
- `database-reviewer` — PostgreSQL query optimization
- `deployment-verification-agent` — Go/No-Go deployment checklists
- `observer` — Living progress documentation during sessions
- And 57 more...

### Module 3: Commands (97)
Slash commands you invoke directly:
- **Planning**: `/plan`, `/create-plan`, `/autoplan`, `/brainstorm`
- **Development**: `/tdd`, `/bugfix`, `/quick-fix`, `/build-fix`, `/fix-ts`
- **Review**: `/code-review`, `/review-pr`, `/go-review`, `/python-review`
- **Git**: `/commit`, `/create-pr`, `/rebase`, `/ship`, `/worktrees`
- **Deploy**: `/deploy`, `/pre-deploy`, `/verify-deploy`, `/staged-deploy`
- **Quality**: `/qa`, `/e2e`, `/test-coverage`, `/parallel-qa`
- **Config**: `/sync-push`, `/sync-pull`, `/save`, `/handoff`, `/checkpoint`
- **Meta**: `/health`, `/healthcheck`, `/context-save`, `/auto-clear`

### Module 13: Templates & Scripts
Starter templates and utility scripts:
- `CLAUDE.md.template` — Battle-tested global instructions with 25+ sections
- `settings.json.template` — Recommended settings with hooks, permissions, and environment config
- `claude-hooks.sh` — Universal hook handler for all 17 session lifecycle events
- **7 bin scripts**: `context-status.sh` (token tracking), `claude-hooks.sh`, `claude-checkpoint.sh`, `claude-export.sh`, `claude-init.sh`, `claude-parallel.sh`, `claude-sync-export.sh`

---

## Multi-Machine Sync

Keep your Claude Code config synchronized across multiple machines using built-in `/sync-push` and `/sync-pull` commands.

### How It Works

```
Machine A                    GitHub Repo                   Machine B
~/.claude/ ──/sync-push──▶  antifragile-claude-code  ◀──/sync-pull── ~/.claude/
~/bin/     ──────────────▶  assets/bin/              ◀────────────── ~/bin/
```

### What Syncs

| Asset | Push | Pull | Method |
|-------|------|------|--------|
| Skills | New only | New only | Additive (never overwrites) |
| Agents | New only | New only | Additive |
| Commands | New only | New only | Additive |
| Rules | New only | New only | Additive |
| Bin scripts | New + updated | New + updated | Smart merge (newer wins) |
| CLAUDE.md | Always | Insights merge | Section-level sync |
| Insights | Extract tagged sections | Merge missing sections | Dedup by header |
| Machine signatures | Always | Read-only | JSON manifest |

### Insights Flow

Tag any CLAUDE.md section with `(Insights YYYY-MM-DD HOSTNAME)` and it automatically syncs to all machines:

```markdown
## Response Timestamps (Insights 2026-04-11 M2-Max)
- At the end of EVERY response, include context token percentage...
```

`/sync-push` extracts these to `assets/insights/{hostname}.md`. `/sync-pull` merges missing sections into local CLAUDE.md on other machines.

### Personal Data Protection

Both `/sync-push` and `/sync-pull` include multi-layer scanning:
- **Pre-push scan**: Checks local files for usernames, domains, client names before copying
- **Staging scan**: Re-scans the repo staging area before commit
- **Blocked on detection**: Push is halted if personal data is found

---

## Context Tracking

Every response includes real-time context window usage:

```
Completed: 20:47:35 11-Apr-2026 (took 1m37s) | ctx: ~203K/1M (20%)
```

The `context-status.sh` script estimates token usage from transcript file size plus fixed overhead for tools, skills, and memory. Installed to `~/bin/` via `/sync-pull` and referenced in the CLAUDE.md timestamp rule.

---

## Repository Structure

```
antifragile-claude-code/
  assets/
    agents/          # 69 agent .md files
    bin/             # 7 utility scripts (context-status, hooks, etc.)
    claude-md/       # Per-machine CLAUDE.md snapshots
    commands/        # 97 command .md files
    git-hooks/       # Pre-push account verification hook
    insights/        # Per-machine Insights extracts
    machines/        # Machine signature JSON manifests
    rules/           # 32 rule files (common + 4 languages)
    scripts/         # Post-install, security patch, skill scan
    skills/          # 570 skills across 10 categories
      dev/           #   226 development skills
      devops/        #   46 infrastructure skills
      gtm/           #   86 go-to-market skills
      marketing/     #   39 marketing/CRO skills
      media/         #   6 media generation skills
      ops/           #   9 operational workflow skills
      security/      #   41 security analysis skills
      seo/           #   1 SEO skill
      thinking/      #   115 reasoning/meta skills
      learning/      #   1 learning skill
  prompts/           # 16 installation prompt modules
  install.sh         # Script-based installer
  uninstall.sh       # Script-based rollback
```

---

## Before You Start

### Session Setup

1. **Open a new Claude Code session** — don't paste into an existing one
2. **Start from your home directory** — this ensures `~/.claude/` resolves correctly
   - **Mac/Linux**: Open terminal, type `claude` (you're already in `~`)
   - **Windows**: Open terminal in `C:\Users\YourName`, then run `claude`
3. Copy a prompt from the table above and paste it in

### Platform Compatibility

| Platform | Prompt Install | Script Install | Notes |
|----------|---------------|----------------|-------|
| **macOS** | Yes | Yes | Full support |
| **Linux** | Yes | Yes | Full support |
| **Windows** | Yes | Via Git Bash/WSL | Prompts work natively. Scripts need bash. |

**No dependencies** beyond Claude Code itself. The prompts tell Claude to clone the repo and copy files — Claude handles everything.

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and working
- Git (for cloning — Claude uses it automatically)
- That's it.

---

## Uninstalling / Rollback

### Option 1: Prompt-based (All platforms)

Copy the rollback prompt from [prompts/15-rollback.md](prompts/15-rollback.md) and paste it into a new Claude Code session. Supports removing specific modules or everything.

### Option 2: Script-based (Mac/Linux)

```bash
git clone --depth 1 https://github.com/AntifragileTech/antifragile-claude-code.git /tmp/ccpp
bash /tmp/ccpp/uninstall.sh --list       # see what's installed
bash /tmp/ccpp/uninstall.sh --module 4   # remove module 4
bash /tmp/ccpp/uninstall.sh --all        # remove everything
rm -rf /tmp/ccpp
```

### What rollback preserves

Rollback **never** touches:
- Your own custom skills (anything you created before installing)
- Your `~/.claude/settings.json`
- Your project-level `CLAUDE.md` files
- Any Claude Code config not part of this pack

---

## FAQ

**Q: Will this overwrite my existing skills/agents/commands?**
No. Every prompt uses safe merge — existing files are never overwritten.

**Q: Can I install just one module?**
Yes. Each module is independent. Install any combination you want.

**Q: Do I need to restart Claude Code after installing?**
Yes, start a new session for changes to take effect.

**Q: How do I update to newer versions?**
Re-run the same prompt. It skips existing files and only adds new ones.

**Q: What if I don't want marketing/GTM skills?**
Skip modules 7 and 8. Only install what you need.

**Q: How do I sync across multiple machines?**
Use `/sync-push` on the source machine, `/sync-pull` on others. Both commands are installed with Module 3.

**Q: Is my personal data safe?**
Yes. Multi-layer scanning blocks pushes that contain usernames, project domains, or client names.

---

## Companion Tools (Install Separately)

These tools complement the pack but are installed independently.

### gstack by Garry Tan (60K+ stars)

23 opinionated slash commands: CEO review, staff engineer code review, real-browser QA, security audit, and release pipeline.

```bash
curl -fsSL https://bun.sh/install | bash
git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
cd ~/.claude/skills/gstack && ./setup
```

**Key commands:** `/qa`, `/review`, `/office-hours`, `/ship`, `/cso`, `/retro`, `/browse`
**Upgrade:** `/gstack-upgrade` in any session. **Remove:** `rm -rf ~/.claude/skills/gstack`

### SkillGuard (Security Auditor)

Audits agent skills for security vulnerabilities — maps findings to OWASP Top 10 for Agentic Apps + MITRE ATLAS.

```bash
git clone https://github.com/LLMSecurity/skillguard.git ~/.claude/skills/skillguard
```

**Usage:** Ask Claude: "Audit all skills in ~/.claude/skills/"

---

## Credits & Sources

Skills and configurations were curated from:
- [everything-claude-code](https://github.com/affaan-m/everything-claude-code) — Core dev skills, agents, commands
- [Trail of Bits](https://github.com/trailofbits) — Security skills (semgrep, codeql, fuzzing)
- [cc-devops-skills](https://github.com/dkmaker-xyz/cc-devops-skills) — DevOps/infra skills
- [goose-skills](https://github.com/athina-ai/goose-skills) — GTM/marketing skills (MIT)
- [context-engineering-kit](https://github.com/cyanheads/context-engineering-kit) — Thinking/reasoning skills
- [compound-engineering](https://github.com/grapeot/compound-engineering) — Advanced agents
- [superpowers](https://github.com/nicobailon/claude-code-superpowers) — Meta skills
- [ui-ux-pro-max](https://github.com/m-spunky/ui-ux-pro-max) — Design skills
- [obsidian-skills](https://github.com/lostinsoba/claude-code-obsidian-skills) — Obsidian integration
- [jeffallan](https://github.com/jeffallan/claude-code-skills) — Framework-specific skills
- [agentsys](https://github.com/pinkpixel-dev/agentsys) — Performance & enhancement skills
- [taches](https://github.com/julienblin/taches) — Utility commands & skills
- [scopecraft](https://github.com/scopecraft/claude-code) — Project management commands

All sources are open-source. Check individual repos for their specific licenses.

---

## License

MIT
