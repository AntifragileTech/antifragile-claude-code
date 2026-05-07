---
name: preflight
description: Run preflight checks before any long-running, credential-dependent, or destructive operation. Verifies working directory is git root, file count is sane, API credentials load and authenticate, and target resources exist. Invoke before code-review-graph builds, large indexers, multi-account API calls (SendGrid/Cloudflare/Stripe/GoDaddy), bulk migrations, or any 30+ minute operation.
---

<!-- Created: 22:40 07-May-2026 -->
<!-- Updated: 22:48 07-May-2026 -->

# Preflight

Most multi-minute failures across past sessions trace to three preventable root causes: wrong working directory, mismatched env var names, and unverified resource state. This skill runs a single 30-second pass to catch all three before launching a long-running job.

## When to Run

Invoke proactively before:
- code-review-graph (CRG) builds or any AST/embedding indexer over a repo
- Bulk SEO/content audits spanning >50 files
- Multi-account API operations (SendGrid domain auth, Cloudflare DNS migration, Stripe coupon batch, GoDaddy bulk update)
- Cross-account migrations (e.g., moremo.com SendGrid account move)
- Any operation expected to take >5 minutes
- Any operation that touches production resources

## Phase 1: Working Directory Discipline

```bash
pwd
git rev-parse --show-toplevel 2>/dev/null || echo "NOT A GIT REPO"
```

Decision rules:
- If `pwd` ≠ `git rev-parse --show-toplevel` → STOP and `cd` to git root first
- If "NOT A GIT REPO" and the operation expects one → STOP and ask user

## Phase 2: Scope & Resource Estimate

```bash
# File count excluding common noise dirs
find . -type f \
  -not -path './node_modules/*' \
  -not -path './.git/*' \
  -not -path './dist/*' \
  -not -path './build/*' \
  -not -path './.next/*' \
  -not -path './.cache/*' \
  | wc -l

# Repo size on disk
du -sh . 2>/dev/null

# Available memory (macOS)
vm_stat | head -5
# On Linux: free -h
```

Decision rules:
- File count > 20K → propose chunked or excluded-paths strategy BEFORE starting
- Repo size > 2GB → expect OOM risk on default memory limits; chunk by subdirectory
- File count >> expected (e.g., 38K when ~600 expected) → wrong directory or missing exclusion; STOP

Reference precedent: 25-project CRG batch had OOM kills on a 4.2GB project and an 11GB project (exit 137); the 11GB project also wrong-dir-scanned 38K node_modules files before kill.

## Phase 3: Credential Preflight (for API-driven ops)

For each provider in scope, verify env var name AND that the key authenticates:

```bash
# Pattern: check env var names match the canonical naming
# Canonical names (from CLAUDE.md):
#   - GODADDY_API_KEY_1, GODADDY_API_KEY_2 (NOT GD_API_KEY_*)
#   - SENDGRID_API_KEY_1, SENDGRID_API_KEY_2, SENDGRID_API_KEY_3 (NOT SG_*)
#   - CLOUDFLARE_API_TOKEN_1, CLOUDFLARE_API_TOKEN_2
#   - STRIPE_SECRET_KEY (or STRIPE_SECRET_KEY_<account> for multi-account)

# 1. Confirm the var is loaded
env | grep -E "^(GODADDY|SENDGRID|CLOUDFLARE|STRIPE)_" | sed 's/=.*/=<set>/'

# 2. Authenticate (don't just check the var exists — verify the key actually works)
# SendGrid:
curl -sS -o /dev/null -w "%{http_code}\n" \
  -H "Authorization: Bearer $SENDGRID_API_KEY_1" \
  https://api.sendgrid.com/v3/user/account

# Cloudflare:
curl -sS -o /dev/null -w "%{http_code}\n" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN_1" \
  https://api.cloudflare.com/client/v4/user/tokens/verify

# Stripe:
curl -sS -o /dev/null -w "%{http_code}\n" \
  -u "$STRIPE_SECRET_KEY:" \
  https://api.stripe.com/v1/balance

# GoDaddy:
curl -sS -o /dev/null -w "%{http_code}\n" \
  -H "Authorization: sso-key $GODADDY_API_KEY_1:$GODADDY_API_SECRET_1" \
  https://api.godaddy.com/v1/domains
```

Decision rules:
- HTTP status ≠ 200 → STOP. Do NOT retry blindly. Check env var naming in CLAUDE.md, confirm which numbered account (1/2/3) owns the resource, and ask user before proceeding
- Var not in `env` output → name mismatch. Check `.env` file directly, do not guess
- Multi-account ops: verify the SPECIFIC numbered account that owns the target resource — not just any working key

Reference precedents (do not repeat):
- `GD_API_KEY_1` used instead of `GODADDY_API_KEY_1` → silent failures, falsely reported expired hidemo.site as "found"
- Cloudflare Account 2 credentials missing from `.env` → blocked moremo.com investigation
- SendGrid key momentarily confused with Stripe key → wasted retries

## Phase 4: Target Resource Verification

Before claiming a resource exists or is actionable, verify state explicitly:

- **Domain**: check WHOIS expiry, DNS resolution, AND ownership in the API account you'll use
- **User/Customer**: check `deleted_at`, `status`, and active flags — not just "returns 200"
- **Brand/Project ID**: confirm the ID is current — stale IDs cause `resource_missing` (BigMailer brand ID precedent)
- **URL referenced in output**: `curl -I` it. Non-existent `demo.*` subdomains have been referenced in past output and did not resolve

## Phase 5: Report

Output a one-screen summary BEFORE proceeding:

```
PREFLIGHT REPORT
================
Working directory: /path/to/git/root  ✓ (matches git toplevel)
File count: 1,247 (excluding node_modules) — within budget
Repo size: 340 MB — OK
Memory available: 18 GB — OK
Credentials verified:
  - SENDGRID_API_KEY_1 → 200 (account: contact@yourdomain.com)
  - CLOUDFLARE_API_TOKEN_1 → 200 (zones: 6)
Target resources verified:
  - moremo.com → exists, expires 2027-03-15, in Cloudflare Account 1
  - SendGrid sender monitor@yourdomain.com → verified

GO / NO-GO: GO
```

If any check fails, output `NO-GO: <specific reason>` and stop. Do not proceed without user approval.

## Anti-patterns

- DO NOT skip phases to "save time" — the 30-second preflight prevents 5-30 minute kill/restart cycles
- DO NOT assume credentials work because they worked last session — keys rotate
- DO NOT proceed with "I'll fix it if it fails" — silent auth failures eat real time before being noticed
- DO NOT run preflight inside a loop or hook on every command — it is a session-start / pre-operation check, not a per-call wrapper
