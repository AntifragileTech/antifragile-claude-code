# Web Application Security Reference

## Tools Required
- `burpsuite` — proxy, scanner, intruder
- `sqlmap` — SQL injection automation
- `nikto` — web server scanner
- `subfinder` / `amass` — subdomain enumeration
- `nuclei` — template-based vuln scanning
- `owasp-zap` — DAST in CI/CD
- `postman` / `42crunch` — API security testing
- `ffuf` — fuzzing

---

## 1. SQL Injection
```bash
# sqlmap automated scan
sqlmap -u "https://target.com/page?id=1" --dbs
sqlmap -r request.txt --level=5 --risk=3   # from Burp saved request
# Second-order: inject into profile fields, observe on next query
```
Payloads to test: single quote, OR 1=1, WAITFOR DELAY, UNION SELECT.
**Fix**: Parameterized queries only. Never string-concatenate SQL. WAF as defence-in-depth.

---

## 2. XSS (Cross-Site Scripting)
```bash
# DOM-based: check client-side JS for unsafe sinks
grep -r "innerHTML\|outerHTML" src/

# CSP check
curl -I https://target.com | grep Content-Security-Policy
# Weak: unsafe-inline, unsafe-eval, wildcard * sources
```
Test: reflected (URL params), stored (comments/usernames), DOM (client-side sinks).
Use XSS Hunter for blind/out-of-band verification.
**Fix**: Output-encode all user data per context. CSP with nonces. HttpOnly + Secure cookies.

---

## 3. CSRF
```bash
# Test: replay POST without CSRF token via Burp Repeater. 200 OK = vulnerable.
curl -I https://target.com | grep -i "set-cookie"
# Should see: SameSite=Strict or SameSite=Lax
```
**Fix**: CSRF tokens on all state-changing forms. SameSite=Strict on session cookies.

---

## 4. API Security (OWASP API Top 10)
```bash
# API1 - BOLA: change resource ID to another user's
#   GET /api/users/123/orders → /api/users/124/orders

# API3 - Mass Assignment: send extra fields
#   POST /api/users  body: {"username":"x","role":"admin"}

# GraphQL introspection check
curl -X POST https://target.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{__schema{types{name}}}"}'
# Should return 400/disabled in prod

# 42crunch / Postman: import OpenAPI spec, run security audit
```
Test coverage: BOLA, broken auth (alg:none JWT), mass assignment, function-level auth bypass.
**Fix**: Validate permissions on every request. Whitelist writable fields. Disable introspection in prod.

---

## 5. HTTP Request Smuggling
Use Burp "HTTP Request Smuggler" extension for automated CL.TE / TE.CL desync detection.
**Fix**: Normalize headers at reverse proxy. Reject ambiguous requests.

---

## 6. WAF Bypass Techniques
```bash
nuclei -t waf-bypass/ -u https://target.com
```
Common bypass patterns: URL encoding, case variation, comment-based whitespace substitution.

---

## 7. Subdomain Enumeration
```bash
subfinder -d target.com -o subdomains.txt
amass enum -d target.com
cat subdomains.txt | httpx -status-code | grep "404"   # dangling CNAME check
nuclei -l subdomains.txt -t exposures/ -t vulnerabilities/
```

---

## 8. Threat Modeling
```bash
docker run -it -p 3000:3000 owasp/threat-dragon
```
Process: DFD → trust boundaries → STRIDE (Spoofing, Tampering, Repudiation, Info Disclosure, DoS, Elevation) → risk rating → mitigations.

---

## Checklist Summary
- [ ] All input params tested for SQLi (manual + sqlmap)
- [ ] All output contexts tested for XSS (reflected, stored, DOM)
- [ ] CSRF tokens on all state-changing requests
- [ ] API: BOLA, auth bypass, mass assignment tested
- [ ] GraphQL introspection disabled in prod
- [ ] No HTTP request smuggling (CL/TE desync)
- [ ] Subdomain enumeration done — no dangling CNAMEs
- [ ] Security headers: CSP, X-Frame-Options, HSTS
- [ ] WAF bypass attempts tested
- [ ] OWASP ZAP in CI/CD pipeline
