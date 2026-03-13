# /component-scaffold — React Component Generator Skill

## Trigger
User says: "component-scaffold", "new component", "scaffold component", "create component", "generate component"

## Purpose
Generate React/Next.js components following the monorepo's conventions.

## Arguments
- `name` (required): Component name in PascalCase (e.g., `UserProfile`)
- `app` (optional): Target app — marketing, web, or admin (default: web)
- `type` (optional): page | component | layout | modal | form (default: component)

## Steps

### 1. Discover Conventions
Before generating, check existing patterns in the target app:
```bash
# Find existing component structure
ls apps/APP/src/components/ 2>/dev/null || ls apps/APP/components/ 2>/dev/null
# Check import style (relative vs alias)
head -20 apps/APP/src/components/*/index.tsx 2>/dev/null | head -30
# Check if barrel exports are used
ls apps/APP/src/components/index.ts 2>/dev/null
```

### 2. Generate Component
Based on type, create the appropriate files:

**Standard Component:**
```
apps/APP/src/components/ComponentName/
├── ComponentName.tsx    # Main component
└── index.ts             # Barrel export
```

**Page Component:**
```
apps/APP/src/app/route-name/
└── page.tsx             # Page with metadata export
```

**Modal Component:**
```
apps/APP/src/components/modals/
└── ComponentNameModal.tsx  # Modal using in-app dialog (NOT window.confirm)
```

**Form Component:**
```
apps/APP/src/components/forms/
└── ComponentNameForm.tsx   # Form with validation
```

### 3. Component Template Rules
- TypeScript with explicit prop types (interface, not type)
- Props interface named `ComponentNameProps`
- Export as named export (not default) from component file
- Default export only from page.tsx files
- Use `'use client'` ONLY if the component needs hooks or browser APIs
- For notifications: use toast/banner components, NEVER `window.alert()` or browser Notification API
- For confirmations: use modal dialog component, NEVER `window.confirm()`

### 4. Post-generation
- Run TypeScript check: `npx tsc --noEmit 2>&1 | head -10`
- Verify import paths resolve correctly
- Add barrel export to parent index.ts if one exists

## Rules
- NEVER use `window.alert()`, `window.confirm()`, `window.prompt()`, or browser Notification API
- NEVER use default exports for components (only for pages)
- Match existing code style — check indentation, quotes, semicolons from nearby files
- Keep generated components under 100 lines — split if larger
- Use Prisma types from the correct package when dealing with data models
