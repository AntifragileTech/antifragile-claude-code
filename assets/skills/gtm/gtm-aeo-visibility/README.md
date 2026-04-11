# AEO Visibility Checker

**AI Answer Engine Optimization** — track how visible your company is across ChatGPT, Claude, Gemini, and Perplexity.

## Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Set API Keys

```bash
export OPENAI_API_KEY=sk-...
export ANTHROPIC_API_KEY=sk-ant-...
export GOOGLE_API_KEY=...
export PERPLEXITY_API_KEY=pplx-...
```

### 3. Profile Your Company

```bash
node src/cli.js profile my-company --url=https://example.com
```

This generates:
- `clients/my-company/profile.json` (company + competitors)
- `clients/my-company/queries.json` (~100 test queries)

**Edit `queries.json`** to customize the queries.

### 4. Run Visibility Check

```bash
node src/cli.js run my-company
```

Output:
- `clients/my-company/runs/[timestamp]/report.md` (detailed analysis)
- `clients/my-company/runs/[timestamp]/results.csv` (raw data)
- `clients/my-company/history.csv` (historical tracking)

### 5. View History

```bash
node src/cli.js history my-company
```

## Usage Examples

### Test specific queries only

```bash
node src/cli.js run my-company --queries "best AI coding tools" "AI pair programming"
```

### Run for multiple clients

```bash
node src/cli.js profile acme-corp
node src/cli.js profile startup-b
node src/cli.js run acme-corp
node src/cli.js run startup-b
```

## What Gets Analyzed

For each query × engine combination:

1. **Mentioned**: Is your company mentioned at all?
2. **Prominence**: High (top 2 sentences) / Medium / Low
3. **Sentiment**: Positive (+1) / Neutral (0) / Negative (-1)
4. **Competitors**: Which competitors are mentioned?

## Report Structure

### Markdown Report
- Executive summary (overall visibility score, top engine)
- Performance by engine (mention rate, prominence, sentiment)
- Competitor comparison
- Top performing queries
- Missed opportunities (where competitors mentioned but you're not)

### CSV Export
Full data export with all metrics per query × engine.

## Cost

- **Full run**: $10-30 (100 queries × 4 engines)
- **Single query**: ~$0.40-1.20 (4 engines)
- **Profiling**: ~$0.50 (one-time)

The CLI shows cost estimate before running.

## Architecture

```
aeo-visibility/
├── src/
│   ├── cli.js          # Main CLI commands
│   ├── research.js     # Company profiling
│   ├── query-gen.js    # Query generation
│   ├── engines.js      # API clients (ChatGPT, Claude, Gemini, Perplexity)
│   ├── analyzer.js     # Response analysis
│   └── reporter.js     # Report generation
├── clients/
│   └── [client-name]/
│       ├── profile.json
│       ├── queries.json
│       ├── runs/[timestamp]/
│       └── history.csv
└── SKILL.md            # OpenClaw skill documentation
```

## Integration with OpenClaw

When used as an OpenClaw skill, you can trigger it via chat:

```
"Check our AEO visibility"
"Run visibility check for acme-corp"
"How visible are we on AI answer engines?"
```

See `SKILL.md` for integration details.

## API Keys

Get API keys from:
- OpenAI: https://platform.openai.com/api-keys
- Anthropic: https://console.anthropic.com/settings/keys
- Google AI: https://aistudio.google.com/apikey
- Perplexity: https://www.perplexity.ai/settings/api

## Future Enhancements

- Weekly scheduled runs with trend alerts
- More engines (SearchGPT, Gemini Deep Research)
- Optimization recommendations
- A/B testing different query phrasings
- Query performance optimization
