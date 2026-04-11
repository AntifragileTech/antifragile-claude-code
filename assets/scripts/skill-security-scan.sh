#!/usr/bin/env bash
# Skill Security Scanner — runs automatically via PostToolUse hook
# Scans newly written/edited skill files for security vulnerabilities
set -euo pipefail

FILE_PATH="$1"

# Only scan files inside ~/.claude/skills/
case "$FILE_PATH" in
  */.claude/skills/*.md) ;;
  *) exit 0 ;;
esac

ISSUES=()

# 1. Curl-pipe-bash (Remote Code Execution)
if grep -qE 'curl\s.*\|\s*(sudo\s+)?(ba)?sh' "$FILE_PATH" 2>/dev/null; then
  if ! grep -qE '# ⚠️|❌|NEVER|dangerous|Download and inspect' "$FILE_PATH" 2>/dev/null; then
    ISSUES+=("CRITICAL: curl-pipe-bash pattern found — use download-then-inspect instead")
  fi
fi

# 2. Hardcoded secrets / realistic key prefixes
if grep -qE '=sk-[a-z]{2,4}-\.\.\.|=sk-\.\.\.|PASSWORD=(postgres|password|admin|root|changeme|YourStrong)' "$FILE_PATH" 2>/dev/null; then
  ISSUES+=("HIGH: Hardcoded or weak placeholder secrets — use <YOUR_API_KEY> format")
fi

# 3. SQL injection in example code
if grep -qE 'f"(SELECT|INSERT|UPDATE|DELETE).*\{' "$FILE_PATH" 2>/dev/null; then
  if ! grep -qE '❌|BAD|sanitize|allowlist|parameterized' "$FILE_PATH" 2>/dev/null; then
    ISSUES+=("HIGH: SQL injection pattern in example code — use parameterized queries")
  fi
fi

# 4. --break-system-packages
if grep -qE '\-\-break-system-packages' "$FILE_PATH" 2>/dev/null; then
  ISSUES+=("HIGH: --break-system-packages flag — use a virtual environment instead")
fi

# 5. innerHTML without sanitization warning
if grep -qE '\.innerHTML\s*=' "$FILE_PATH" 2>/dev/null; then
  if ! grep -qE 'DOMPurify|sanitize|⚠️|textContent' "$FILE_PATH" 2>/dev/null; then
    ISSUES+=("MEDIUM: innerHTML usage without sanitization warning — add DOMPurify note")
  fi
fi

# 6. Wildcard CORS without warning
if grep -qE 'Access-Control-Allow-Origin.*\*' "$FILE_PATH" 2>/dev/null; then
  if ! grep -qE '❌|NEVER|avoid|⚠️|never.*production' "$FILE_PATH" 2>/dev/null; then
    ISSUES+=("MEDIUM: Wildcard CORS (Access-Control-Allow-Origin: *) without warning")
  fi
fi

# 7. sudo without warning
if grep -qE '(^|\s)sudo\s' "$FILE_PATH" 2>/dev/null; then
  if ! grep -qE '⚠️|caution|warning|careful' "$FILE_PATH" 2>/dev/null; then
    ISSUES+=("LOW: sudo usage without security warning")
  fi
fi

# 8. chmod 777 / world-writable
if grep -qE 'chmod\s+777|0777' "$FILE_PATH" 2>/dev/null; then
  if ! grep -qE '❌|WRONG|never|avoid' "$FILE_PATH" 2>/dev/null; then
    ISSUES+=("MEDIUM: World-writable permissions (chmod 777)")
  fi
fi

# Output results
if [ ${#ISSUES[@]} -gt 0 ]; then
  echo "⚠️ SKILL SECURITY SCAN — $(basename "$(dirname "$FILE_PATH")")/$(basename "$FILE_PATH")"
  echo "Found ${#ISSUES[@]} issue(s):"
  for issue in "${ISSUES[@]}"; do
    echo "  • $issue"
  done
  echo ""
  echo "Fix these before the skill is considered safe."
fi
