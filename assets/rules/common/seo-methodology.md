# SEO Methodology — Standard Operating Procedure

> Universal SEO audit, fix, and optimization workflow. Apply to any marketing website project.
> Phase-by-phase execution with inspector agents after each phase.

---

## Pre-Flight Checklist

Before starting ANY SEO work:
1. Check if an ahrefs/Screaming Frog/SEMrush CSV report exists — process it first
2. Read existing `sitemap.ts`, `robots.ts`, `ai.txt`, `llms.txt` files
3. Identify the project's tech stack (Next.js, static HTML, etc.)
4. Note all existing pages, tools, blog posts for baseline

---

## Phase 1: Critical Errors (404s & Broken Links)

**Priority**: HIGHEST — these directly hurt SEO rankings.

### 1.1 Cloudflare Email Obfuscation Fix
- Cloudflare's Email Address Obfuscation converts visible emails to `/cdn-cgi/l/email-protection` links
- Crawlers that don't execute JavaScript see these as 404s
- **Fix**: Create a client-side `SafeEmail` component that renders emails via JS state only
- Replace ALL `mailto:` links and visible email addresses with SafeEmail
- Exception: emails inside `<script type="application/ld+json">` (JSON-LD) are safe — Cloudflare doesn't obfuscate script tags

### 1.2 Broken Internal Links
- Grep all internal links from source files (TSX, MDX, HTML)
- Cross-reference against actual pages/routes that exist
- Fix by redirecting to correct existing pages or creating the missing content
- Common patterns: blog links to non-existent posts, app URL links from marketing pages

### 1.3 Fix Report CSV
- For each ahrefs CSV processed, create a matching `{filename}_fixed.csv` with: URL, Status (FIXED/SKIPPED/OK/NOTED), Action Taken

### Inspector 1.1 & 1.2
- Run internal link audit agent after fixes
- Verify zero broken links remain
- Check console for 404 errors on dev server

---

## Phase 2: SEO Metadata

### 2.1 Page Titles (≤60 characters)
- Google truncates at ~60 chars in SERPs
- Pattern: `{Short descriptive title} | {Brand Name}`
- For blogs with long titles: use short `title` for SERP + `h1Title` for page H1 display
- Never sacrifice keyword intent when shortening

### 2.2 Meta Descriptions (120-155 characters)
- Too long (>160): Google truncates — shorten to 120-155 chars
- Too short (<110): Missed keyword opportunity — expand to 120-155 chars
- Include primary keyword + CTA or value proposition
- Blog category descriptions need expanding (often too short)

### 2.3 Open Graph Tags
- Every page MUST have `og:type` (`website` for pages, `article` for blog posts)
- Required OG tags: `og:title`, `og:description`, `og:url`, `og:image`, `og:type`
- Check for duplicate `type` fields after automated edits

### 2.4 Structured Data (JSON-LD)
- Validate with Google Rich Results Test
- `SoftwareApplication` needs `aggregateRating` for rich results
- `FAQPage`, `HowTo`, `BreadcrumbList` where applicable
- Organization schema with correct contact info

### Inspector 2.1 & 2.2
- Verify all titles ≤60 chars (including brand suffix)
- Verify all descriptions 120-155 chars
- Check og:type present on every page
- Build the project to catch any metadata compilation errors

---

## Phase 3: Sitemap & Technical SEO

### 3.1 Sitemap Completeness
- ALL indexable pages must be in sitemap
- Common miss: subdirectory blog posts (e.g., `/blog/compare/*`)
- Dynamic routes must auto-generate sitemap entries
- No duplicate entries (http vs https)

### 3.2 Canonical URLs
- Every page should have a canonical URL
- All canonicals must use https (not http)
- No self-referencing issues

### 3.3 Robots.txt
- Allow all public pages
- Disallow: `/api/`, `/start/`, `/embed/`, admin paths
- Include sitemap URL
- Add AI crawler rules (see Phase 7)

### Inspector 3.1 & 3.2
- Verify sitemap includes all pages (count pages vs sitemap entries)
- Check for duplicate sitemap entries
- Verify robots.txt blocks correct paths

---

## Phase 4: Google Analytics

### 4.1 GA4 Coverage
- GA4 must be on EVERY marketing page
- Best approach: add to root layout (covers all routes)
- Verify on client-rendered pages (job status pages, dynamic routes)
- Check with `document.querySelector('script[src*="gtag"]')` in console

### 4.2 Event Tracking
- Scroll depth tracking
- CTA click tracking
- Tool usage tracking
- 404 page tracking
- Form submission tracking

### Inspector 4.1 & 4.2
- Visit 5+ different page types and verify GA4 script loads
- Check Network tab for gtag requests

---

## Phase 5: Tool/Feature Page SEO

### 5.1 Contextual Naming
- Tool names should include the domain/category context
- Examples: "Domain SPF Checker" not just "SPF Checker"
- "Email Inbox Risk Checker" not just "Inbox Risk Checker"
- Apply consistently across Header, Footer, sitemap, tool pages

### 5.2 Cross-Linking Between Tools
- Create a reusable `FreeToolsCrossLink` component
- Add to the bottom of every tool page
- Shows all other tools (excluding current page)
- Include icons and contextual names

### 5.3 Tool Page Metadata
- Each tool page needs unique title, description, OG tags
- Include primary keyword in title
- Description should describe the tool's function + "free, no sign-up"

### Inspector 5.1 & 5.2
- Verify FreeToolsCrossLink renders on all tool pages
- Verify tool names consistent across Header, Footer, and tool pages
- Check no broken cross-links

---

## Phase 6: Content Creation

### 6.1 Blog Posts
- Date: ALWAYS use today's date (NEVER future dates)
- Category: must be from the project's valid category list
- `readingTime`: NEVER set in frontmatter — auto-calculated
- Include "Related Reading" section with 4-6 internal links
- Link to relevant tools within content
- Keep each post under 200 lines

### 6.2 Use Cases
- Add use cases for new features/tools
- Include: problem, solution, benefits, mockup
- Add FAQ entries for each new use case

### 6.3 Internal Linking
- Every blog should link to related tools
- Every tool page should link to related blogs
- Use cases should link to both blogs and tools
- New content must cross-link with existing content

### Inspector 6.1 & 6.2
- Verify all blog dates are today or past (never future)
- Verify no broken links in new content
- Run internal link audit on new content

---

## Phase 7: AI SEO (AEO — Answer Engine Optimization)

### 7.1 ai.txt (for AI crawlers)
- Located at `/public/ai.txt`
- Lists all key pages with descriptions
- Include pricing info, feature list
- Update whenever new pages/tools are added

### 7.2 llms.txt (for LLM indexing)
- Located at `/public/llms.txt`
- Markdown-formatted product description
- Feature list, pricing table, free tools list, developer tools
- Company info and contact

### 7.3 robots.ts — AI Crawler Rules
- Explicitly allow these AI crawlers:
  - `GPTBot` (OpenAI/ChatGPT)
  - `Google-Extended` (Google Gemini)
  - `ClaudeBot` (Anthropic/Claude)
  - `Anthropic-AI` (Anthropic)
  - `CCBot` (Common Crawl)
  - `Bytespider` (ByteDance/TikTok)
  - `PerplexityBot` (Perplexity AI)
  - `Applebot-Extended` (Apple Intelligence)
  - `cohere-ai` (Cohere)
- Same disallow rules as regular crawlers

### 7.4 Structured Data for AI
- JSON-LD schemas help AI crawlers understand content
- Organization, WebSite, SoftwareApplication schemas
- FAQ schemas on relevant pages
- HowTo schemas on tool pages

### Inspector 7.1 & 7.2
- Verify ai.txt lists ALL current pages and tools
- Verify llms.txt has complete, accurate product info
- Verify robots.ts includes all AI crawler user agents

---

## Phase 8: Placeholder Domains & Branding

### 8.1 Example Domain Policy
- NEVER use `example.com`, `mysite.com`, `acme.com` in mockups/demos
- Use the company's own product domains as examples
- Keep a list of approved example domains for the project
- Form input placeholders (e.g., `placeholder="example.com"`) are OK — they're user-facing hints

### 8.2 Consistency Check
- All mockup/demo content should use approved domains
- No duplicate domain names as React keys in lists
- Brand name consistent across all pages

### Inspector 8.1 & 8.2
- Grep for `example.com`, `mysite`, `acme` in source
- Verify only approved domains in mockups
- Check for duplicate key warnings in console

---

## Phase 9: Final Inspection

### 9.1 Build Verification
- TypeScript: zero errors (`npx tsc --noEmit`)
- Production build passes (all static pages generated)
- No console errors on dev server across 5+ page types

### 9.2 Fix Report CSVs
- One `_fixed.csv` for each input ahrefs CSV
- Contains: URL/Scope, Status, Action Taken, Summary
- Status values: FIXED, SKIPPED (not our domain), OK (correct behavior), NOTED (for later)

### 9.3 Final Link Audit
- Run internal link audit across ALL source files
- Verify zero broken internal links
- Check all tool cross-links work
- Verify sitemap entry count matches actual page count

### Inspector 9.1 & 9.2
- Full build test
- Console error check across homepage, features, tools, blog, use-cases, contact
- Verify fix report CSV count matches input CSV count
