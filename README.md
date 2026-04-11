# Antifragile Claude Code

> Turn Claude Code from a basic assistant into a fully-equipped engineering, security, DevOps, and marketing powerhouse — with one prompt at a time.

**523 skills** · **68 agents** · **84 commands** · **30 rules** · **3 templates** · **Zero scripting required**

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
| 🔍 | **Preflight Check** | Verify git, python3, disk space — auto-installs missing deps | [00-preflight.md](prompts/00-preflight.md) |
| 0 | **Core Setup** | Global CLAUDE.md with auto-discovery rules so Claude proactively uses all your skills | [00-core-setup.md](prompts/00-core-setup.md) |
| 1 | **Coding Rules** | 30 rule files: immutability, testing (80% coverage), security, git workflow, patterns | [01-rules.md](prompts/01-rules.md) |
| 2 | **Agents** | 68 specialized agents: architect, planner, TDD guide, security reviewer, and more | [02-agents.md](prompts/02-agents.md) |
| 3 | **Commands** | 84 slash commands: /plan, /tdd, /code-review, /brainstorm, /debug, and more | [03-commands.md](prompts/03-commands.md) |
| 4 | **Dev Skills** | 188 framework & language skills: React, Next.js, Django, FastAPI, Rails, Rust, Go, Swift... | [04-skills-dev.md](prompts/04-skills-dev.md) |
| 5 | **Security Skills** | 40 security skills from Trail of Bits: semgrep, codeql, fuzzing, vulnerability scanners | [05-skills-security.md](prompts/05-skills-security.md) |
| 6 | **DevOps Skills** | 46 infra skills: Terraform, Kubernetes, Helm, Docker, Ansible, CI/CD generators | [06-skills-devops.md](prompts/06-skills-devops.md) |
| 7 | **GTM Skills** | 86 go-to-market skills: SEO, ads, outreach, competitor intel, content creation | [07-skills-gtm.md](prompts/07-skills-gtm.md) |
| 8 | **Marketing Skills** | 38 marketing/CRO skills: copywriting, email sequences, pricing, A/B testing | [08-skills-marketing.md](prompts/08-skills-marketing.md) |
| 9 | **Thinking Skills** | 115 reasoning & meta skills: kaizen, tree-of-thoughts, debate, agent orchestration | [09-skills-thinking.md](prompts/09-skills-thinking.md) |
| 10 | **Ops Skills** | 8 operational workflow skills: parallel bug-fix, staged deploy, localization pipeline, QA | [10a-skills-ops.md](prompts/10a-skills-ops.md) |
| 12 | **Learning Skills** | 1 learning & teaching skill: Feynman technique for concept mastery | [12-skills-learning.md](prompts/12-skills-learning.md) |
| 13 | **Templates** | CLAUDE.md template, settings.json template, hooks script | [13-templates.md](prompts/13-templates.md) |
| 🚀 | **FULL INSTALL** | Everything above in one shot | [14-full-install.md](prompts/14-full-install.md) |
| ↩️ | **ROLLBACK** | Remove any module or everything | [15-rollback.md](prompts/15-rollback.md) |

---

## Quick Start — Full Install (Everything)

If you want the complete setup, just copy the prompt from [prompts/14-full-install.md](prompts/14-full-install.md) and paste it into Claude Code.

**Estimated time**: ~5 minutes. Claude will clone this repo, copy all assets, set up your CLAUDE.md, and report final counts.

---

## What Each Module Does

### Module 0: Core Setup
Adds a `Skill Auto-Discovery` section to your global `~/.claude/CLAUDE.md`. This is what makes Claude **proactively use** all installed skills instead of waiting for you to invoke them manually. Install this first.

### Module 1: Coding Rules
Installs rule files into `~/.claude/rules/` organized by:
- **common/** — Universal: immutability, error handling, testing (80% min), security, git workflow
- **typescript/** — TS-specific patterns, hooks, testing
- **python/** — Python-specific patterns, hooks, testing
- **golang/** — Go-specific patterns, hooks, testing
- **swift/** — Swift-specific patterns, hooks, testing

### Module 2: Agents
Agents are specialized AI personas Claude can delegate to. Examples:
- `architect` — System design decisions
- `planner` — Implementation planning
- `tdd-guide` — Test-driven development enforcement
- `code-reviewer` — Automated code review
- `security-sentinel` — Security vulnerability detection
- `performance-oracle` — Performance analysis

### Module 3: Commands
Slash commands you can invoke directly: `/plan`, `/tdd`, `/code-review`, `/brainstorm`, `/debug`, `/verify`, `/build-fix`, `/create-pr`, and 76 more.

### Module 10: Ops Skills
Operational workflow skills for real-world deployment and QA:
- `parallel-bugfix` — Spawn 3 parallel agents with different fix strategies, pick the winner
- `staged-deploy` — 4-phase deployment: pre-deploy → staging smoke tests → decision gate → production
- `parallel-qa` — 4 parallel QA agents testing API, Web, Storefront, and Marketing simultaneously
- `localization-pipeline` — Autonomous multi-language translation with scan → fix → validate → report
- `cross-app-audit` — Systematic monorepo audit with P0/P1/P2 categorized findings
- `infra-healthcheck` — Pre-session infrastructure validation (tokens, Docker, services)
- `self-healing-observer` — Pre-flight auth check with local file fallback
- `deploy-cpanel` — cPanel zip deployment with Python zipfile and validation checklist

### Module 12: Learning Skills
Learning and teaching skills using proven pedagogical techniques:
- `feynman` — Feynman Learning Coach: transforms complex concepts into intuitive clarity through iterative simplification, analogies, and guided discovery

### Module 13: Templates
Starter templates for configuring Claude Code:
- `CLAUDE.md.template` — Battle-tested global instructions with 25+ sections
- `settings.json.template` — Recommended settings with hooks, permissions, and environment config
- `claude-hooks.sh` — Universal hook handler for session lifecycle, safety checks, and build verification

### Modules 4–9: Skills by Category
Skills are deep reference documents Claude uses when working on specific tasks. They contain best practices, patterns, and step-by-step guides for each domain.

---

## Before You Start

### Session Setup (Important)

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

**No dependencies** beyond Claude Code itself. The prompts tell Claude to clone the repo and copy files — Claude handles everything. No Python, Node, or package managers needed.

---

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and working
- Git (for cloning this repo — Claude uses it automatically)
- That's it.

---

## Power User: Script Install (Mac/Linux)

If you prefer a single bash script over prompts:

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

## Uninstalling / Rollback

Changed your mind? Want to clean up? You can remove any module or everything — even weeks after installation.

### Option 1: Prompt-based rollback (All platforms)

Copy the rollback prompt from [prompts/15-rollback.md](prompts/15-rollback.md) and paste it into a new Claude Code session. It covers:
- Removing specific modules by number
- Removing everything at once
- Confirmation before any deletion

### Option 2: Script-based rollback (Mac/Linux)

If you installed using `install.sh`, manifests were saved automatically:

```bash
git clone --depth 1 https://github.com/AntifragileTech/antifragile-claude-code.git /tmp/ccpp

bash /tmp/ccpp/uninstall.sh --list       # see what's installed
bash /tmp/ccpp/uninstall.sh --module 4   # remove module 4
bash /tmp/ccpp/uninstall.sh --module 7 8 # remove modules 7 and 8
bash /tmp/ccpp/uninstall.sh --all        # remove everything

rm -rf /tmp/ccpp
```

### What rollback preserves

Rollback **never** touches:
- Your own custom skills (anything you created yourself before installing)
- Your `~/.claude/settings.json`
- Your project-level `CLAUDE.md` files
- Any Claude Code config not part of the Antifragile Claude Code

---

## FAQ

**Q: Will this overwrite my existing skills/agents/commands?**
No. Every prompt uses safe merge — existing files are never overwritten.

**Q: Can I install just one module?**
Yes. Each module is independent. Install any combination you want.

**Q: Do I need to restart Claude Code after installing?**
Yes, start a new session for changes to take effect.

**Q: How do I update to newer versions?**
Re-run the same prompt. It will skip existing files and only add new ones.

**Q: What if I don't want marketing/GTM skills?**
Skip modules 7 and 8. Only install what you need.

---

## Credits & Sources

Skills and configurations in this pack were curated from:
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

## Companion Tools (Install Separately)

These tools complement the Antifragile pack but are installed independently — they have their own repos and update cycles.

### gstack by Garry Tan (60K+ stars)

23 opinionated slash commands that turn Claude Code into a virtual engineering team — CEO review, staff engineer code review, real-browser QA, security audit, and release pipeline.

**Install:**
```bash
# Requires Bun (https://bun.sh)
curl -fsSL https://bun.sh/install | bash

# Clone and setup
git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
cd ~/.claude/skills/gstack && ./setup
```

**Key commands:** `/qa`, `/review`, `/office-hours`, `/ship`, `/cso`, `/retro`, `/browse`

**Rollback (complete removal):**
```bash
# Remove gstack skills and all generated files
rm -rf ~/.claude/skills/gstack

# Remove Codex/Factory copies if created
rm -rf ~/.codex/skills/gstack*
rm -rf ~/.factory/skills/gstack*

# Optional: remove Bun if no longer needed
rm -rf ~/.bun
sed -i '' '/\.bun\/bin/d' ~/.zshrc
```

**Upgrade:** Run `/gstack-upgrade` in any Claude Code session.

**Compatibility:** gstack installs into `~/.claude/skills/gstack/` — a subfolder that coexists with all Antifragile skills. No conflicts, no overwrites.

### Aperant (13K+ stars)

Desktop Electron app for visual task management with parallel agent terminals, git worktree isolation, and automatic QA loops.

**Install:**
Download from [github.com/AndyMik90/Aperant/releases](https://github.com/AndyMik90/Aperant/releases) — macOS, Windows, Linux.

**Rollback:**
```bash
# macOS
rm -rf /Applications/Aperant.app

# Config cleanup (optional)
rm -rf ~/.auto-claude
```

**Compatibility:** Aperant wraps Claude Code — your `~/.claude/` config (skills, agents, commands, rules) works underneath it.

### SkillGuard (Security Auditor)

Audits agent skills for security vulnerabilities before installation — maps findings to OWASP Top 10 for Agentic Apps + MITRE ATLAS.

**Install:**
```bash
git clone https://github.com/LLMSecurity/skillguard.git ~/.claude/skills/skillguard
```

**Usage:** Ask Claude: "Audit all skills in ~/.claude/skills/" or "Is this skill safe to install? [URL]"

**Rollback:**
```bash
rm -rf ~/.claude/skills/skillguard
```

**Why:** 341 malicious skills were found on ClawHub in Feb 2026. A study of 22,511 public skills found 140,963 security findings. Run SkillGuard after installing any new skills.

---

## License

MIT
