# Module 0: Core Setup

> Adds Skill Auto-Discovery to your global CLAUDE.md so Claude proactively uses all installed skills.

## Copy this prompt into Claude Code:

```
Check if ~/.claude/CLAUDE.md exists. If not, create it.

Then check if it already contains "Skill Auto-Discovery". If yes, say "Already configured" and stop.

If not, append this exact block to the END of ~/.claude/CLAUDE.md:

## Skill Auto-Discovery (CRITICAL)
You have hundreds of installed skills, commands, and agents. Before starting ANY task, scan the available skills list for relevant matches. DO NOT ask the user to invoke skills manually — proactively use them.

### Skill Matching Rules
1. **Before writing code**: Check if a language/framework-specific skill exists (e.g., `nextjs-developer`, `fastapi-expert`, `react-expert`, `terraform-engineer`, `kubernetes-specialist`).
2. **Before debugging**: Use `systematic-debugging` or `debug-like-expert` skill.
3. **Before security work**: Use Trail of Bits skills (`semgrep`, `codeql`, `supply-chain-risk-auditor`, `insecure-defaults`, etc.).
4. **Before DevOps/Infra**: Use DevOps skills (`terraform-generator`, `dockerfile-generator`, `k8s-yaml-generator`, `helm-generator`, `github-actions-generator`, etc.).
5. **Before UI/UX work**: Use `ui-ux-pro-max`, `frontend-design`, `design-system`, `ui-styling` skills.
6. **Before planning**: Use `writing-plans`, `brainstorming`, or `plan` skill.
7. **Before code review**: Use `code-review`, `security-review`, or language-specific reviewer skills.
8. **Before testing**: Use `test-driven-development`, `tdd-workflow`, `e2e-testing`, or language-specific testing skills.
9. **Before marketing/content**: Match to CRO, SEO, copywriting, email skills as appropriate.
10. **Before deploying**: Use `pre-deploy`, `verification-loop`, `deployment-patterns`.

### How to Use Skills
- Invoke skills via the Skill tool with the skill name.
- If multiple skills are relevant, invoke the most specific one first.
- You can chain skills: plan → implement → test → review → deploy.

### Skill Categories Quick Reference
- **Languages**: nextjs, react, vue, angular, python, django, fastapi, rails, rust, go, swift, kotlin, java, springboot, laravel, php, cpp, csharp, flutter, typescript
- **DevOps**: terraform, k8s, helm, ansible, docker, jenkins, gitlab-ci, github-actions, azure-pipelines
- **Security**: semgrep, codeql, supply-chain, vulnerability scanners, fuzzing
- **Quality**: code-review, test-driven-development, verification-loop, e2e-testing, property-based-testing
- **Design**: ui-ux-pro-max, frontend-design, design-system, banner-design, brand, liquid-glass-design
- **Thinking**: tree-of-thoughts, root-cause-tracing, kaizen, critique, brainstorming, debate
- **Marketing**: copywriting, seo-audit, page-cro, signup-flow-cro, cold-email, content-strategy, ad-creative

After appending, confirm it was added and show the line count of CLAUDE.md.
```
