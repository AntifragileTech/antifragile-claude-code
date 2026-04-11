---
name: gsc-regex
description: >
  Google Search Console analysis: RE2 regex patterns, query diagnosis, page trajectory
  classification, and content auditing. Auto-triggers when: analyzing GSC data, filtering
  search queries, segmenting branded vs non-branded traffic, diagnosing ranking drops,
  classifying page health (DEAD/WEAK/FAIR/GOOD/PERFORMANCE), content audit, E-E-A-T review,
  crawl budget optimization, query migration tracking, or any task involving Google Search
  Console Performance report filtering or site content health.
domain: seo
tags: [seo, gsc, google-search-console, regex, re2, query-analysis, keyword-segmentation, content-audit, eeat, crawl-budget]
version: "1.1"
---

# GSC Regex Filters — RE2 Pattern Reference

> Google Search Console uses **RE2 syntax** — not Python/JS regex.
> RE2 key differences: no lookaheads, no backreferences, no \b word boundary (use alternatives below).
> All patterns go in: Performance Report → + New → Query or Page → Custom (regex)

---

## 1. Branded vs Non-Branded Traffic

```re2
# Branded — match your brand name (case-insensitive in GSC)
(yourbrand|your brand|yourdomain)

# Multi-brand
(brand1|brand2|brand one|brand-one)

# Non-branded — GSC has no NOT filter natively
# Workaround: export data, filter in Google Sheets with =NOT(REGEXMATCH())
# Or use SEO Stack / Looker Studio for exclusion filters
```

**Use case**: Split CTR, impressions, avg position by branded vs non-branded.
Branded queries skew avg position up — remove them to see true organic performance.

---

## 2. Question / Informational Intent

```re2
# All question starters
^(how|what|why|when|where|who|which|can|does|do|is|are|will|should|would)

# Specific intent groups
^(how to|how do|how does|how can|how much|how many)
^(what is|what are|what does|what should)
^(why is|why does|why do|why are)
^(best|top|vs|versus|compare|difference between)

# Questions with question mark (some users type it)
\?$
```

**Use case**: Find all informational queries → content gap analysis, FAQ schema opportunities, blog topics.

---

## 3. Long-Tail Keywords (3+ words)

```re2
# 3+ word queries (two or more spaces = 3+ words)
\S+\s\S+\s\S+

# 4+ word queries
\S+\s\S+\s\S+\s\S+

# 5+ word queries
\S+\s\S+\s\S+\s\S+\s\S+
```

**Use case**: Long-tail queries convert better. Find ones with impressions but low clicks → easy ranking wins.

---

## 4. Local / Geo Intent

```re2
# Near me intent
near me

# City targeting (add your cities)
(london|manchester|birmingham|glasgow|leeds)
(new york|los angeles|chicago|houston|phoenix)
(dubai|abu dhabi|sharjah)

# Country/region modifiers
(uk|usa|us|canada|australia|india)( |$)

# Local modifiers
(local|near|nearby|in my area|around me)

# Zip/postcode pattern (US)
[0-9]{5}

# City + service pattern
(london|manchester).*(plumber|dentist|lawyer|accountant)
```

**Use case**: Isolate local queries → audit local landing pages, check GMB alignment, local schema.

---

## 5. Commercial / Transactional Intent

```re2
# Buy intent
^(buy|purchase|order|get|shop for|where to buy)

# Pricing intent
(price|pricing|cost|how much|fee|cheap|affordable|expensive)

# Comparison / decision stage
(vs|versus|compare|best|top [0-9]|review|reviews|rating|ratings)

# Service hiring intent
(hire|find|looking for|need a|book a|quote)

# Discount / deal intent
(discount|coupon|promo|deal|offer|sale|free)
```

**Use case**: Find bottom-funnel queries → check landing page conversion rate, CTA alignment, pricing page SEO.

---

## 6. Page Type Filtering

```re2
# Blog / content pages
/blog/
/(blog|article|post|news|guide|tutorial)/

# Product pages
/(product|products|shop|store|item)/

# Category pages
/(category|categories|collection|collections)/

# Landing pages
/(lp|landing|campaign)/

# Location pages
/(locations|location|cities|city|local)/

# Specific file extensions
\.(pdf|xml|json)$

# Exclude certain paths (use in Sheets — GSC has no NOT)
# =NOT(REGEXMATCH(A2, "/(admin|login|api|cdn)/"))

# Homepage only
^https?://(www\.)?yourdomain\.com/?$

# Subdomains
^https?://app\.yourdomain\.com
^https?://blog\.yourdomain\.com
```

**Use case**: Analyse performance by page type. Blog pages vs product pages have very different CTR norms.

---

## 7. Competitor & Brand Comparison Queries

```re2
# Competitor mentions in your queries
(competitor1|competitor2|competitor3)

# VS / comparison queries mentioning you or competitors
(yourbrand|competitor).*(vs|versus|compare|alternative|review)

# Alternative searches
(alternative|alternatives).*(to )?(yourbrand|competitor)
(yourbrand|competitor).*(alternative|competitor|switch)
```

**Use case**: People searching "competitor vs yourbrand" are in active decision mode → high-intent pages needed.

---

## 8. Featured Snippet / SERP Feature Opportunities

```re2
# Definition queries (often trigger featured snippets)
^(what is|what are|define|definition of)

# List queries (numbered/bulleted snippets)
^(top|best|list of|types of|ways to|steps to|how to)

# Table queries
(comparison|compare|vs|difference|price list|table)

# People Also Ask triggers
^(can you|is it|does it|should i|do i need)
```

**Use case**: Queries matching these patterns where you rank 2-10 = featured snippet opportunities.

---

## 9. Keyword Length / Specificity Segments

```re2
# Single word queries (no spaces)
^\S+$

# Two word queries
^\S+\s\S+$

# Exact 3 word queries
^\S+\s\S+\s\S+$

# Short queries (under ~20 chars approx)
^.{1,20}$

# Long queries (over ~40 chars)
^.{40,}$
```

---

## 10. Technical / Developer Queries

```re2
# API / developer intent
(api|sdk|webhook|endpoint|integration|documentation|docs)

# Error / troubleshooting
(error|fix|not working|broken|issue|problem|debug|troubleshoot)

# Code-related
(code|snippet|example|tutorial|how to implement|github)
```

---

## 11. Seasonal / Temporal Patterns

```re2
# Year mentions (current + next)
(2024|2025|2026)

# Seasonal
(spring|summer|autumn|fall|winter|christmas|holiday|black friday|new year)

# Urgency
(today|now|urgent|asap|same day|next day|overnight)
```

---

## Looker Studio / Google Sheets Bonus

GSC UI can't do exclusions. Use these in Sheets on exported data:

```sheets
# Exclude branded (column A = query)
=NOT(REGEXMATCH(A2,"(yourbrand|your brand)"))

# Match question queries
=REGEXMATCH(A2,"^(how|what|why|when|where|who)")

# Count words in query
=LEN(TRIM(A2))-LEN(SUBSTITUTE(TRIM(A2)," ",""))+1
```

---

## Quick Reference Cheat Sheet

| Goal | Pattern |
|---|---|
| Branded | `(brand\|brand name)` |
| Questions | `^(how\|what\|why\|when\|where\|who)` |
| Long-tail 3+ words | `\S+\s\S+\s\S+` |
| Local intent | `(near me\|in [city])` |
| Buy intent | `^(buy\|purchase\|order\|get)` |
| Comparison | `(vs\|versus\|compare\|best\|review)` |
| Pricing | `(price\|cost\|how much\|cheap)` |
| Blog pages | `/blog/` |
| Featured snippet targets | `^(what is\|how to\|best\|top)` |
| Exclude path (Sheets) | `=NOT(REGEXMATCH(A2,"pattern"))` |

---

## Workflow: Full GSC Audit with Regex

1. **Export** Performance data (Last 3 months, 1000 rows)
2. **Branded split**: separate branded/non-branded impressions + CTR
3. **Intent map**: classify queries by question / commercial / local
4. **Long-tail sweep**: filter 4+ word queries with >100 impressions, CTR <2% = low-hanging fruit
5. **Page type audit**: compare avg position per page type
6. **Featured snippet hunt**: question queries ranked 2-10 with >500 impressions
7. **Competitor queries**: check if competitor brand names appear in your queries

---

## Reference Files

- [Regex Patterns](SKILL.md) — RE2 filter patterns for GSC Performance report (this file)
- [Query Diagnosis](references/query-diagnosis.md) — Position group analysis, page trajectory, 3 diagnostic scenarios, page weighting, migration tracking
- [Content Audit](references/content-audit.md) — URL health tiers (DEAD→PERFORMANCE), E-E-A-T checklist, NLP gap analysis, crawl budget optimization
