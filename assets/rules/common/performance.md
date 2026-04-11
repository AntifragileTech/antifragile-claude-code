# Performance Optimization

## Model Selection Strategy

**Haiku 4.5** (90% of Sonnet capability, 3x cost savings):
- Lightweight agents with frequent invocation
- Pair programming and code generation
- Worker agents in multi-agent systems

**Sonnet 4.6** (Best coding model):
- Main development work
- Orchestrating multi-agent workflows
- Complex coding tasks

**Opus 4.5** (Deepest reasoning):
- Complex architectural decisions
- Maximum reasoning requirements
- Research and analysis tasks

## Context Window Management

Avoid last 20% of context window for:
- Large-scale refactoring
- Feature implementation spanning multiple files
- Debugging complex interactions

Lower context sensitivity tasks:
- Single-file edits
- Independent utility creation
- Documentation updates
- Simple bug fixes

## Extended Thinking + Plan Mode

Extended thinking is enabled by default, reserving up to 31,999 tokens for internal reasoning.

Control extended thinking via:
- **Toggle**: Option+T (macOS) / Alt+T (Windows/Linux)
- **Config**: Set `alwaysThinkingEnabled` in `~/.claude/settings.json`
- **Budget cap**: `export MAX_THINKING_TOKENS=10000`
- **Verbose mode**: Ctrl+O to see thinking output

For complex tasks requiring deep reasoning:
1. Ensure extended thinking is enabled (on by default)
2. Enable **Plan Mode** for structured approach
3. Use multiple critique rounds for thorough analysis
4. Use split role sub-agents for diverse perspectives

## Token Cost Reduction

### Session Hygiene
- `/clear` between unrelated tasks — stale context is re-sent every message
- `/context` to audit what's consuming context (MCP tools, files, history)
- `/rename` before clearing so sessions are findable via `/resume`
- Disable unused MCP servers via `/mcp` — tool definitions add to context
- Prefer CLI tools (`gh`, `aws`, `docker`) over MCP when available

### Prompt Efficiency
- Specific prompts: include file paths, line numbers, function names
- Give verification targets so Claude self-verifies (tests, expected output)
- Use plan mode (Shift+Tab) before complex implementation to avoid re-work
- Course-correct early: Escape to stop, `/rewind` to restore checkpoint

### Delegation
- Delegate verbose ops (tests, logs, docs) to subagents — summary returns, not full output
- Use hooks to preprocess/filter data before Claude sees it
- Use Python/shell scripts for bulk operations — zero AI context cost

### Thinking Budget
- Default: 31,999 tokens per request (expensive)
- Simple tasks: `export MAX_THINKING_TOKENS=8000` or `/effort` to lower
- Toggle: Option+T (macOS) / Alt+T (Windows/Linux)
- Full budget only for: architecture, complex debugging, multi-file refactors

## Build Troubleshooting

If build fails:
1. Use **build-error-resolver** agent
2. Analyze error messages
3. Fix incrementally
4. Verify after each fix
