# Query Diagnosis & Page Trajectory — GSC Methodology

> Use this when: analyzing why a page is losing clicks, diagnosing ranking drops,
> prioritizing content fixes, or assessing page health from GSC Performance data.

---

## 1. Position Group Segmentation

Split query counts into 4 brackets — never look at avg position alone:

| Group | Positions | Signal |
|---|---|---|
| **Top 3** | 1–3 | High CTR, featured snippet zone |
| **Page 1 mid** | 4–10 | Click-worthy, optimization target |
| **Page 2** | 11–20 | Low clicks, needs push to P1 |
| **Buried** | 21+ | Effectively invisible |

**How to use in GSC:**
```
Performance → Pages → select URL → Queries tab
Sort by Position — manually count queries per bracket
Or export CSV and use COUNTIFS in Sheets:
=COUNTIFS(C:C,">="&1,C:C,"<="&3)   # Top 3
=COUNTIFS(C:C,">="&4,C:C,"<="&10)  # P1 mid
=COUNTIFS(C:C,">="&11,C:C,"<="&20) # P2
=COUNTIFS(C:C,">"&20)               # Buried
```

---

## 2. Page Trajectory Classification

Track query counts week-on-week across position groups to classify each page:

### Growth 📈
- Top 3 + P1 mid query counts increasing
- New queries appearing in buried → migrating up
- Action: Scale — add internal links, expand content

### Stagnation 😐
- Query counts flat across all groups for 4+ weeks
- Impressions flat, clicks flat
- Action: Refresh — update content, add new angles, improve E-E-A-T signals

### Saturation 🔶
- P1 mid queries high but not moving to Top 3
- High impressions, CTR plateauing
- Action: Optimize — title/meta CTR improvements, structured data, content depth

### Decline ⚠️
- Queries dropping from P1 into P2/buried
- Or total query count shrinking week-on-week
- Action: Diagnose — run the 3-scenario diagnostic below immediately

```sheets
# Week-on-week query count change (Sheets formula)
# Column A = week, B = query count
=B2-B1   # absolute change
=(B2-B1)/B1*100  # % change
```

---

## 3. Three Diagnostic Scenarios

When a page shows **Decline**, run this decision tree:

### Scenario 1 — Growing Query Volume + Growing Impressions
```
Total queries: ↑   Impressions: ↑   Clicks: ↑ or flat
```
**Diagnosis**: Content gaining semantic relevance — Google indexing more of your topic.
**Action**: No panic. Add depth, internal links. Let it mature.

### Scenario 2 — Stable Queries + Falling Clicks
```
Total queries: → (flat)   Impressions: → (flat)   Clicks: ↓
```
**Diagnosis**: Ranking positions slipping within existing groups. Recoverable.
Root causes: SERP feature stealing clicks (featured snippet, PAA), title/meta CTR drop, competitor improved.
**Action**:
- Check if a SERP feature appeared above your result
- A/B test title tag (more compelling, add number/year)
- Check for cannibalization — two pages competing for same queries

### Scenario 3 — Query Loss (Total Queries Dropping)
```
Total queries: ↓   Impressions: ↓   Clicks: ↓
```
**Diagnosis**: True content devaluation. Google reducing how many queries your page is relevant for.
Root causes: Thin content, E-E-A-T issues, fresher/better competitor content, topic drift.
**Action**:
- Full content rewrite with depth + sources
- Add author credibility signals
- Check if URL was recently changed (redirect issues)
- Run NLP analysis — are you missing key subtopics?

---

## 4. Page Weighting Formula

Prioritize which pages to fix first using this composite score:

```
Page Weight = (Top3 queries × 3) + (P1mid queries × 2) + (P2 queries × 1)
```

Higher score = more Google investment in that page = more worth fixing.

**In Sheets (after GSC export):**
```sheets
# Assuming: D=Top3 count, E=P1mid count, F=P2 count
=D2*3 + E2*2 + F2*1
```

Sort descending by Page Weight, then filter for Decline trajectory = **highest-priority fix list**.

---

## 5. Query Migration Tracking

Run this comparison monthly: same URL, two date ranges (e.g., last 28d vs prior 28d).

| Pattern | What it means |
|---|---|
| Queries present in both periods, position improved | Healthy growth |
| Queries present in both, position worsened | Slippage — optimize |
| Queries only in old period (disappeared) | Devaluation — deep fix needed |
| Queries only in new period (appeared) | New relevance — expand content |

```sheets
# After exporting both periods, use VLOOKUP to find disappeared queries
=IFERROR(VLOOKUP(A2, NewPeriod!A:A, 1, 0), "DISAPPEARED")
```

---

## 6. Content Audit Prioritization Matrix

Combine trajectory + page weight to prioritize:

| Priority | Trajectory | Page Weight | Action |
|---|---|---|---|
| 🔴 P1 | Decline | High (>20) | Fix immediately |
| 🟠 P2 | Decline | Low (<10) | Consolidate or prune |
| 🟡 P3 | Stagnation | High | Refresh + expand |
| 🟢 P4 | Growth | Any | Support with links |
| ⚪ P5 | Saturation | Any | CTR optimization only |

Declining pages with **Top 10 presence** (any P1 mid queries) = highest ROI fixes.
