# ICM Workspace Design

**Interpreted Context Methodology** — build structured multi-stage AI workflows using folder structure instead of orchestration frameworks. One agent, reading the right files at the right moment, does what would otherwise need a multi-agent framework.

> Source: [RinDig/Interpreted-Context-Methdology](https://github.com/RinDig/Interpreted-Context-Methdology) by Jake Van Clief

---

## The Core Idea

Replace framework complexity with filesystem structure. Stage sequencing = folder numbering. Context scoping = folder hierarchy. State management = files on disk. Human review = editing output files between stages.

---

## Five-Layer Architecture

Agents read down the layers and stop when they have what they need:

```
Layer 0: CLAUDE.md           "Where am I?"         Always loaded (~800 tokens)
Layer 1: CONTEXT.md          "Where do I go?"       Read on entry (~300 tokens)
Layer 2: Stage CONTEXT.md    "What do I do?"         Read per-task (~200-500 tokens)
Layer 3: Reference material  "What rules apply?"     Loaded selectively (varies)
Layer 4: Working artifacts   "What am I working with?" Loaded selectively (varies)
```

- **Layer 3** = stable factory: design systems, voice rules, skill files, build conventions
- **Layer 4** = per-run product: previous stage outputs, user-provided source material

Total context per stage: **2,000–8,000 tokens** (vs 30,000–50,000 for monolithic approaches).

---

## Workspace Structure

```
workspace/
├── CLAUDE.md              # Layer 0 — folder map + routing table
├── CONTEXT.md             # Layer 1 — task routing
├── setup/
│   └── questionnaire.md   # One-time onboarding (configure the factory)
├── shared/                # Layer 3 — cross-stage reference files
├── skills/                # Layer 3 — bundled domain skills
├── [brand-vault]/         # Layer 3 — brand, voice, design config
└── stages/
    ├── 01-research/
    │   ├── CONTEXT.md     # Layer 2 — stage contract
    │   ├── references/    # Layer 3 — stage-specific rules
    │   └── output/        # Layer 4 — artifacts (handoff to next stage)
    ├── 02-script/
    │   ├── CONTEXT.md
    │   ├── references/
    │   └── output/
    └── 03-production/
        ├── CONTEXT.md
        ├── references/
        └── output/
```

---

## Stage Contract Format

Every stage `CONTEXT.md` follows this exact shape (keep under 80 lines):

```markdown
## Inputs
| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Previous stage | ../01-research/output/slug-research.md | Full file | Source material |
| Voice guide | ../../brand-vault/voice-rules.md | "Voice Rules" section | Tone |

## Process
1. Read inputs
2. [Do the stage's one job]
3. Run audit checklist
4. Save to output/

## Outputs
| Artifact | Location | Format |
|----------|----------|--------|
| Script | output/[slug]-script.md | Markdown |

## Audit
| Check | Pass Condition |
|-------|---------------|
| Follows voice rules | No banned phrases present |
```

---

## Key Patterns

**One stage, one job.** A stage that researches does not also write.

**Output folders are the handoff.** Stage N writes to `output/`. Stage N+1 reads from `../0N/output/`. Humans can edit output files between stages — the next stage picks up whatever is there.

**One-way references only.** If A references B, B never references A. Prevents circular dependencies.

**Selective section loading.** CONTEXT.md Inputs tables specify exact sections to load — not whole files. `voice-rules.md | "Voice Rules" section | Tone`. Keeps tokens low.

**Canonical sources.** Every rule has one home. Other files point there; they never duplicate.

**Docs over outputs.** Agents learn from reference docs (Layer 3), not previous outputs (Layer 4). Early outputs are the worst outputs — don't let future agents copy them.

**Questionnaire = configure the factory.** Onboarding sets brand, voice, design, preferences. It never asks about individual runs. Flat, all-at-once, never repeated.

**Placeholders syntax:** `{{SCREAMING_SNAKE_CASE}}` — replaced by onboarding agent. Conditional blocks: `{{?SECTION_NAME}} ... {{/SECTION_NAME}}`.

---

## Trigger Keywords (add to every workspace CLAUDE.md)

| Keyword | Action |
|---------|--------|
| `setup` | Run onboarding questionnaire, replace all `{{placeholders}}` |
| `status` | Scan all `output/` folders, render ASCII pipeline diagram |

---

## When to Use ICM

✅ Sequential workflows with human review at each step
✅ Repeatable pipelines (same stages, different input each run)
✅ Content production, course creation, report generation, code documentation

❌ Real-time multi-agent loops (needs message-passing, not files)
❌ High-concurrency systems (needs queueing infrastructure)
❌ Complex automated branching mid-pipeline

---

## Naming Conventions

- Folders and files: `lowercase-with-hyphens`
- Stage folders: zero-padded prefix: `01-`, `02-`, `03-`
- Output files: `[topic-slug]-[artifact-type].md`
- Placeholders: `{{SCREAMING_SNAKE_CASE}}`
- No spaces anywhere

---

## Quality Guardrails

- `CONTEXT.md` files: under 80 lines
- Reference files: under 200 lines (split if longer)
- Every empty folder that should persist: add `.gitkeep`
- No circular references between stages
- Zero placeholders remaining after `setup` completes
