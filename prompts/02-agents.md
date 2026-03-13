# Module 2: Agents

> Installs 68 specialized agents for architecture, planning, TDD, code review, security, performance, and more.

> **💡 Tip**: For Claude to auto-discover and proactively use these assets, also run **Module 0: Core Setup** — it adds a Skill Auto-Discovery rule to your CLAUDE.md so Claude matches skills to tasks automatically.


## Copy this prompt into Claude Code:

```
Clone https://github.com/AntifragileTech/antifragile-claude-code.git to /tmp/ccpp with --depth 1.

Then install agents:

1. Create ~/.claude/agents/ if it doesn't exist
2. Copy all .md files from /tmp/ccpp/assets/agents/ into ~/.claude/agents/
3. For each file: if it already exists, SKIP it (never overwrite)
4. Report how many agents were installed vs skipped

After copying, clean up: rm -rf /tmp/ccpp
```

## What's Included (68 agents)

**Architecture & Planning**: architect, planner, software-architect, code-architect, code-explorer, tech-lead, business-analyst, team-lead

**Code Quality**: code-reviewer, code-simplifier, pattern-recognition-specialist, contracts-reviewer, historical-context-reviewer, agent-native-reviewer

**Testing**: tdd-guide, e2e-runner, pr-test-analyzer

**Security**: security-reviewer, security-sentinel, security-auditor, silent-failure-hunter

**Performance**: performance-oracle, harness-optimizer

**DevOps**: build-error-resolver, go-build-resolver, deployment-verification-agent, data-migration-expert

**Documentation**: doc-updater, tech-writer, comment-analyzer, ankane-readme-writer

**Specialized**: dhh-rails-reviewer, julik-frontend-races-reviewer, kieran-rails-reviewer, kieran-python-reviewer, kieran-typescript-reviewer, python-reviewer, go-reviewer, database-reviewer

**Meta/Orchestration**: loop-operator, bug-hunter, bug-reproduction-validator, refactor-cleaner, schema-drift-detector, spec-flow-analyzer, architecture-strategist, type-design-analyzer
