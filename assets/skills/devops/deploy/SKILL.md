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

### 2. Pre-Deploy Checks
- Verify no uncommitted changes that should be included
- Check that docker-compose.yml does NOT use `version:` key (deprecated, causes warnings)
- Verify environment variables are up to date

## Deploy

### 3. Execute Deployment
- Run the deploy script
- Monitor output for any errors or warnings
- If deployment fails, check Docker logs immediately

## Post-Deploy Verification

### 4. Container Health
- Run `docker ps` to verify all containers are up and healthy
- Check container restart counts (should be 0 for new deploy)

### 5. URL Verification
- Check all public URLs return HTTP 200
- Use actual domain names, NOT localhost
- Verify marketing site, web app, admin panel, and API endpoints

### 6. SSL Verification
- Verify SSL certificates are valid for all domains

### 7. Quick Functional Check
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
