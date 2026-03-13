# Quick Start Guide

## 1. Setup (First Time)

```bash
# Install dependencies
npm install

# Set API keys
export OPENAI_API_KEY=sk-...
export ANTHROPIC_API_KEY=sk-ant-...
export GOOGLE_API_KEY=...
export PERPLEXITY_API_KEY=pplx-...
```

## 2. Profile Your Company

```bash
node src/cli.js profile my-company --url=https://mycompany.com
```

This creates:
- `clients/my-company/profile.json`
- `clients/my-company/queries.json` (~100 queries)

**Review and edit** `clients/my-company/queries.json` to customize queries.

## 3. Run Visibility Check

```bash
node src/cli.js run my-company
```

This will:
- Query all 4 engines (ChatGPT, Claude, Gemini, Perplexity)
- Analyze mentions, prominence, sentiment
- Generate report + CSV
- Update history

**Time**: ~10-15 minutes for 100 queries
**Cost**: $10-30

## 4. Review Results

```bash
# View the report
cat clients/my-company/runs/[timestamp]/report.md

# Open CSV in spreadsheet
open clients/my-company/runs/[timestamp]/results.csv

# View historical summary
node src/cli.js history my-company
```

## Granular Testing

Test specific queries only (cheaper, faster):

```bash
node src/cli.js run my-company --queries "best AI tools" "AI coding assistant" "top LLMs"
```

Cost: ~$0.40-1.20 per query (4 engines)

## What You Get

### `report.md`
- Executive summary (visibility score, top engine)
- Performance by engine
- Competitor comparison
- Top queries (where you're mentioned)
- Missed opportunities (competitors mentioned, you're not)

### `results.csv`
Full data: query, mentioned (4 engines), prominence (4 engines), sentiment (4 engines), competitors

### `history.csv`
Track trends over time (timestamp, queries, mentions, avg_score, top_engine)

## Next Steps

1. Optimize queries based on performance
2. Schedule weekly runs to track trends
3. Focus on "missed opportunity" queries
4. Test different query phrasings
5. Run after content/SEO changes to measure impact

## Tips

- Start with 10-20 queries to test before full run
- Edit `queries.json` to focus on your ICP's actual searches
- Track history weekly to spot trends
- Compare prominence scores across engines to find opportunities
- Use "missed opportunities" section to prioritize content strategy
