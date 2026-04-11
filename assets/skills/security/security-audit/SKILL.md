---
name: security-audit
description: >
  Comprehensive security audit orchestrator. Auto-triggers for: security testing, vulnerability assessment,
  penetration testing, security review, hardening, CVE analysis, auth/access control review, CI/CD security,
  cloud security posture, container security, or any task involving "is this secure", "audit for vulnerabilities",
  "security check", "pentest", "harden", or "find security issues". Routes to the relevant domain reference
  based on what is being tested: web apps, cloud infra, Kubernetes/containers, IAM/identity, or DevSecOps pipelines.
domain: security
tags: [security, pentest, audit, vulnerability, hardening, devsecops, cloud-security, k8s, iam, web-app]
version: "1.0"
---

# Security Audit Skill

## Overview

This skill orchestrates security audits across five domains. Based on what is in scope,
load the relevant reference file(s) and execute the checks within them.

## Domain Routing

| What you're testing | Reference file to load |
|---|---|
| Web app, APIs, XSS, SQLi, OWASP | `references/web-app.md` |
| AWS, Azure, GCP, cloud config | `references/cloud.md` |
| Kubernetes, containers, Docker | `references/kubernetes.md` |
| Active Directory, IAM, OAuth, Zero Trust | `references/iam.md` |
| CI/CD pipeline, secrets, SAST/DAST, dependencies | `references/devsecops.md` |

Load multiple reference files when the scope crosses domains (e.g., a cloud-native app on K8s = cloud + kubernetes + devsecops).

## Execution Workflow

### Step 1 — Scope Definition
Identify what is being tested:
- Application type (web, API, mobile, desktop)
- Infrastructure (cloud provider, container platform)
- Pipeline (CI/CD, IaC, dependency management)
- Identity systems (AD, OAuth, SSO, PAM)

### Step 2 — Load Reference(s)
Read the relevant reference file(s) from `references/`. Each contains:
- Tool commands to run
- What to look for
- Fix recommendations
- A checklist

### Step 3 — Execute Checks
Run through the checklist items systematically. For each check:
1. Run the tool/command
2. Record finding (PASS / FAIL / INFO)
3. Note severity: CRITICAL / HIGH / MEDIUM / LOW
4. Note remediation if FAIL

### Step 4 — Report Findings
Output a structured table:

| # | Domain | Finding | Severity | Status | Remediation |
|---|---|---|---|---|---|
| 1 | K8s | Wildcard RBAC on prod namespace | CRITICAL | FAIL | Remove * verbs, use least-privilege role |
| 2 | Web | CSRF token missing on /api/transfer | HIGH | FAIL | Add CSRF middleware |
| 3 | Cloud | CloudTrail not enabled in us-west-2 | HIGH | FAIL | Enable multi-region trail |
| 4 | DevSecOps | No secret scanning in pre-commit | MEDIUM | FAIL | Install gitleaks hook |
| 5 | IAM | MFA enforced on all users | - | PASS | - |

### Step 5 — Prioritized Remediation
List CRITICALs first, then HIGHs. For each:
- Exact file/config/command to fix
- Time to fix estimate (quick win vs project)
- Whether it blocks deployment

## Authorization Reminder

**CRITICAL**: Only execute active testing (sqlmap, nmap, pacu, impacket) against:
- Systems you own
- Systems you have explicit written authorization to test

Passive checks (config review, code scanning, manifest analysis) are always safe.
Active scanning without authorization is illegal in most jurisdictions.

## Reference Files

- [Web App Security](references/web-app.md) — SQLi, XSS, CSRF, API OWASP Top 10
- [Cloud Security](references/cloud.md) — AWS/Azure/GCP posture, IAM, CloudTrail
- [Kubernetes & Container Security](references/kubernetes.md) — RBAC, image scanning, Falco, network policies
- [IAM & Identity Security](references/iam.md) — Active Directory, OAuth/SAML, Zero Trust, PAM
- [DevSecOps](references/devsecops.md) — Secret scanning, SAST, SCA, DAST, supply chain
