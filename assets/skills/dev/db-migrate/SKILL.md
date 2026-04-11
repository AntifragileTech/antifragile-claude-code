# /db-migrate — Prisma Database Migration Skill

## Trigger
User says: "db-migrate", "run migration", "update schema", "prisma migrate", "add column", "change table"

## Purpose
Safely run Prisma database migrations with schema verification before and after.

## Steps

### 1. Pre-flight Check
- Run `npx prisma db pull --print` to see current live schema
- Run `npx prisma migrate status` to check pending migrations
- If there are pending migrations, warn the user before proceeding

### 2. Schema Verification (CRITICAL)
- Before writing ANY query, run `\d table_name` or `npx prisma db execute --stdin <<< "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'TARGET_TABLE';"` to verify actual column names
- NEVER assume column names. Known gotchas in this codebase:
  - `email_logs` uses `sent_at` NOT `created_at`
  - `incidents` uses `started_at` NOT `created_at`
- Compare schema.prisma with live DB to detect drift

### 3. Migration Execution
- For schema changes: `npx prisma migrate dev --name descriptive_name`
- For production: `npx prisma migrate deploy`
- Always generate the client after: `npx prisma generate`

### 4. Post-migration Verification
- Run `npx prisma migrate status` to confirm migration applied
- Run `npx prisma db pull --print | grep TABLE_NAME` to verify the changed table
- Check that TypeScript types are updated: `npx tsc --noEmit 2>&1 | head -20`

### 5. Rollback Plan
- If migration fails, show the user how to rollback:
  - `npx prisma migrate resolve --rolled-back MIGRATION_NAME`
  - Or manually: `npx prisma db execute --stdin <<< "SQL_ROLLBACK_STATEMENT"`
- Always output the rollback SQL before applying a migration

## Rules
- NEVER run `prisma migrate reset` in production without explicit user confirmation
- NEVER drop columns or tables without showing the user what data will be lost
- Always back up the migration SQL before applying
- For data migrations, use a separate script — not Prisma migrate
