# Content Audit — URL Health, E-E-A-T & Crawl Budget

> Use this when: auditing all pages on a site, deciding what to keep/fix/prune,
> improving E-E-A-T signals, or optimizing crawl budget allocation.

---

## 1. URL Health Classification

Every page on the site gets one of 5 tiers based on GSC + traffic data:

| Tier | Definition | GSC Signal | Action |
|---|---|---|---|
| **PERFORMANCE** | Top pages driving meaningful traffic | High clicks, strong positions | Protect, expand, internal link from |
| **GOOD** | Healthy pages with steady traffic | Decent clicks, P1 rankings | Maintain, light refresh annually |
| **FAIR** | Pages with potential but underperforming | Some impressions, low clicks | Optimize title/meta, add depth |
| **WEAK** | Minimal traffic, thin content | High impressions, near-zero clicks | Rewrite or consolidate |
| **DEAD** | No measurable organic value | Zero/near-zero impressions | Prune, redirect, or noindex |

**Thresholds (adjust per site size):**

```
PERFORMANCE : clicks > 50/month AND avg position < 15
GOOD        : clicks 10-50/month OR avg position < 20
FAIR        : clicks 1-10/month OR impressions > 100
WEAK        : clicks < 1/month AND impressions < 100
DEAD        : clicks = 0 AND impressions < 10 (last 3 months)
```

**Sheets formula to auto-classify (after GSC export):**
```sheets
# A=URL, B=Clicks, C=Impressions, D=Avg Position
=IF(AND(B2>50,D2<15),"PERFORMANCE",
 IF(OR(B2>=10,D2<20),"GOOD",
  IF(OR(B2>=1,C2>100),"FAIR",
   IF(AND(B2<1,C2<100),"WEAK","DEAD"))))
```

---

## 2. Content Health Score

Score each page 0–100 across 5 dimensions:

### 2.1 Quality & Depth (0–25)
- Word count appropriate for query intent (not just long)
- Covers all key subtopics (check PAA boxes for your target query)
- Original insights, data, examples — not just rephrased competitors
- Clear structure: H2s, H3s, lists, tables where appropriate

### 2.2 E-E-A-T Alignment (0–25)
```
Experience    — First-hand accounts, case studies, real examples
Expertise     — Author credentials visible, cited sources, accurate claims
Authoritativeness — Backlinks from topically relevant domains, brand mentions
Trustworthiness — HTTPS, privacy policy, about page, author bio, contact info
```
YMYL pages (health, finance, legal) need highest E-E-A-T bar.

### 2.3 Topical Coverage (0–20)
- Does content cover all subtopics GSC shows users searching for?
- Run NLP gap check: paste URL into Google's NLP API demo
- Check PAA (People Also Ask) boxes — are they answered in content?
- Check related searches at bottom of SERP

### 2.4 Index Health (0–15)
- Page indexed (check: `site:yourdomain.com/url`)
- No noindex tag accidentally applied
- Canonical points to self (not another page)
- Not blocked in robots.txt
- Mobile-friendly (Google's Mobile-Friendly Test)

### 2.5 Engagement Signals (0–15)
- Internal links pointing TO this page (check GSC Links report)
- Bounce rate / engagement time reasonable
- No thin above-the-fold ad blocks
- Core Web Vitals passing (LCP, CLS, INP)

**Score interpretation:**
```
80-100 : GOOD — maintain
60-79  : FAIR — targeted improvements
40-59  : WEAK — significant rewrite needed
0-39   : DEAD — prune or consolidate
```

---

## 3. NLP Gap Analysis (Google NLP API)

Find missing subtopics that would increase semantic relevance:

```bash
# Google Cloud NLP API (free tier: 5k units/month)
curl -X POST \
  "https://language.googleapis.com/v1/documents:analyzeEntities?key=YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "document": {
      "type": "HTML",
      "content": "PASTE_PAGE_HTML_HERE"
    },
    "encodingType": "UTF8"
  }'
```

**Compare your page entities vs top 3 competitor pages:**
- Entities present in all 3 competitors but missing from yours = add these topics
- Salience score < 0.1 on your target entity = strengthen coverage
- Entity type mismatch (e.g., competitors classified as ORGANIZATION, yours as OTHER) = brand/trust issue

**Free alternative — no API key:**
- Use https://cloud.google.com/natural-language#section-2 (demo)
- Paste page content, compare entity list to competitors

---

## 4. Crawl Budget Optimization

Allocate crawl budget to highest-value pages:

### Block from crawl (robots.txt or noindex):
```
- DEAD pages (0 traffic, no backlinks)
- Duplicate pages (pagination, sort/filter params without canonical)
- Internal search result pages
- Thank-you / confirmation pages
- Admin, login, cart pages
- Staging/dev URLs accidentally indexed
```

### robots.txt patterns:
```
# Block low-value parameterized URLs
Disallow: /*?sort=
Disallow: /*?filter=
Disallow: /*?ref=
Disallow: /search?

# Block utility pages
Disallow: /thank-you
Disallow: /checkout/
Disallow: /account/
```

### Priority crawl signals:
- Submit XML sitemap including ONLY PERFORMANCE + GOOD tier URLs
- Internal link heavily from PERFORMANCE pages → FAIR pages you want to promote
- Remove internal links to DEAD pages entirely

---

## 5. Decision Tree: Keep / Fix / Prune

For every URL after classification:

```
URL tier?
├── PERFORMANCE → Keep. Add internal links from it. Update annually.
├── GOOD        → Keep. Light refresh if >12 months old.
├── FAIR        → Fix. Improve title/meta first (quick win), then content depth.
├── WEAK        → Decision:
│   ├── Has backlinks? → Keep + rewrite fully
│   ├── Topic still relevant? → Consolidate into stronger page (301 redirect)
│   └── Topic irrelevant? → Prune (404 or 301 to homepage/category)
└── DEAD        → Decision:
    ├── Has backlinks? → 301 redirect to most relevant live page
    └── No backlinks? → Remove + 404 (update XML sitemap)
```

---

## 6. Full Content Audit Workflow

```
Step 1 — Export GSC data (last 3 months, all pages)
Step 2 — Classify all URLs into DEAD/WEAK/FAIR/GOOD/PERFORMANCE tiers
Step 3 — Cross-reference with Screaming Frog crawl (word count, title, h1, canonical)
Step 4 — Score top 20 WEAK/FAIR pages with Content Health Score
Step 5 — Run NLP gap analysis on WEAK pages with impressions > 100
Step 6 — Prioritize fixes: WEAK with backlinks first, then FAIR with high impressions
Step 7 — Prune/redirect confirmed DEAD pages
Step 8 — Update XML sitemap to exclude pruned pages
Step 9 — Monitor: recheck tier classifications in 60 days
```

---

## 7. E-E-A-T Quick Checklist

```
Author signals:
- [ ] Author name on every article
- [ ] Author bio with credentials/experience
- [ ] Author page with full profile
- [ ] LinkedIn/social links from author bio

Content signals:
- [ ] External citations to authoritative sources
- [ ] Original data, research, or case studies
- [ ] Last updated date visible
- [ ] Reviewed by / fact-checked by notation (YMYL pages)

Site signals:
- [ ] About page with team/company info
- [ ] Contact page with real contact details
- [ ] Privacy policy + Terms of service
- [ ] Physical address if local business
- [ ] Awards, press mentions, certifications visible
```
