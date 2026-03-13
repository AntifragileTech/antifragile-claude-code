# Module 6: DevOps & Infrastructure Skills

> Installs 46 skills for Terraform, Kubernetes, Docker, Ansible, CI/CD, and monitoring.

> **💡 Tip**: For Claude to auto-discover and proactively use these assets, also run **Module 0: Core Setup** — it adds a Skill Auto-Discovery rule to your CLAUDE.md so Claude matches skills to tasks automatically.


## Copy this prompt into Claude Code:

```
Clone https://github.com/AntifragileTech/antifragile-claude-code.git to /tmp/ccpp with --depth 1.

Then install DevOps skills:

1. For each directory in /tmp/ccpp/assets/skills/devops/, copy it to ~/.claude/skills/
2. If the skill directory already exists in ~/.claude/skills/, SKIP it (never overwrite)
3. Report: how many installed, how many skipped, total skills now in ~/.claude/skills/

After copying, clean up: rm -rf /tmp/ccpp
```

## What's Included (46 skills)

**Terraform**: terraform-engineer, terraform-generator, terraform-validator, terragrunt-generator, terragrunt-validator

**Kubernetes**: kubernetes-specialist, k8s-yaml-generator, k8s-yaml-validator, k8s-debug, helm-generator, helm-validator

**Docker**: dockerfile-generator, dockerfile-validator, docker-debug, docker-patterns, devcontainer-setup

**CI/CD**: github-actions-generator, github-actions-validator, gitlab-ci-generator, gitlab-ci-validator, jenkinsfile-generator, jenkinsfile-validator, azure-pipelines-generator, azure-pipelines-validator

**Ansible**: ansible-generator, ansible-validator

**Monitoring**: monitoring-expert, promql-generator, promql-validator, logql-generator, loki-config-generator, fluentbit-generator, fluentbit-validator

**General**: devops-engineer, sre-engineer, cloud-architect, chaos-engineer, deploy, deployment-patterns, pre-deploy, healthcheck, healthcheck-auto, bash-script-generator, bash-script-validator, makefile-generator, makefile-validator
