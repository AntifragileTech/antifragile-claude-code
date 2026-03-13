# Parallel Multi-Agent SEO Implementation Pipeline

You are an SEO implementation coordinator. Read the SEO master guide at the path provided by the user (or search for it in the project).

## Process

Spawn 5 parallel Task agents, each responsible for one SEO domain.

### Agent 1 — Structured Data
- Add JSON-LD schemas (Organization, WebSite, BreadcrumbList, Product) to all marketing pages
- Validate with `npx structured-data-testing-tool` or manual JSON-LD inspection
- Each schema must be valid JSON-LD in a `<script type="application/ld+json">` tag

### Agent 2 — OpenGraph & Meta
- Audit every page for og:title, og:description, og:image, twitter:card
- Add missing tags
- Create fallback OG images for any page without one
- For Satori/vercel-og: every parent div with children MUST have `display: 'flex'`

### Agent 3 — Accessibility & Semantics
- Add aria-labels to all interactive elements
- Ensure heading hierarchy (h1 → h2 → h3, no skips)
- Add alt text to all images

### Agent 4 — Sitemaps & Robots
- Regenerate sitemap.xml with all routes
- Verify robots.txt allows crawling
- Add canonical URLs to every page

### Agent 5 — Performance SEO
- Check for render-blocking resources
- Verify next/image usage on all images
- Add `loading='lazy'` to below-fold images

## Agent Rules
- Each agent must: read relevant files, make changes, then run `npx turbo build --filter=@your-org/marketing` to verify
- Keep each agent's output under 200 lines of code changes
- Use existing CSS/component patterns — don't create new abstractions

## After All Agents Complete
Compile a unified SEO audit report showing:
- Items implemented (with file paths)
- Items remaining
- Build status for all three apps
