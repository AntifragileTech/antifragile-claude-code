# Module 3: Commands

> Installs 84 slash commands for planning, TDD, code review, debugging, deployment, and more.

> **💡 Tip**: For Claude to auto-discover and proactively use these assets, also run **Module 0: Core Setup** — it adds a Skill Auto-Discovery rule to your CLAUDE.md so Claude matches skills to tasks automatically.


## Copy this prompt into Claude Code:

```
Clone https://github.com/AntifragileTech/antifragile-claude-code.git to /tmp/ccpp with --depth 1.

Then install commands:

1. Create ~/.claude/commands/ if it doesn't exist
2. Copy all .md files from /tmp/ccpp/assets/commands/ into ~/.claude/commands/
3. For each file: if it already exists, SKIP it (never overwrite)
4. Report how many commands were installed vs skipped

After copying, clean up: rm -rf /tmp/ccpp
```

## What's Included (84 commands)

**Planning**: /plan, /create-plan, /write-plan, /brainstorm, /multi-plan

**Development**: /implement, /implement-next, /tdd, /build-fix, /quick-fix, /bugfix, /refactor-clean

**Review**: /code-review, /review-pr, /go-review, /python-review, /verify, /test-coverage

**Testing**: /e2e, /go-test, /fix-tests

**Git/PR**: /commit, /create-pr, /rebase, /release-docs

**Debugging**: /debug, /root-cause, /analyze-issue

**Meta**: /checkpoint, /handoff, /sessions, /projects, /whats-next

**Multi-agent**: /multi-execute, /multi-frontend, /multi-backend, /multi-workflow, /orchestrate
