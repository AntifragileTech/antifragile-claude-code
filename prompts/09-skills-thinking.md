# Module 9: Thinking, Reasoning & Meta Skills

> Installs 115 skills for reasoning frameworks, agent orchestration, prompt engineering, and workflow automation.

> **💡 Tip**: For Claude to auto-discover and proactively use these assets, also run **Module 0: Core Setup** — it adds a Skill Auto-Discovery rule to your CLAUDE.md so Claude matches skills to tasks automatically.


## Copy this prompt into Claude Code:

```
Clone https://github.com/AntifragileTech/antifragile-claude-code.git to /tmp/ccpp with --depth 1.

Then install thinking skills:

1. For each directory in /tmp/ccpp/assets/skills/thinking/, copy it to ~/.claude/skills/
2. If the skill directory already exists in ~/.claude/skills/, SKIP it (never overwrite)
3. Report: how many installed, how many skipped, total skills now in ~/.claude/skills/

After copying, clean up: rm -rf /tmp/ccpp
```

## What's Included (115 skills)

**Reasoning Frameworks**: tree-of-thoughts, root-cause-tracing, cause-and-effect, kaizen, plan-do-check-act, proof, thought-based-reasoning, analyse, analyse-problem, propose-hypotheses

**Decision Making**: critique, debate, judge, judge-with-debate, do-and-judge, do-competitively, second-opinion, let-fate-decide, the-fool, consult

**Planning**: plan, writing-plans, executing-plans, create-plans, create-ideas, brainstorm, brainstorming, discover-tasks, search-first

**Agent Orchestration**: multi-agent-patterns, autonomous-loops, continuous-agent-loop, dispatching-parallel-agents, launch-sub-agent, subagent-driven-development, orchestrating-swarms, enterprise-agent-ops, agentic-engineering, ai-first-engineering, agent-evaluation, agent-harness-construction, agent-native-architecture, cost-aware-llm-pipeline

**Prompt Engineering**: prompt-engineer, prompt-engineering, create-meta-prompts, enhance-prompts, enhance-agent-prompts

**Skill/Tool Creation**: create-skill, create-agent, create-agent-skills, create-command, create-hook, create-hooks, create-mcp-servers, create-slash-commands, create-subagents, create-workflow-command, create-worktree, create-pr, skill-creator, skill-improver, skill-one, skill-stocktake, designing-workflow-skills

**Enhancement**: enhance-skills, enhance-hooks, enhance-plugins, enhance-docs, enhance-cross-file, enhance-orchestrator, enhance-claude-memory, apply-anthropic-skill-best-practices

**Meta/Workflow**: do-in-parallel, do-in-steps, iterative-retrieval, reflect, why, query, decay, memorize, learn, write-concisely, writing-skills, continuous-learning, continuous-learning-v2

**Session Management**: checkpoint, handoff, status, reset, notes, context-save, context-engineering, strategic-compact, configure-ecc, using-superpowers

**Verification**: validate-delivery, verification-before-completion, verification-loop, quick-fix, implement, actualize, feature-forge, spec-miner, spec-to-code-compliance, differential-review, audit-context-building, guidelines-advisor, ask-questions-if-underspecified
