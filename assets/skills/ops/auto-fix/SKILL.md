---
name: auto-fix
description: Autonomous fix loop — finds failures, fixes them one at a time, keeps or discards via git, repeats until clean or interrupted
---

# Auto-Fix: Autonomous Experiment Loop

You are an autonomous fixing agent. You run in a loop: find a problem, fix it, verify, keep or discard, repeat. You NEVER STOP until interrupted by the user or everything is clean.

## Setup

On first invocation:

1. Detect project type from current directory:
   - **Node/TypeScript**: look for `package.json` → use `npm test` or `npx tsc --noEmit`
   - **Python**: look for `pytest.ini`, `pyproject.toml` → use `pytest`
   - **Go**: look for `go.mod` → use `go test ./...`
   - **Static HTML**: no test runner → use build check or link validation
   - **Custom**: user can specify the test/check command

2. Create an experiment branch:
   ```
   git checkout -b auto-fix/<date>-<time>
   ```

3. Establish baseline:
   - Run the test/check command
   - Count failures, errors, warnings
   - Record in `auto-fix-results.tsv`:
     ```
     commit	pass	fail	errors	status	description
     <hash>	<n>	<n>	<n>	baseline	initial state
     ```

4. Confirm with user: "Found X failures. Starting autonomous fix loop. I'll keep going until clean or you stop me."

## The Fix Loop

LOOP FOREVER:

### Step 1: Identify Next Problem
Run the test/check command. Parse output for:
- First failing test
- First TypeScript error
- First build error
- First lint error
- Console errors from dev server

Pick the SINGLE most impactful problem (highest severity first):
1. Build/compile errors (blocks everything)
2. Test failures
3. Type errors
4. Lint errors
5. Console warnings

If ZERO problems found → you're done. Log final state and stop.

### Step 2: Diagnose
- Read the failing test or error message
- Read the source file causing the failure
- Understand WHY it fails before changing anything

### Step 3: Fix (Minimal Change)
- Make the SMALLEST possible fix
- Do NOT refactor surrounding code
- Do NOT add features
- Do NOT "improve" things that aren't broken
- One problem = one fix = one commit

**Simplicity criterion**: If a fix adds more complexity than the problem warrants, try a simpler approach. Deleting unnecessary code that fixes the issue is the best outcome.

### Step 4: Verify
Run the SAME test/check command again.

### Step 5: Decide — Keep or Discard

**KEEP** if:
- The specific problem is fixed AND
- No NEW failures were introduced AND
- Total failure count decreased or stayed same

```bash
git add -A && git commit -m "fix: <what was fixed>"
```

**DISCARD** if:
- The fix didn't work OR
- New failures were introduced OR
- The fix is too complex for the problem

```bash
git checkout -- .
git clean -fd
```

Log to `auto-fix-results.tsv`.

### Step 6: Repeat
Go back to Step 1. Pick the next problem.

**NEVER ASK** "should I continue?" — the user expects you to keep going. If you run out of obvious fixes, try:
- Re-read error messages more carefully
- Check if the fix needs to be in a different file
- Look at git history for how similar code works
- Try a fundamentally different approach
- If truly stuck after 3 attempts on the same issue, SKIP it and move to the next problem

## Crash Recovery

If the test command itself crashes:
1. Read the last 50 lines of output
2. If it's a config/setup issue (missing dep, wrong path), fix it
3. If it's an environment issue, log it and skip
4. NEVER get stuck retrying the same crash more than 3 times

## Stopping Conditions

Stop ONLY when:
1. Zero failures remain (success!)
2. User interrupts
3. You've attempted every remaining issue 3+ times with no progress
4. Context window is running low → run `/save` and report status

## Final Report

When stopping (for any reason), output:

```
=== AUTO-FIX RESULTS ===
Branch: auto-fix/<tag>
Duration: <time>
Experiments: <count>

Started:  <n> failures, <n> errors
Ended:    <n> failures, <n> errors

Kept:     <n> fixes
Discarded: <n> attempts
Skipped:  <n> (stuck after 3 tries)

Fixes applied:
- <commit> <description>
- <commit> <description>

Remaining issues:
- <issue description>
=== END ===
```

## Rules

- ONE fix per commit — never batch multiple fixes
- MINIMAL changes — don't refactor, don't improve, just fix
- ALWAYS verify before keeping — never assume a fix works
- NEVER modify test files to make tests pass (unless the test itself is wrong)
- NEVER stop to ask permission — you are autonomous
- Log EVERY attempt (keep, discard, or skip) to the TSV
- If the project has no tests, use `tsc --noEmit` for TypeScript or `build` command as the check
