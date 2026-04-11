# IAM & Identity Security Reference

## Tools Required
- `bloodhound` + `neo4j` — AD attack path visualization
- `impacket` — Kerberos attacks (authorized testing)
- `ldapsearch` / `ldapdomaindump` — AD enumeration
- `cyberark` / `sailpoint` — PAM/IGA platforms
- `okta-cli` — Okta administration
- `mimikatz` — credential extraction (authorized lab only)

---

## 1. Active Directory Audit
```bash
# Enumerate AD via ldapsearch
ldapsearch -x -H ldap://DC_IP -D "DOMAIN\user" -w PASSWORD \
  -b "DC=domain,DC=com" "(objectClass=user)" sAMAccountName memberOf

# ldapdomaindump: full AD dump
python3 ldapdomaindump.py -u DOMAIN\\user -p PASSWORD DC_IP

# Find users with no pre-auth required (ASREPRoasting targets)
ldapsearch ... "(userAccountControl:1.2.840.113556.1.4.803:=4194304)"

# Find Kerberoastable accounts (SPNs set)
ldapsearch ... "(&(objectClass=user)(servicePrincipalName=*))"

# BloodHound: attack path analysis
bloodhound-python -d DOMAIN -u user -p pass -c all -ns DC_IP
# Import JSON files into BloodHound UI
# Query: "Find Shortest Paths to Domain Admins"
```

---

## 2. Kerberoasting & Golden Ticket Detection
```bash
# Kerberoasting detection (SIEM query for Event ID 4769)
# Look for: TGS requested for service accounts, RC4 encryption used
# EventID 4769, TicketEncryptionType=0x17 (RC4) = suspicious

# ASREPRoasting
impacket-GetNPUsers DOMAIN/ -no-pass -usersfile users.txt -format hashcat

# Golden Ticket detection
# EventID 4624 with LogonType=3 + unusual source IP
# TGT lifetime > 10 hours (default max)

# DCSync attack detection (EventID 4662)
# Look for: replication rights on domain object, non-DC source
```
**Fix**: Enable AES encryption for Kerberos. Audit SPNs on service accounts. Set KRBTGT password rotation policy.

---

## 3. Active Directory Tiered Model
```
Tier 0: Domain Controllers, AD admin accounts, PKI — highest protection
Tier 1: Member servers (app servers, DBs) — elevated protection
Tier 2: Workstations, end-user devices — standard protection

Rules:
- Tier 0 admins NEVER log into Tier 1/2 systems
- Tier 0 accounts accessible only from PAWs (Privileged Access Workstations)
- Separate admin accounts per tier — no account crosses tiers
```
```bash
# Audit tier violations: Tier 0 accounts logging into Tier 2
# EventID 4624: check Tier 0 account names against Tier 2 computer names
Get-ADComputer -Filter * -Properties MemberOf | Where-Object {$_.MemberOf -like "*Tier2*"}
```

---

## 4. OAuth / SAML Security
```bash
# OAuth misconfiguration tests
# 1. State parameter missing → CSRF on OAuth flow
# 2. Redirect URI not validated → authorization code theft
# 3. Token leakage in Referer header
# 4. Scope creep: request minimal scope, test if broader scope accessible

# JWT testing (alg:none attack)
# Decode JWT: base64 -d <<< $(echo $TOKEN | cut -d. -f2)
# Modify alg to "none", remove signature, check if accepted

# SAML assertion replay
# Capture valid SAML response, replay with different NameID
# Check: NotOnOrAfter timestamp enforced?

# Detect suspicious OAuth consent (Azure)
az ad app list --query "[?requiredResourceAccess[].resourceAppId=='00000003-0000-0000-c000-000000000000']"
```
**Fix**: Validate redirect URIs strictly. Enforce state param. Short-lived tokens. Least-privilege OAuth scopes.

---

## 5. Zero Trust Implementation
```bash
# Cloudflare Access (SaaS Zero Trust)
# Policy: Identity (IdP) + Device Posture + Location
# Test: access protected app without valid device cert → should deny

# BeyondCorp model checks:
# 1. Device inventory complete and up to date?
# 2. User identity verified via MFA on every access?
# 3. Access granted per request, not per network?
# 4. All access logged and monitored?

# Tailscale (mesh VPN for Zero Trust)
tailscale status  # show all nodes
tailscale ping TARGET_NODE  # verify connectivity

# mTLS service-to-service
# Verify: services reject requests without valid client cert
curl --cert client.crt --key client.key https://service/endpoint
```

---

## 6. Privileged Access Management (PAM)
```bash
# CyberArk: audit privileged account usage
# Check: all admin accounts vaulted, passwords rotated on checkout
# Verify: session recording enabled for all privileged sessions

# AWS: Privileged Access Workstation enforcement
# Systems Manager Session Manager — no direct SSH
aws ssm start-session --target i-INSTANCE_ID

# Detect privileged account abuse
# EventID 4728/4732: member added to privileged group
# EventID 4756: member added to universal group
# Alert on: any Tier 0 group membership changes
```

---

## 7. Honeytokens / Deception
```bash
# Deploy AD honeytokens (fake privileged accounts)
# Create account: svc_backup_admin (attractive name, no real permissions)
# Alert on: any authentication attempt against honeytoken account
# EventID 4625 (failed) or 4624 (success) on honeytoken = attacker present
```

---

## Checklist Summary
- [ ] BloodHound run — no unintended paths to Domain Admin
- [ ] Kerberoasting: all service account passwords >25 chars, AES encryption
- [ ] ASREPRoasting: pre-auth required on all accounts
- [ ] AD tiered model enforced — no cross-tier logons
- [ ] OAuth: redirect URIs validated, state param enforced
- [ ] SAML: assertion replay prevented (timestamps enforced)
- [ ] JWT: alg:none rejected, signature validated
- [ ] Zero Trust: every access decision includes identity + device posture
- [ ] PAM: all admin accounts vaulted in CyberArk/similar
- [ ] Honeytokens deployed in AD
- [ ] KRBTGT password rotated in last 180 days
