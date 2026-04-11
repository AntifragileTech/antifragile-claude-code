---
name: self-healing-observer
description: Pre-flight auth check for observer/memory agents with local fallback
---

# Self-Healing Observer Pipeline

## Usage
Invoke with: `/self-healing-observer` before launching any observer or memory agent session.

## Pre-Flight Check

1. **Test OAuth token** — make a minimal API call to verify authentication
2. **If 401 or auth error**:
   - Attempt token refresh using stored refresh token
   - If refresh succeeds: proceed normally, log "AUTH: refreshed"
   - If refresh fails: switch to local mode
3. **Surface auth status** in the first line of output:
   - `AUTH: valid` — proceeding with API-based observation
   - `AUTH: refreshed` — token was stale, refreshed successfully
   - `AUTH: local-only` — API unavailable, using file-based logging

## Local Fallback Mode

When API auth is unavailable:
- Write all observations to `~/.claude/logs/observations/session-{timestamp}.md`
- Use standard frontmatter format:
  ```
  ---
  session: {timestamp}
  mode: local-only
  directory: {pwd}
  ---
  ```
- Log key decisions, file changes, and context for next session
- Do NOT retry API calls — they will all fail

## Rules
- NEVER proceed with observer agents if auth check fails AND local fallback is not set up
- NEVER retry failed auth calls more than once
- Always tell the user which mode is active
- Local observations can be bulk-uploaded to API later when auth is restored
