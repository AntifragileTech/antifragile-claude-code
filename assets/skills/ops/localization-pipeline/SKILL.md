---
name: localization-pipeline
description: Autonomous Arabic localization audit and fix pipeline for HTML sites
---

# Autonomous Localization Pipeline

## Usage
Invoke with: `/localization-pipeline [directory path]`

Default directory: the Arabic (`/ar/`) subdirectory of the current project.

## Pipeline Steps

### Step 1: Scan for Untranslated Strings
- Use grep/ripgrep to scan all HTML files for remaining English text
- Ignore: code, HTML attributes, URLs, script/style blocks, meta tags
- Write findings to `./localization-audit.md` with file paths and line numbers

### Step 2: Create Tracking Checklist
- Create a TodoWrite checklist of every file needing fixes
- Group by severity: fully untranslated pages vs partial strings

### Step 3: Batch Fix
- For each file, replace English strings with Arabic translations
- Ensure `dir="rtl"` attributes are set on all text containers
- Use Python scripts for bulk operations across >5 files (don't edit file-by-file)
- Preserve HTML structure — never break tags

### Step 4: Validation Pass
- Grep again to confirm no English strings remain
- Run basic HTML syntax check (unclosed tags, broken structure)
- Verify RTL attributes are present on text containers

### Step 5: Summary Report
Generate a report showing:
- Files modified (count + list)
- Strings replaced (count)
- Files needing manual review (ambiguous context)
- Ready-to-deploy zip (excluding node_modules, .git)

## Rules
- Use grep/sed/Python scripts for bulk operations — NOT file-by-file AI edits
- Stop and ask user if translation context is ambiguous
- Never modify non-text content (images, scripts, styles)
- Create deployment zip using Python `zipfile` (not macOS `zip`)
