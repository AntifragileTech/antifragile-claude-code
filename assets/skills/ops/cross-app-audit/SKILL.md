---
name: cross-app-audit
description: Systematic cross-app monorepo audit across all apps with prioritized findings
---

# Cross-App Monorepo Audit

## For each app (api, web, storefront, marketing):
1. Run `tsc --noEmit` — report any type errors
2. Check all routes for 404s and broken links
3. Verify environment variables are properly validated
4. Check for security issues: exposed secrets, missing auth guards, CORS config
5. Verify Docker/deployment configs are consistent
6. Check for contract mismatches between API and frontend types

## Workflow
1. **Before fixing any bug**: grep across ALL apps for the same pattern first
2. **Batch related fixes**: fix all instances together in one pass
3. **Verify each app**: run `tsc --noEmit` on each app before declaring done
4. Use Task agents to parallelize per-app work when possible

## Output
Create a structured report with findings categorized as:
- **P0**: Security issues, broken auth, data loss risks
- **P1**: Type errors, broken routes, contract mismatches
- **P2**: Missing validation, inconsistent configs, code quality
