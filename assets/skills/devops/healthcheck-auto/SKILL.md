# Self-Healing Production Health Check

Run a comprehensive production health check with auto-remediation for known issues.

## Check Sequence (execute via SSH)

### 1. Container Health
```
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```
- Flag any container not "Up" or with restart loops

### 2. Public URL Verification
Check all return HTTP 200: marketing site, web app, admin panel, API `/health`

### 3. Database Verification
```
SELECT schemaname, tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename;
```
- Verify core tables exist
- Check column names with `\d tablename` before any data queries

### 4. Redis
```
redis-cli ping
```

### 5. SSL Certificates
```
echo | openssl s_client -servername DOMAIN -connect DOMAIN:443 2>/dev/null | openssl x509 -noout -enddate
```
- Check all domains, flag any expiring within 30 days

### 6. Disk Usage
- System: `df -h`
- Docker: `docker system df`

### 7. BullMQ Queues
- Check for failed jobs, stuck/stalled jobs

## Auto-Remediation Rules

- If Docker reclaimable space exceeds 5GB: run `docker system prune -f`
- If a container has restarted >3 times: log the last 50 lines of its logs
- If a queue has failed jobs: report the error messages

## Output Format

Categorize every finding as **CRITICAL**, **WARNING**, or **INFO** with a proposed fix command.

Generate a final health score out of 100 and a prioritized action items list.
