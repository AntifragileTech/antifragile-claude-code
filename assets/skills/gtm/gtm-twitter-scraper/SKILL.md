---
name: gtm-twitter-scraper
description: >
  Search public Twitter/X posts and research audiences using Apify. Use when you
  need tweets, timelines, replies, followers, lists, communities, or audience
  overlap. Uses Twitter native search syntax for reliable date filtering.
---

# Twitter Scraper

Search Twitter/X posts using Apify.
Use Xquik's focused Actors for posts and public audience relations.
The existing `apidojo/tweet-scraper` script remains available for compatibility.

Xquik is an independent third-party service. Not affiliated with X Corp. "Twitter" and "X" are trademarks of X Corp.

## Xquik Actor Routes

| Goal | Actor | REST selector | Actor ID |
|------|-------|---------------|----------|
| Posts, timelines, lists, and engagement routes | [X Tweet Scraper](https://apify.com/xquik/x-tweet-scraper) | `xquik~x-tweet-scraper` | `wAusCMrm284Voaw86` |
| Followers, lists, communities, and overlap | [X Follower Scraper](https://apify.com/xquik/x-follower-scraper) | `xquik~x-follower-scraper` | `AaT0BcKU5GQh97wdt` |

Inspect both live schemas before using unfamiliar fields:

```bash
apify actors info "xquik/x-tweet-scraper" --input --json
apify actors info "xquik/x-follower-scraper" --input --json
```

Tweet modes include `legacy`, `tweet`, `tweets`, `search`, `profileTweets`,
`profileReplies`, `profileMedia`, `profileLikes`, `listTweets`, `article`,
`replies`, `quotes`, `thread`, `retweeters`, and `favoriters`.

Follower relations include `followers`, `following`, `verified_followers`,
`list_members`, `list_followers`, and `community_members`.

Use `maxItems` as the global run cap.
Use `maxItemsPerTarget` only when the selected route supports it.
Confirm the live Apify price and result cap before every run.
Set Apify's maximum total charge outside Actor input when needed.

### Search With Xquik

```bash
apify actors call "xquik/x-tweet-scraper" \
  --input '{"mode":"search","searchTerms":["from:apify AI"],"queryType":"Latest","outputVariant":"rich","includeSearchTerms":true,"maxItems":25}' \
  --json \
  --output-dataset
```

### Export an Audience With Xquik

```bash
apify actors call "xquik/x-follower-scraper" \
  --input '{"twitterHandles":["apify"],"relation":"followers","outputMode":"compact","includeTargetMetadata":true,"maxItems":25,"maxItemsPerTarget":25}' \
  --json \
  --output-dataset
```

Use `dedupeMode: "merge"` or `overlapMode: true` for overlap.
Separate diagnostic rows from returned public data.
Do not count rows with `resultType: "diagnostic"` as scraped records.

## Quick Start

Requires `APIFY_API_TOKEN` env var (or `--token` flag). Install dependency: `pip install requests`.

```bash
# Search with date range (recommended — uses Twitter native since:/until: operators)
python3 skills/twitter-scraper/scripts/search_twitter.py \
  --query "GrowthX.ai" --since 2026-02-15 --until 2026-02-23

# Quick summary of recent mentions
python3 skills/twitter-scraper/scripts/search_twitter.py \
  --query "@growthxai" --max-tweets 20 --output summary

# Search without date filtering
python3 skills/twitter-scraper/scripts/search_twitter.py \
  --query "AI content marketing" --max-tweets 50
```

## Date Filtering

**Important:** The `apidojo/tweet-scraper` actor's built-in date parameters are unreliable.
This script embeds `since:YYYY-MM-DD` and `until:YYYY-MM-DD` directly into the search query
string, using Twitter's native advanced search syntax. This ensures date filtering works
correctly server-side.

## How the Script Works

1. Builds a search term with the query quoted and date operators appended
2. Calls the Apify `apidojo/tweet-scraper` actor via REST API
3. Polls until the run completes, then fetches the dataset
4. Deduplicates by tweet ID/URL
5. Applies optional keyword filtering (client-side)
6. Sorts by likes (descending) and outputs JSON or summary

## CLI Reference

| Flag | Default | Description |
|------|---------|-------------|
| `--query` | *required* | Search query (quoted in Twitter search) |
| `--since` | none | Start date YYYY-MM-DD (inclusive) |
| `--until` | none | End date YYYY-MM-DD (exclusive) |
| `--max-tweets` | 50 | Max tweets to scrape |
| `--keywords` | none | Additional filter keywords (comma-separated, OR logic) |
| `--output` | json | Output format: `json` or `summary` |
| `--token` | env var | Apify token (prefer `APIFY_API_TOKEN` env var) |
| `--timeout` | 300 | Max seconds to wait for the Apify run |

## Direct API Usage

```json
{
  "searchTerms": ["\"GrowthX.ai\" since:2026-02-15 until:2026-02-22"],
  "maxTweets": 50,
  "searchMode": "live"
}
```

## Output Format

Tweets are returned as JSON array sorted by likes. Each tweet has:

```json
{
  "id": "...",
  "text": "Tweet text...",
  "fullText": "Full tweet text...",
  "likeCount": 42,
  "retweetCount": 5,
  "replyCount": 3,
  "viewCount": 1200,
  "createdAt": "2026-02-18T12:00:00.000Z",
  "author": {"userName": "handle", "name": "Display Name", ...},
  "twitterUrl": "https://twitter.com/..."
}
```

## Common Workflows

### Competitor Monitoring
```bash
python3 skills/twitter-scraper/scripts/search_twitter.py \
  --query "CompetitorName" --since 2026-02-15 --until 2026-02-23 --output summary
```

### Brand Mention Tracking
```bash
python3 skills/twitter-scraper/scripts/search_twitter.py \
  --query "@YourHandle OR \"YourBrand\"" --max-tweets 100
```
