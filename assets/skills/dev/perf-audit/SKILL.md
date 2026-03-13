# /perf-audit — Next.js Performance Audit Skill

## Trigger
User says: "perf-audit", "performance check", "bundle size", "slow page", "optimize", "lighthouse"

## Purpose
Audit Next.js app performance: bundle size, rendering, images, and data fetching.

## Steps

### 1. Bundle Analysis
```bash
# Build with analysis
ANALYZE=true npx turbo build --filter=APP_NAME
# Check build output sizes
find apps/APP/.next -name "*.js" -size +100k | head -20
# Check for large dependencies
npx turbo build --filter=APP_NAME 2>&1 | grep -E "First Load|Route"
```
- Flag any route chunk > 100KB
- Flag First Load JS > 200KB
- Look for duplicate dependencies across chunks

### 2. Image Optimization
```bash
# Find raw img tags (should use next/image)
grep -rn "<img " --include="*.tsx" --include="*.jsx" apps/APP/
# Find large static images
find apps/APP/public -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | xargs ls -lhS | head -10
# Check for missing width/height on next/image
grep -rn "Image" --include="*.tsx" apps/APP/ | grep -v "width\|height"
```
- All images should use `next/image`
- Static images > 200KB should be optimized or use WebP
- Verify `priority` prop on above-fold hero images

### 3. Rendering Analysis
```bash
# Find client components that could be server components
grep -rn "'use client'" --include="*.tsx" apps/APP/ | head -20
# Check for unnecessary client-side data fetching
grep -rn "useEffect.*fetch\|useSWR\|useQuery" --include="*.tsx" apps/APP/
# Find components importing large client libraries
grep -rn "import.*from.*framer-motion\|import.*from.*moment\|import.*from.*lodash" --include="*.tsx" apps/APP/
```
- Flag `'use client'` components that don't use hooks or browser APIs
- Flag client-side fetching that could be server-side
- Flag large libraries (moment.js, lodash full import)

### 4. Data Fetching
```bash
# Find fetch calls without caching config
grep -rn "fetch(" --include="*.ts" --include="*.tsx" apps/APP/ | grep -v "cache\|revalidate\|next:" | head -20
# Check for N+1 query patterns
grep -rn "findMany\|findFirst" --include="*.ts" apps/APP/ | head -20
```
- Verify fetch calls have `cache` or `next.revalidate` config
- Look for N+1 Prisma queries in loops
- Check for missing `Suspense` boundaries on async components

### 5. Third-party Scripts
```bash
grep -rn "script.*src\|Script.*src\|gtag\|analytics\|hotjar\|intercom" --include="*.tsx" apps/APP/ | head -15
```
- Third-party scripts should use `next/script` with `strategy="lazyOnload"`
- Analytics should not block rendering

## Output
Produce a summary table:
| Category | Finding | Severity | File | Fix |
Rate overall: Good / Needs Work / Critical

## Rules
- Do NOT modify files during audit — report only
- Focus on the app the user specifies (marketing, web, or admin)
- If no app specified, audit all three and compare
