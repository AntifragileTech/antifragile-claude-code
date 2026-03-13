# Module 7: GTM (Go-To-Market) Skills

> Installs 86 go-to-market skills for SEO, ads, outreach, competitor intelligence, and content creation.

**Note**: Most scraping skills need an [Apify](https://apify.com) API token (`APIFY_API_TOKEN`). SEO skills optionally use Ahrefs/SEMrush via Apify actors. Outreach skills use [Smartlead](https://smartlead.ai) (`SMARTLEAD_API_KEY`).

## Copy this prompt into Claude Code:

```
Clone https://github.com/AntifragileTech/antifragile-claude-code.git to /tmp/ccpp with --depth 1.

Then install GTM skills:

1. For each directory in /tmp/ccpp/assets/skills/gtm/, copy it to ~/.claude/skills/
2. If the skill directory already exists in ~/.claude/skills/, SKIP it (never overwrite)
3. Report: how many installed, how many skipped, total skills now in ~/.claude/skills/

After copying, clean up: rm -rf /tmp/ccpp
```

## What's Included (86 skills)

**SEO**: gtm-seo-content-engine, gtm-seo-content-audit, gtm-seo-domain-analyzer, gtm-seo-opportunity-finder, gtm-seo-traffic-analyzer, gtm-aeo-visibility, gtm-aeo-visibility-monitor

**Ads**: gtm-ad-angle-miner, gtm-ad-campaign-analyzer, gtm-ad-spend-allocator, gtm-ad-to-landing-page-auditor, gtm-google-ad-scraper, gtm-google-search-ads-builder, gtm-meta-ads-campaign-builder, gtm-search-ad-keyword-architect, gtm-trending-ad-hook-spotter, gtm-competitor-ad-teardown, gtm-paid-channel-prioritizer

**Competitor Intel**: gtm-competitor-intel, gtm-competitive-pricing-intel, gtm-competitive-strategy-tracker, gtm-competitor-monitoring-system, gtm-battlecard-generator

**Content**: gtm-content-asset-creator, gtm-content-repurposer, gtm-blog-scraper, gtm-create-html-carousel, gtm-create-html-slides, gtm-help-center-article-generator, gtm-site-content-catalog

**Outreach**: gtm-email-drafting, gtm-early-access-email-sequence, gtm-setup-outreach-campaign, gtm-customer-win-back-sequencer, gtm-messaging-ab-tester

**Social/Scraping**: gtm-linkedin-post-research, gtm-linkedin-profile-post-scraper, gtm-linkedin-commenter-extractor, gtm-linkedin-influencer-discovery, gtm-linkedin-job-scraper, gtm-reddit-scraper, gtm-twitter-scraper, gtm-hacker-news-scraper, gtm-product-hunt-scraper, gtm-youtube-watcher, gtm-youtube-apify-transcript

**ICP & Signals**: gtm-icp-persona-builder, gtm-icp-website-audit, gtm-icp-website-review, gtm-signal-scanner, gtm-signal-detection-pipeline, gtm-funding-signal-monitor, gtm-job-posting-intent, gtm-expansion-signal-spotter

**Source**: [goose-skills](https://github.com/athina-ai/goose-skills) (MIT license)
