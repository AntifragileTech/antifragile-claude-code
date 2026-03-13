# Production Health Check

Run a comprehensive health check on the production server:

1. SSH into server, check all Docker containers are running
2. Verify all public URLs return 200 (marketing, web, admin, API)
3. Check SSL cert expiry dates (warn if <30 days)
4. Query Postgres: check table row counts, recent errors (use sent_at for email_logs, started_at for incidents)
5. Check Redis connectivity and BullMQ queue status
6. Check disk usage, memory, CPU load
7. Check Docker image disk usage and reclaimable space
8. Summarize findings in a table with status icons

## CRITICAL RULES
- Run ALL checks from INSIDE containers using `docker exec`, NOT from localhost
- For database queries, ALWAYS check column names first with `\d table_name` before writing any SELECT queries
- Known schema gotchas: `email_logs` uses `sent_at` not `created_at`, `incidents` uses `started_at` not `created_at`
- Use actual public domains for URL checks, never localhost

## Check Sequence

### 1. Docker Containers
- Run `docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'`
- Flag any container not "Up" or with restart loops

### 2. Public URL Verification
- Hit every public-facing endpoint (marketing site, web app, admin, API /health)
- Verify HTTP 200 status codes
- Note response times for any slow endpoints (>2s)

### 3. SSL Certificates
- Check certificate expiry for all domains:
  `echo | openssl s_client -servername DOMAIN -connect DOMAIN:443 2>/dev/null | openssl x509 -noout -enddate`
- Flag any certificates expiring within 30 days

### 4. Database (Postgres)
- Connect via `docker exec`
- Check table schemas FIRST with `\d table_name` before any data queries
- Verify recent activity on key tables (users, email_logs, incidents, domains)

### 5. Redis & BullMQ
- Verify Redis connectivity via `docker exec` with `redis-cli ping`
- Check queue depths (pending, active, failed jobs)
- Flag any queues with >0 failed jobs

### 6. Disk & Resources
- Docker disk usage: `docker system df`
- System disk: `df -h`
- Memory and load averages
- If Docker reclaimable space exceeds 5GB, suggest `docker system prune -f`

### 7. Recent Error Logs
- Check last 50 lines of each API/worker container logs
- Flag any repeated errors or stack traces

## Output Format
Summarize all findings in a table with status indicators:
- PASS
- WARNING (needs attention soon)
- FAIL (needs immediate action)

End with a health score out of 100 and prioritized action items.
