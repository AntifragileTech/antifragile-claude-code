# Reusable SEO Audit & Fix Session Prompt

> Copy the prompt below and paste into a new Claude Code session for any project.
> Adjust the placeholders in [BRACKETS] for your specific project.

---

## The Prompt

```
You are conducting a comprehensive SEO audit and fix session for [PROJECT_NAME] marketing website.

## Source Data
- Ahrefs/SEMrush CSV reports are in: [PATH_TO_REPORT_FOLDER]
- Read `index.txt` first for the list of all CSVs
- CSVs may be UTF-16LE encoded — use `iconv -f UTF-16LE -t UTF-8` to read them

## Approved Example Domains (for mockups/demos)
Only use these domains as placeholders: [LIST_YOUR_DOMAINS]
NEVER use example.com, mysite.com, acme.com, or any third-party domains.

## Rules
1. Follow the SEO methodology at `~/.claude/rules/common/seo-methodology.md` — execute ALL 9 phases in order
2. After EACH phase, launch 2 inspector agents to verify the work before moving to the next phase
3. Create a `{filename}_fixed.csv` report for every ahrefs CSV processed — put them in the same folder
4. Blog post dates: ALWAYS use today's date. NEVER use future dates
5. All page titles must be ≤60 characters including the brand suffix
6. All meta descriptions must be 120-155 characters
7. Every page must have og:type (website for pages, article for blog posts)
8. Update ai.txt, llms.txt, and robots.ts with ALL current pages and AI crawler user agents
9. Add cross-links between all free tools/pages at the bottom of each tool page
10. Run TypeScript check + production build after every major phase
11. Do NOT stop at 99% — complete every phase fully before moving on
12. If you encounter a build error, restart the dev server and debug from console logs — don't assume it's a cache issue

## Phase Execution Order
1. Critical 404s & Broken Links (highest SEO impact)
2. SEO Metadata (titles, descriptions, OG tags)
3. Sitemap & Technical SEO
4. Google Analytics coverage
5. Tool/Feature page SEO + cross-linking
6. Content creation (blogs, use cases) — if requested
7. AI SEO (ai.txt, llms.txt, robots.ts)
8. Placeholder domain replacement with approved domains
9. Final inspection + fix report CSVs

## Inspector Pattern
After each phase:
- Inspector A: Verify the specific fixes made in that phase
- Inspector B: Run a broader check (console errors, build, link audit)
If inspectors find issues, fix them before proceeding to the next phase.

## Deliverables
1. All ahrefs CSV errors fixed
2. Matching _fixed.csv report for each CSV
3. Zero TypeScript errors
4. Production build passes
5. Zero console errors on dev server
6. Updated ai.txt, llms.txt, robots.ts
7. Deploy command ready
```

---

## How to Use

1. Start a new Claude Code session in your project directory
2. Paste the prompt above with your project-specific values filled in
3. If you have an ahrefs report, put the CSV folder path
4. If no report, Claude will do a code-level audit using the methodology

## Customization Notes

- For non-Next.js projects: the sitemap/robots patterns will differ but the methodology is the same
- For static HTML sites: use a Python script for bulk metadata fixes instead of component-based approaches
- The 9-phase order is optimized for impact — don't skip phases even if they seem minor
