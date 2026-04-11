---
name: deploy-cpanel
description: Create and validate deployment zips for cPanel shared hosting
---

# Deploy to cPanel

## Steps

1. **Create zip** of project files WITHOUT a `src/` wrapper folder — files must be at the zip root
2. **Use Python `zipfile` module** (never macOS `zip`) with:
   - Directory permissions: `0o40755 << 16`
   - File permissions: `0o100644 << 16`
   - Timestamps: `date_time=time.localtime()[:6]` (never default 1980-01-01)
   - Exclude: `.DS_Store`, `._*`, `node_modules`, `.git`
3. **Ensure `.htaccess`** includes `DirectoryIndex index.html` directive
4. **Verify** no nested folder structure that would cause 403 errors
5. **List all files** in zip for user confirmation before upload (`unzip -l`)
6. **Remind user** to delete zip from web root after extraction

## Validation Checklist

- [ ] Zip created from INSIDE source directory (no wrapper folder)
- [ ] All timestamps are current (not 1980-01-01)
- [ ] .htaccess present with correct DirectoryIndex
- [ ] No sensitive files included (.env, credentials, etc.)
- [ ] File count matches expected deployment files

## Debugging "Changes Not Showing"

1. Check ZIP timestamps first: `unzip -l deploy.zip`
2. If dates show `01-01-1980` — recreate with current timestamps
3. Only then check Cloudflare/LiteSpeed/browser cache
