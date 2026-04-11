---
name: parallel-qa
description: Parallel cross-app QA - spawns 4 agents (api, web, storefront, marketing) for simultaneous testing
---

# Parallel Cross-App QA

Spawn 4 independent Task agents for simultaneous testing:

## Agent 1: API
- TypeScript compilation
- All route handlers return correct status codes
- Auth middleware on every endpoint
- Database queries checked for N+1 issues

## Agent 2: Web (Coach Dashboard)
- Every page route renders without errors
- All imports resolve
- Form submissions validated

## Agent 3: Storefront (Student)
- Checkout flow works end-to-end
- Currency formatting correct
- Responsive layouts validated
- API contract types match the API app

## Agent 4: Marketing
- All links resolve (no 404s)
- Meta tags present and correct
- Embed scripts validated

## Each agent must:
1. Attempt to fix any issues found
2. Re-run checks to verify fixes
3. Write results to a structured summary

## Final step
Merge findings into a single prioritized report (P0/P1/P2).
