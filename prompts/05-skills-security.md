# Module 5: Security Skills

> Installs 40 security skills including Trail of Bits tools, vulnerability scanners, and fuzzing frameworks.

> **💡 Tip**: For Claude to auto-discover and proactively use these assets, also run **Module 0: Core Setup** — it adds a Skill Auto-Discovery rule to your CLAUDE.md so Claude matches skills to tasks automatically.


## Copy this prompt into Claude Code:

```
Clone https://github.com/AntifragileTech/antifragile-claude-code.git to /tmp/ccpp with --depth 1.

Then install security skills:

1. For each directory in /tmp/ccpp/assets/skills/security/, copy it to ~/.claude/skills/
2. If the skill directory already exists in ~/.claude/skills/, SKIP it (never overwrite)
3. Report: how many installed, how many skipped, total skills now in ~/.claude/skills/

After copying, clean up: rm -rf /tmp/ccpp
```

## What's Included (40 skills)

**Static Analysis**: semgrep, semgrep-rule-creator, semgrep-rule-variant-creator, codeql, sarif-parsing, variant-analysis

**Fuzzing**: aflpp, libfuzzer, libafl, atheris, cargo-fuzz, ruzzy, ossfuzz, fuzzing-dictionary, fuzzing-obstacles, wycheproof

**Vulnerability Scanners**: solana-vulnerability-scanner, cairo-vulnerability-scanner, algorand-vulnerability-scanner, cosmos-vulnerability-scanner, substrate-vulnerability-scanner, ton-vulnerability-scanner, firebase-apk-scanner

**Supply Chain**: supply-chain-risk-auditor, insecure-defaults, sharp-edges, token-integration-analyzer

**Code Security**: secure-code-guardian, secure-workflow-guide, security-review, security-reviewer, security-scan, seatbelt-sandboxer

**Crypto**: constant-time-analysis, constant-time-testing, fp-check, zeroize-audit, address-sanitizer

**Other**: burpsuite-project-parser, yara-rule-authoring, dwarf-expert
