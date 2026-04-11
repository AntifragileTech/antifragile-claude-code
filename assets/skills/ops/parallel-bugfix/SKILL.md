---
name: parallel-bugfix
description: Fix bugs using 3 parallel agents with different strategies, pick the winning approach
---

# Parallel Bug-Fix with Test Validation

## Usage
Invoke with: `/parallel-bugfix [bug description]`

## Workflow

1. **Analyze the bug** — identify the suspected root cause file(s) and symptoms
2. **Spawn 3 parallel sub-agents** using the Task tool, each in a worktree (`isolation: "worktree"`):

### Agent 1: Minimal Targeted Fix
- Fix only the suspected root cause with the smallest possible change
- Run build/lint after edit
- Report pass/fail + diff size

### Agent 2: Refactor to Eliminate Bug Class
- Refactor the surrounding code to make the bug class impossible
- Run build/lint after edit
- Report pass/fail + diff size

### Agent 3: Component Rewrite (if <200 lines)
- Rewrite the affected component from scratch
- If component is >200 lines, skip this agent and report "too large to rewrite"
- Run build/lint after edit
- Report pass/fail + diff size

3. **Compare results** from all 3 agents:
   - Pick the approach that passes all checks with the smallest diff
   - If none pass, synthesize the best elements into a final fix
4. **Apply the winning fix** to the main working tree
5. **Run final validation** — build + lint + any existing tests

## Rules
- Each agent gets MAX 200 lines of code changes
- Always run build verification before declaring success
- If all 3 fail, report findings and ask user for direction
