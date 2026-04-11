# DevSecOps Security Reference

## Tools Required
- `gitleaks` — secret scanning in git repos
- `semgrep` — SAST (custom rules)
- `trivy` / `grype` — SCA + container scanning
- `snyk` — dependency vulnerability scanning
- `owasp-zap` — DAST in pipeline
- `checkov` / `tfsec` — IaC security
- `in-toto` — supply chain attestation
- `nessus` / `openvas` — vulnerability scanning
- `gitleaks` — secrets in git history

---

## 1. Secret Scanning (Gitleaks)
```bash
# Scan entire git history for secrets
gitleaks detect --source . --report-format json --report-path gitleaks-report.json

# Pre-commit hook (prevent secrets reaching repo)
# .pre-commit-config.yaml:
# - repo: https://github.com/zricethezav/gitleaks
#   hooks:
#     - id: gitleaks

# GitHub Actions integration
# - uses: gitleaks/gitleaks-action@v2
#   env:
#     GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

# Custom rules for org-specific tokens
# gitleaks.toml: add [[rules]] for internal API key patterns

# Baseline: ignore already-known historical secrets
gitleaks detect --baseline-path gitleaks-baseline.json
```
**Fix**: Rotate any exposed credential immediately. Add to .gitignore. Use env vars or secret managers.

---

## 2. SAST — Semgrep
```bash
# Run OWASP Top 10 rules
semgrep --config=p/owasp-top-ten .

# Run security audit ruleset
semgrep --config=p/security-audit .

# CI/CD integration (GitHub Actions)
# - uses: returntocorp/semgrep-action@v1
#   with:
#     config: p/ci

# Custom rule for hardcoded passwords
# rules:
#   - id: hardcoded-password
#     patterns:
#       - pattern: password = "..."
#     message: Hardcoded password detected
#     severity: ERROR
```

---

## 3. SCA — Dependency Scanning
```bash
# Snyk: scan dependencies
snyk test --severity-threshold=high
snyk monitor  # continuous monitoring

# Trivy: filesystem scan (deps + secrets + misconfigs)
trivy fs . --severity HIGH,CRITICAL

# SBOM generation and analysis
# Generate SBOM
trivy fs . --format cyclonedx --output sbom.json

# Analyze SBOM for vulnerabilities
trivy sbom sbom.json

# Supply chain: verify integrity
# in-toto: sign and verify each pipeline step
in-toto-run --name build --products dist/ -- npm run build
in-toto-verify --layout root.layout --layout-keys key.pub
```

---

## 4. DAST — OWASP ZAP in Pipeline
```bash
# ZAP baseline scan (passive, no attacks)
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t https://target.com -r zap-report.html

# ZAP full scan (active attacks — staging only)
docker run -t owasp/zap2docker-stable zap-full-scan.py \
  -t https://staging.target.com -r full-report.html

# GitHub Actions integration
# - uses: zaproxy/action-baseline@v0.7.0
#   with:
#     target: 'https://staging.target.com'
```

---

## 5. IaC Security Scanning
```bash
# checkov: Terraform, CloudFormation, Kubernetes manifests
checkov -d ./terraform --framework terraform --output junitxml
checkov -f k8s-deployment.yaml --framework kubernetes

# tfsec: Terraform-specific
tfsec ./terraform --format json

# kubesec: Kubernetes manifest scoring
kubesec scan deployment.yaml

# Fail pipeline on HIGH severity
checkov -d . --soft-fail-on MEDIUM --hard-fail-on HIGH
```

---

## 6. Supply Chain Attack Detection
```bash
# Detect typosquatting in dependencies
# npm: check for similar package names
npm audit
npx npm-check-updates --doctor

# Verify package integrity
npm ci  # uses package-lock.json — verifies checksums
pip install --require-hashes -r requirements.txt

# GitHub Actions: pin to commit SHA (not tag)
# BAD:  uses: actions/checkout@v3
# GOOD: uses: actions/checkout@abc123def456

# Detect supply chain compromise in CI/CD
# Look for: unexpected network calls during build
# Log build-time DNS queries, outbound connections
```

---

## 7. GitHub Advanced Security
```bash
# Enable code scanning (SARIF output)
gh api repos/ORG/REPO/code-scanning/analyses

# Secret scanning: check for detected secrets
gh api repos/ORG/REPO/secret-scanning/alerts

# Dependabot: automated dependency PRs
# .github/dependabot.yml:
# version: 2
# updates:
#   - package-ecosystem: npm
#     directory: /
#     schedule: weekly
```

---

## 8. Vulnerability Scanning
```bash
# Nessus: authenticated scan
# Policy: Advanced Scan → credentials → target
# Post-scan: filter by CVSS ≥ 7.0, export CSV

# OpenVAS / Greenbone
gvm-cli --gmp-username admin --gmp-password pass socket \
  --xml "<create_task><name>Audit</name>...</create_task>"

# Nmap advanced
nmap -sV -sC -O --script vuln TARGET_IP
nmap -p- --min-rate 5000 TARGET_IP   # all ports fast
```

---

## Checklist Summary
- [ ] Gitleaks pre-commit hook installed on all repos
- [ ] Semgrep SAST running in CI — zero HIGH/CRITICAL
- [ ] Dependencies scanned (Snyk/Trivy) — zero CRITICAL CVEs
- [ ] SBOM generated and stored per release
- [ ] DAST (ZAP) running against staging on every deploy
- [ ] IaC scanned with checkov before apply
- [ ] GitHub Actions pinned to commit SHAs
- [ ] Supply chain: package-lock.json / pip hashes enforced
- [ ] GitHub Advanced Security enabled
- [ ] Vulnerability scan monthly — findings SLA: CRITICAL 24h, HIGH 7d
