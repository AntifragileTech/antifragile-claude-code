# Module 1: Coding Rules

> Installs 29 rule files covering coding style, testing, security, git workflow, and language-specific patterns.

## Copy this prompt into Claude Code:

```
Clone https://github.com/AntifragileTech/antifragile-claude-code.git to /tmp/ccpp with --depth 1.

Then copy the rules from the repo into my Claude Code setup:

1. Create ~/.claude/rules/ if it doesn't exist
2. Copy all directories and files from /tmp/ccpp/assets/rules/ into ~/.claude/rules/
3. For each file: if it already exists in ~/.claude/rules/, SKIP it (never overwrite)
4. Report how many rule files were installed vs skipped

The rules are organized as:
- common/ — Universal coding principles (9 files)
- typescript/ — TypeScript-specific (5 files)
- python/ — Python-specific (5 files)
- golang/ — Go-specific (5 files)
- swift/ — Swift-specific (5 files)

After copying, clean up: rm -rf /tmp/ccpp
```
