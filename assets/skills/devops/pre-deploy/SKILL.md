# Pre-Deploy Validation

Run a mandatory consistency check before deployment. Do NOT suggest deploying until all checks pass.

## Checks

### 1. TypeScript Compilation
```bash
npx tsc --noEmit
```
Fix all errors before proceeding.

### 2. Field Name Consistency
- Grep the codebase for all new/changed field names
- Verify they match across: Prisma schema, API routes, frontend interfaces, and components
- Flag any mismatches (e.g., `whatsappConnected` vs `isWhatsappConnected`)

### 3. Regex Pattern Collision Check
- For any new/changed regex patterns, test against ALL existing patterns
- Specifically check for keyword collisions (e.g., SIGNUP keyword matching inside other patterns)
- Write a quick test script if needed

### 4. Variable Scoping
- For any refactored functions, verify variables aren't lost between scope boundaries
- Check that extracted utility functions receive all needed parameters

### 5. Auth Flow Verification
- If auth-related files changed, trace the full signup AND login paths
- Verify country code handling, phone format normalization, and token flow

### 6. Environment Path Check
- Confirm Prisma schema path matches deployment environment (local vs container)
- Verify database connection strings and container names
- Check environment variables are set correctly

### 7. WhatsApp-Specific Checks (if applicable)
- Verify LID vs phone number handling in all comparison logic
- Ensure no flows ask users for information available from WhatsApp API metadata
- Check pushName extraction works across function boundaries

## Output
Present a checklist with PASS/FAIL per item. Only provide deploy commands after ALL checks pass.
