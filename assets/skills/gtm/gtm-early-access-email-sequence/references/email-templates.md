# Email Templates Reference

These are the base templates for the 7-email onboarding sequence. The agent personalizes each one using research from Phase 1. Variables in `{{double_braces}}` are replaced with real data. Sections marked `[PERSONALIZE]` require the agent to generate unique content based on research.

---

## Email 1 — Welcome + Quick Start
**Day:** 0 (immediate) | **Personalized:** Light | **Goal:** First workflow within 24 hours

**Subject:** You're in — here's how to get started in 2 minutes

**Body:**
```
Hey {{first_name}},

You're in. Welcome to Goose early access.

Here's the fastest way to see what it can do:

→ Run your first workflow [link]

It takes about 2 minutes. Pick a workflow, point it at your company (or a competitor), and let it run. You'll get a real output — not a demo, not a sample.

A few things to know:
- This is early. Some things will be rough. That's why you're here — your feedback shapes what this becomes.
- I read every reply to this email. If something breaks, confuses you, or impresses you — just hit reply.
- If you want to walk through it together, grab 15 minutes on my calendar: {{calendly_link}}

Talk soon,
{{sender_name}}
```

**Personalization notes:** Light touch. Use first name. No role-specific content. Universal.

---

## Email 2 — Personalized Use Case #1
**Day:** 2 | **Personalized:** Heavy (by role + company) | **Goal:** Drive a second session with a role-specific workflow

**Subject:** A workflow built for what you actually do

### Sales variant
```
Hey {{first_name}},

Quick one — since you're on the sales side at {{company}}, there's a workflow you should try:

Signal-Triggered Outbound

Goose monitors for buying signals — job changes, funding rounds, champion moves — and auto-generates personalized outreach for each one. Not templates. Actual personalized messages based on the signal + account research.

Here's what it looks like:
1. A signal fires (e.g., your prospect's VP Sales just left)
2. Goose researches the account and the new person in the role
3. It crafts a message that references the transition and ties it to your value prop
4. You review, approve, and send

→ Try it here [link]

[PERSONALIZE: Add 1-2 sentences connecting this workflow to something specific about their company's sales motion. E.g., if they sell to enterprise, mention signal detection at scale. If they're early-stage, mention replacing an SDR hire.]

{{sender_name}}
```

### Marketing variant
```
Hey {{first_name}},

Since you're on the marketing side at {{company}}, there's a workflow that'll be immediately useful:

SEO Content Audit

Goose crawls your site and your competitors' sites, maps your keyword coverage, identifies the gaps, and gives you a prioritized list of what to write next — backed by actual data, not guesses.

It takes about 3 minutes to run. You'll get:
- Your full content inventory with traffic estimates
- Head-to-head keyword gap matrix vs. 2-3 competitors
- Prioritized content recommendations ranked by opportunity size

→ Run it on {{company_domain}} [link]

[PERSONALIZE: Reference something specific about their content/SEO situation. E.g., "I noticed {{company}} has a solid blog but the comparison pages are thin — the audit will show exactly which competitor keywords to target."]

{{sender_name}}
```

### Growth / RevOps variant
```
Hey {{first_name}},

Since you're running growth/ops at {{company}}, this one's for you:

GTM Audit

Goose analyzes your entire GTM motion — content footprint, SEO visibility, competitor positioning, hiring signals, social presence, ad activity — and gives you a scored report with a white space map showing where the opportunities are.

Takes about 3 minutes. You'll get a full diagnostic without hiring a consultant.

→ Run a GTM audit on {{company_domain}} [link]

[PERSONALIZE: Reference something specific about their GTM motion you found during research. E.g., "Given {{company}}'s move into enterprise, the audit's competitive positioning section will be especially useful."]

{{sender_name}}
```

### Founder variant
```
Hey {{first_name}},

As a founder, you probably don't have time for a 3-week GTM audit. So we made it take 3 minutes:

GTM Audit

Goose analyzes your content, SEO, competitors, hiring signals, social presence, and ad activity — then gives you a scored report showing exactly where you're strong, where you're exposed, and what to prioritize next.

It's the kind of analysis an agency charges $5-10K for. Takes 3 minutes.

→ Run it on {{company_domain}} [link]

[PERSONALIZE: Reference something specific about their company's stage or market. E.g., "Post Series A, the white space map tends to surface 2-3 channels your competitors own that you haven't touched yet."]

{{sender_name}}
```

---

## Email 3 — Nudge / Check-in
**Day:** 5 | **Personalized:** Light | **Goal:** Get a reply

**Subject:** Quick question

**Body (default — assume not activated, since activation status unknown at generation time):**
```
Hey {{first_name}},

No pressure — just checking in. Did you get a chance to try a workflow?

If you got stuck or weren't sure where to start, just reply and I'll point you to the right one for {{company}}. Takes 2 minutes.

Or if it's just not the right time, that's fine too — I'll stop nudging.

{{sender_name}}
```

**Activated variant (use this if the user completed a workflow before Day 5):**
```
Hey {{first_name}},

Saw you ran {{workflow_name}} — nice. Quick question:

What made you pick that one first?

I'm asking everyone in early access this because the answer tells me a lot about what to build next. One line is fine.

{{sender_name}}
```

**Note:** Generate the default (not-activated) version. Add a note that the sender should swap to the activated variant if the user has completed a workflow by Day 5.

---

## Email 4 — Personalized Use Case #2
**Day:** 8 | **Personalized:** Heavy (by role + company) | **Goal:** Expand usage

**Subject:** One more thing to try

### Sales variant
```
Hey {{first_name}},

One more workflow you'd find useful — Meeting Prep.

Before every sales call, Goose auto-researches every attendee: their background, recent LinkedIn activity, company news, competitive context, and potential pain points. Delivered to your inbox before the meeting starts.

It's the research your AEs should be doing but don't have time for.

→ Set it up here [link]

[PERSONALIZE: Connect to their sales motion. E.g., "With {{company}} selling into {{vertical}}, the competitive context section will be especially useful — it pulls in what tools your prospects are currently using."]

{{sender_name}}
```

### Marketing variant
```
Hey {{first_name}},

Another one worth trying — Competitor Content Tracking.

Goose monitors your competitors' blogs, social posts, ads (Meta + Google), and review sites — then sends you a weekly brief with what changed, what's working for them, and what it means for your strategy.

Set it once, get a competitive intel brief every week without lifting a finger.

→ Set it up here [link]

[PERSONALIZE: Name specific competitors. E.g., "I'd start by tracking {{competitor_1}} and {{competitor_2}} — the ad monitoring alone will show you what messaging they're testing."]

{{sender_name}}
```

### Growth / RevOps variant
```
Hey {{first_name}},

Another workflow that fits your world — Event Prospecting.

Goose scrapes attendee lists from industry events (Luma, conference websites), qualifies them against your ICP, enriches with contact data, and exports a ready-to-outreach lead list.

Next time there's a relevant event in your space, point Goose at it and let it find the leads.

→ Try it here [link]

[PERSONALIZE: Mention a specific event or conference relevant to their industry. E.g., "If {{company}} is going to SaaStr this year, you could have a qualified lead list from the attendee directory in 10 minutes."]

{{sender_name}}
```

### Founder variant
```
Hey {{first_name}},

If you tried the GTM audit, here's the natural next step — Outbound Engine.

Goose monitors for buying signals across your target market — funding rounds, key hires, job postings that mention your category — then auto-generates personalized outreach for each signal.

It's like having an SDR who never sleeps and actually does the research.

→ Set it up here [link]

[PERSONALIZE: Reference their ICP or target market. E.g., "For {{company}} selling to {{target_segment}}, the job posting signals tend to be the highest-converting — they show active buying intent."]

{{sender_name}}
```

---

## Email 5 — Community Spotlight
**Day:** 10 | **Personalized:** No | **Goal:** Social proof

**Subject:** What early users are doing with Goose

**Body (TEMPLATE — must be filled with real usage data at send time):**
```
Hey {{first_name}},

We're two weeks into early access. Here's what people are actually using Goose for:

Most popular workflows:
1. {{top_workflow}} — {{X}} runs so far
2. {{second_workflow}} — {{Y}} runs
3. {{third_workflow}} — {{Z}} runs

A few things that surprised us:
- {{real_observation_1}}
- {{real_observation_2}}
- {{real_observation_3}}

If you haven't tried it yet, now's a good time — the product is measurably better than it was 10 days ago thanks to this group's feedback.

→ Jump in [link]

{{sender_name}}
```

**IMPORTANT:** Do NOT generate personalized content for this email. Output it as a template with clear placeholders. The sender must fill it with real data on Day 10. If there's not enough usage data by Day 10, skip this email entirely.

---

## Email 6 — Skills Page Feature Drop
**Day:** 12 | **Personalized:** No | **Goal:** Feature launch, drive return visit

**Subject:** New: browse every workflow Goose can run

**Body:**
```
Hey {{first_name}},

We just shipped something I think you'll like — the Skills Page.

It's a browsable library of every workflow Goose can execute, organized by what you're trying to accomplish:

- Find leads — event attendees, hiring signals, competitor audiences, pain-language scrapers
- Research — competitor intel, SEO audits, GTM analysis, industry scanning
- Create — outbound sequences, content, meeting briefs, campaign assets
- Monitor — competitor content, buying signals, review sites, newsletters

Each skill shows what it does, what inputs it needs, and what you'll get back. Think of it as the menu.

→ Browse the Skills Page [link]

If you see something that would be useful but doesn't exist yet — reply and tell me. We're building based on what early users ask for.

{{sender_name}}
```

---

## Email 7 — Feedback Ask
**Day:** 14 | **Personalized:** Light | **Goal:** Book a feedback call

**Subject:** 15 minutes — would mean a lot

**Body (default — assume not activated):**
```
Hey {{first_name}},

Honest question — what kept you from trying Goose?

No judgment. Understanding why people don't use something is just as valuable as understanding why they do. If you have 30 seconds, just reply with one of these:

- Didn't have time — totally get it
- Tried it, got confused — I want to fix that
- Not relevant to what I'm doing right now — fair enough
- Something else — I'm all ears

And if you'd rather just chat for 15 minutes: {{calendly_link}}

Appreciate it either way.

{{sender_name}}
```

**Activated variant (use if user completed a workflow):**
```
Hey {{first_name}},

You've been using Goose for two weeks now and I'd genuinely love to hear your take.

Not a sales conversation — I want to understand:
- What worked and what didn't
- What you expected that wasn't there
- Whether you'd use this regularly or not (and why)

15 minutes. I'll share what we're building next and you can tell me if we're headed in the right direction.

→ Grab a time {{calendly_link}}

Either way — thanks for being one of the first people to try this. It's genuinely better because of the early access group.

{{sender_name}}
```

**Note:** Same as Email 3 — generate the default version, add a note to swap if the user is active by Day 14.
