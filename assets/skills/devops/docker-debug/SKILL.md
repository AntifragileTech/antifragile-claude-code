# /docker-debug — Docker Compose Debugging Skill

## Trigger
User says: "docker-debug", "container issue", "docker logs", "service down", "container networking", "docker health"

## Purpose
Debug Docker Compose production deployments systematically.

## Steps

### 1. Status Overview
```bash
docker compose ps -a                    # All containers with status
docker compose ps --format json | jq .  # Structured output
docker stats --no-stream                # CPU/memory snapshot
```

### 2. Log Investigation
```bash
docker compose logs --tail=50 SERVICE_NAME          # Recent logs
docker compose logs --tail=100 --since=5m SERVICE   # Last 5 minutes
docker compose logs SERVICE_NAME 2>&1 | grep -i "error\|fatal\|exception" | tail -20
```

### 3. Container Health Checks
- ALWAYS use `docker exec` for health checks from INSIDE containers — NOT localhost
- For inter-service checks: `docker exec CONTAINER curl -s http://SERVICE_NAME:PORT/health`
- For public URL checks: use the actual domain, not localhost
```bash
docker exec CONTAINER_NAME curl -sf http://localhost:PORT/health
docker inspect --format='{{.State.Health.Status}}' CONTAINER_NAME
```

### 4. Networking Debug
- Think container-to-container networking FIRST, not localhost
```bash
docker network ls
docker network inspect NETWORK_NAME
docker exec CONTAINER ping -c 2 OTHER_SERVICE    # Inter-container connectivity
docker exec CONTAINER nslookup OTHER_SERVICE      # DNS resolution
docker compose exec SERVICE_NAME netstat -tlnp    # Open ports inside container
```

### 5. Resource Issues
```bash
docker system df                        # Disk usage
docker system prune --dry-run           # What would be cleaned
docker volume ls                        # Check volumes
docker exec CONTAINER df -h             # Disk inside container
```

### 6. Restart & Recovery
```bash
docker compose restart SERVICE_NAME     # Soft restart
docker compose up -d --force-recreate SERVICE_NAME  # Hard restart
docker compose down && docker compose up -d         # Full restart
```

## Rules
- Do NOT use `version:` key in docker-compose.yml (deprecated)
- Do NOT run `docker system prune` without user confirmation
- Do NOT run `docker compose down -v` (destroys volumes) without explicit approval
- Always check logs BEFORE restarting — restarts destroy log context
- For database containers, NEVER force-remove without checking data volumes
