---
name: infra-healthcheck
description: Pre-session infrastructure health check - tokens, services, Docker, env vars
---

# Infrastructure Health Check

Run before any work begins:

1. **OAuth tokens**: Verify all tokens are valid, refresh any expiring within 2 hours
2. **External services**: Test connectivity to SendGrid, database, Docker, CDN
3. **Agent endpoints**: Confirm memory agent and observer agent respond
4. **Docker state**: Check container status and volume permissions (nodeuser ownership)
5. **Environment variables**: Validate across all apps in the monorepo

## On failure
- Refresh expired tokens automatically
- Restart stopped services
- Fix permissions (host-level, before container start)
- Only proceed to primary work when all systems are green

## Output
One-line status for each check:
```
OAuth: OK (refreshed 1 token)
SendGrid: OK
Database: OK
Docker: OK (3/3 containers running)
Env vars: OK (all apps validated)
```
