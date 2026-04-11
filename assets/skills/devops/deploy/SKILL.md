# Deploy to Production

Standardized deployment and verification workflow.

## Pre-Deploy

### 1. Build Verification
Run builds for ALL three apps using the correct turbo filter names:
```bash
npx turbo build --filter=@your-org/marketing
npx turbo build --filter=@your-org/web
npx turbo build --filter=@your-org/admin
```
- If ANY build fails, fix it before proceeding. Do NOT deploy with broken builds.
- Check `package.json` for exact package names if unsure about filter names.

### 2. Identify ALL Affected Apps
- Run `git diff --name-only HEAD` to list changed files
- Map files to apps: `apps/api/`, `apps/web/`, `apps/storefront/`, `apps/marketing/`
- **List every app that has changes — NEVER assume only one app is affected**
- Show the full list to the user and wait for explicit confirmation before deploying

### 3. Pre-Deploy Checks
- Verify no uncommitted changes that should be included
- Check that docker-compose.yml does NOT use `version:` key (deprecated, causes warnings)
- Verify CORS origins in API config match ALL frontend domains
- Confirm Docker volume permissions use host-level ops (not `docker exec` after start)
- Confirm SendGrid sender matches verified address in project config (`check project config`)
- Verify environment variables are up to date

## Deploy

### 4. Execute Deployment
- Run the deploy script
- Monitor output for any errors or warnings
- If deployment fails, check Docker logs immediately

## Post-Deploy Verification

### 5. Container Health
- Run `docker ps` to verify all containers are up and healthy
- Check container restart counts (should be 0 for new deploy)

### 6. URL Verification
- Check all public URLs return HTTP 200
- Use actual domain names, NOT localhost
- Verify marketing site, web app, admin panel, and API endpoints

### 7. SSL Verification
- Verify SSL certificates are valid for all domains

### 8. Quick Functional Check
- Verify health check endpoint responds correctly
- Check that health checks run from INSIDE containers, not localhost
- Verify database connectivity via container exec

## Output
Report deployment status:
- Build status per app
- Container status
- URL verification results
- Any warnings or issues found

Flag anything that needs immediate attention.
