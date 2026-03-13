# Antifragile Claude Code

> Turn Claude Code from a basic assistant into a fully-equipped engineering, security, DevOps, and marketing powerhouse — with one prompt at a time.

**514 skills** · **68 agents** · **84 commands** · **29 rules** · **Zero scripting required**

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
| 1 | **Coding Rules** | 29 rule files: immutability, testing (80% coverage), security, git workflow, patterns | [01-rules.md](prompts/01-rules.md) |
| 2 | **Agents** | 68 specialized agents: architect, planner, TDD guide, security reviewer, and more | [02-agents.md](prompts/02-agents.md) |
| 3 | **Commands** | 84 slash commands: /plan, /tdd, /code-review, /brainstorm, /debug, and more | [03-commands.md](prompts/03-commands.md) |
| 4 | **Dev Skills** | 188 framework & language skills: React, Next.js, Django, FastAPI, Rails, Rust, Go, Swift... | [04-skills-dev.md](prompts/04-skills-dev.md) |
| 5 | **Security Skills** | 40 security skills from Trail of Bits: semgrep, codeql, fuzzing, vulnerability scanners | [05-skills-security.md](prompts/05-skills-security.md) |
| 6 | **DevOps Skills** | 46 infra skills: Terraform, Kubernetes, Helm, Docker, Ansible, CI/CD generators | [06-skills-devops.md](prompts/06-skills-devops.md) |
| 7 | **GTM Skills** | 86 go-to-market skills: SEO, ads, outreach, competitor intel, content creation | [07-skills-gtm.md](prompts/07-skills-gtm.md) |
| 8 | **Marketing Skills** | 39 marketing/CRO skills: copywriting, email sequences, pricing, A/B testing | [08-skills-marketing.md](prompts/08-skills-marketing.md) |
| 9 | **Thinking Skills** | 115 reasoning & meta skills: kaizen, tree-of-thoughts, debate, agent orchestration | [09-skills-thinking.md](prompts/09-skills-thinking.md) |
| 🚀 | **FULL INSTALL** | Everything above in one shot | [10-full-install.md](prompts/10-full-install.md) |
| ↩️ | **ROLLBACK** | Remove any module or everything | [11-rollback.md](prompts/11-rollback.md) |

---

## Quick Start — Full Install (Everything)

If you want the complete setup, just copy the prompt from [prompts/10-full-install.md](prompts/10-full-install.md) and paste it into Claude Code.

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

Copy the rollback prompt from [prompts/11-rollback.md](prompts/11-rollback.md) and paste it into a new Claude Code session. It covers:
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

## License

MIT
