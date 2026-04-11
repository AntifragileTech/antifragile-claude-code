---
name: staged-deploy
description: Autonomous staged deployment pipeline with smoke tests and auto-rollback
---

# Staged Deployment Pipeline

## Phase 1: Pre-Deploy
- Run verification checklist against current production as baseline
- Check Docker volume permissions (nodeuser ownership, not root)
- Validate all environment variables and API keys
- Verify SendGrid sender identity matches config

## Phase 2: Deploy to Staging
Run deploy script, then spawn parallel smoke-test agents:
- **Agent A**: Auth flows (login, OTP, magic links, SSO)
- **Agent B**: Storefront (checkout, cart, course pages)
- **Agent C**: API endpoints (CORS headers, X-Frame-Options, route health)
- **Agent D**: Embed widgets and WhatsApp bot responses

## Phase 3: Decision
- If any agent reports failures: diagnose root cause, attempt fix, re-test
- After 3 failed fix attempts on any issue: halt and produce incident report
- Never deploy to production with known failures

## Phase 4: Production
- Deploy to production
- Re-run all smoke tests
- Generate complete handoff document with changelog, test results, rollback instructions
- Save to persistent memory files
- Do not override existing docs — only improve and update
