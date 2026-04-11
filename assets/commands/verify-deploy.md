---
description: "Self-healing deployment verification for monorepo. Runs pre-deploy checks, validates post-deploy health, and reports pass/fail with fix recommendations."
allowed-tools: Bash, Read, Glob, Grep, TodoWrite
---

You are a deployment verification agent for a multi-app monorepo (api, web, storefront, marketing).

Run all checks below in two phases. Report each check as ✅ PASS or ❌ FAIL with a one-line fix recommendation for any failure.

---

## Phase 1: Pre-Deploy Checks

### 1. TypeScript — All Apps
Run `npx tsc --noEmit` in each app directory that has a `tsconfig.json`. Collect all errors.

```bash
for app in apps/api apps/web apps/storefront apps/marketing; do
  if [ -f "$app/tsconfig.json" ]; then
    echo "=== $app ===" && cd "$app" && npx tsc --noEmit 2>&1 | tail -5; cd -
  fi
done
```

Report: app name | error count | first error (if any)

### 2. Environment Variables
For each app, find the env validation schema or `.env.example` file. Compare against actual `.env` (or the running environment). Flag any keys present in `.env.example` but missing from `.env`.

```bash
for app in apps/api apps/web apps/storefront apps/marketing; do
  [ -f "$app/.env.example" ] && echo "=== $app ===" && \
  comm -23 <(grep -oP '^[A-Z_]+(?==)' "$app/.env.example" | sort) \
           <(grep -oP '^[A-Z_]+(?==)' "$app/.env" 2>/dev/null | sort)
done
```

### 3. Docker Volume Permissions
Check that any mounted volumes used by the app are owned by the correct user (`nodeuser`, uid 1001 typically). Look at `docker-compose.yml` for volume mounts, then verify host directory ownership.

```bash
grep -A2 'volumes:' docker-compose.yml 2>/dev/null | grep '\./\|/var\|/data' | \
  awk '{print $NF}' | cut -d: -f1 | while read dir; do
    [ -d "$dir" ] && echo "$dir: $(stat -c '%U:%G %a' "$dir" 2>/dev/null || stat -f '%Su:%Sg %p' "$dir")"
  done
```

Fix recommendation if wrong owner: `sudo chown -R 1001:1001 <volume-path>` before running `docker compose up`.

### 4. SendGrid Sender Verification
Grep for the FROM address used in email sending code across all apps. Warn if any address differs from the project's verified sender (check for `SENDGRID_FROM_EMAIL` or `FROM_EMAIL` env var, or hardcoded addresses in email service files).

```bash
grep -r "from.*@\|FROM_EMAIL\|SENDGRID_FROM" apps/ --include="*.ts" --include="*.js" --include="*.env*" -l
```

Read each flagged file and extract the sender address. Flag mismatches.

### 5. CORS Origins
Find the CORS configuration in the API app. Extract allowed origins. Verify they include all frontend domains (web, storefront, marketing) — both production URLs and any staging URLs. Flag missing origins.

---

## Phase 2: Post-Deploy Checks

Run these AFTER deployment completes. Use the production domain (not localhost). Read the project's `.env` or `docker-compose.yml` to find the actual domain.

### 5. API Health Endpoints
Hit every health/status endpoint:
```bash
curl -sf https://<API_DOMAIN>/health && echo "✅ /health" || echo "❌ /health"
curl -sf https://<API_DOMAIN>/api/status && echo "✅ /api/status" || echo "❌ /api/status"
```

### 6. CORS Headers
Simulate a cross-origin request from each frontend origin:
```bash
for origin in <WEB_DOMAIN> <STOREFRONT_DOMAIN> <MARKETING_DOMAIN>; do
  result=$(curl -sI -H "Origin: https://$origin" -H "Access-Control-Request-Method: GET" \
    -X OPTIONS https://<API_DOMAIN>/api/health 2>&1 | grep -i "access-control-allow-origin")
  echo "$origin → $result"
done
```

Flag any origin that does not get `Access-Control-Allow-Origin` back.

### 7. Embed Widget Frame Check
If the project has embeddable widgets, verify they are NOT blocked by X-Frame-Options:
```bash
curl -sI https://<API_DOMAIN>/embed 2>&1 | grep -i "x-frame-options\|content-security-policy" || echo "✅ No frame blocking headers"
```

### 8. Auth Flow (Smoke Test)
Verify the auth endpoints respond (not 404/500):
```bash
curl -sf -o /dev/null -w "%{http_code}" -X POST https://<API_DOMAIN>/api/auth/login \
  -H "Content-Type: application/json" -d '{"email":"smoke@test.invalid","password":"x"}' \
  | grep -qE "^(400|401|422)" && echo "✅ Login endpoint responds" || echo "❌ Login endpoint unexpected response"
```

---

## Output Format

Print a summary table:

```
## Pre-Deploy Results
| Check | Status | Notes |
|-------|--------|-------|
| TypeScript — api | ✅ PASS | 0 errors |
| TypeScript — web | ❌ FAIL | 3 errors — run /fix-ts |
| Env vars — api | ✅ PASS | All vars present |
| Docker permissions | ⚠️ WARN | ./data owned by root — fix before deploy |
| SendGrid sender | ✅ PASS | monitor@yourdomain.com verified |
| CORS config | ❌ FAIL | Missing: storefront.example.com |

## Post-Deploy Results
| Check | Status | Notes |
|-------|--------|-------|
| /health | ✅ PASS | 200 OK |
| CORS — web | ✅ PASS | Header present |
| CORS — storefront | ❌ FAIL | No Access-Control-Allow-Origin |
| Embed frame | ✅ PASS | No blocking headers |
| Auth endpoint | ✅ PASS | Returns 401 as expected |
```

**If ANY pre-deploy check fails: DO NOT DEPLOY. Fix the issue first.**

List all failures with specific file paths and fix commands so the user can resolve them without investigation.
