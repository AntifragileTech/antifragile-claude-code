# Cloud Security Reference (AWS / Azure / GCP)

## Tools Required
- `aws-cli` + `scout-suite` — AWS enumeration & assessment
- `pacu` — AWS exploitation framework (authorized testing)
- `trufflehog` — credential/secret detection in AWS
- `prowler` — AWS/Azure/GCP CIS benchmarks
- `checkov` — IaC security scanning
- `azure-cli` — Azure resource auditing
- `gcloud` — GCP resource auditing
- `forseti` — GCP security assessment

---

## 1. AWS S3 Bucket Audit
```bash
# List all buckets and ACLs
aws s3api list-buckets
aws s3api get-bucket-acl --bucket BUCKET_NAME
aws s3api get-bucket-policy --bucket BUCKET_NAME

# Check public access block settings
aws s3api get-public-access-block --bucket BUCKET_NAME
# All four should be: true

# Find public buckets (account-level)
aws s3control get-public-access-block --account-id $(aws sts get-caller-identity --query Account --output text)

# Remediate misconfiguration
aws s3api put-public-access-block --bucket BUCKET_NAME \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

---

## 2. AWS IAM Privilege Escalation
```bash
# Scout Suite: full AWS assessment
python3 scout.py aws --report-dir ./report

# Detect credential exposure
trufflehog github --repo https://github.com/org/repo
trufflehog filesystem --directory ./

# Check for over-privileged roles
aws iam get-account-authorization-details > iam_dump.json
# Look for: AdministratorAccess, *, Action:iam:*

# GuardDuty automation: auto-remediate findings
aws guardduty list-findings --detector-id $DETECTOR_ID
aws guardduty get-findings --detector-id $DETECTOR_ID --finding-ids $FINDING_ID

# Privilege escalation paths (pacu - authorized only)
python3 pacu.py  # then: run iam__privesc_scan
```
**Fix**: Use permission boundaries. Enforce least privilege. Enable GuardDuty + Security Hub.

---

## 3. AWS CloudTrail Anomaly Detection
```bash
# Check CloudTrail is enabled in all regions
aws cloudtrail describe-trails
aws cloudtrail get-trail-status --name TRAIL_NAME

# Query for suspicious activity (Athena)
SELECT eventTime, userIdentity.arn, eventName, sourceIPAddress
FROM cloudtrail_logs
WHERE eventName IN ('ConsoleLogin','CreateUser','AttachUserPolicy','PutBucketPolicy')
  AND errorCode IS NULL
ORDER BY eventTime DESC LIMIT 100;

# AWS Security Hub compliance check
aws securityhub get-findings --filters '{"ComplianceStatus":[{"Value":"FAILED","Comparison":"EQUALS"}]}'
```

---

## 4. Azure Security Audit
```bash
# Azure Activity Log: detect lateral movement
az monitor activity-log list --start-time 2024-01-01 \
  --query "[?operationName.value=='Microsoft.Authorization/roleAssignments/write']"

# Azure AD: find privileged role members
az ad group member list --group "Global Administrators"
az role assignment list --all --query "[?roleDefinitionName=='Owner']"

# Detect storage misconfigurations
az storage account list --query "[?allowBlobPublicAccess==true]"

# Microsoft Defender for Cloud recommendations
az security assessment list --query "[?status.code=='Unhealthy']"

# Conditional Access Policies audit
az ad conditional-access policy list
# Check: MFA enforcement, device compliance, location restrictions
```

---

## 5. GCP Security Assessment
```bash
# IAM permissions audit
gcloud projects get-iam-policy PROJECT_ID --format=json

# Check for overly-permissive service accounts
gcloud iam service-accounts list
gcloud iam service-accounts get-iam-policy SA_EMAIL

# GCP Organization Policy constraints
gcloud org-policies list --organization=ORG_ID

# Forseti: full GCP assessment
forseti inventory create
forseti scanner run
forseti violation list

# GCPBucketBrute: enumerate public buckets (authorized)
python3 gcpbucketbrute.py -k KEYWORD -u
```

---

## 6. Cloud Incident Response
```bash
# AWS: isolate compromised EC2
aws ec2 modify-instance-attribute --instance-id i-xxxx \
  --groups sg-isolated  # security group with no ingress/egress

# Preserve evidence
aws ec2 create-snapshot --volume-id vol-xxxx --description "IR-$(date +%Y%m%d)"

# Revoke active sessions
aws iam delete-access-key --access-key-id AKIAXXXX --user-name USERNAME

# CloudTrail forensics
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=Username,AttributeValue=SUSPECT_USER \
  --start-time 2024-01-01 --end-time 2024-01-07
```

---

## 7. IaC Security (Terraform / CloudFormation)
```bash
# checkov: scan Terraform for misconfigs
checkov -d ./terraform --framework terraform

# checkov: CloudFormation
checkov -f template.yaml --framework cloudformation

# tfsec: Terraform security scanner
tfsec ./terraform

# Prowler: CIS benchmarks across AWS/Azure/GCP
prowler aws --compliance cis_1.5_aws
prowler azure --compliance cis_2.0_azure
```

---

## Checklist Summary
- [ ] S3 buckets: public access block enabled on all
- [ ] CloudTrail enabled in all regions, logs encrypted
- [ ] GuardDuty enabled, findings actioned
- [ ] No root account API keys
- [ ] MFA enforced on all IAM users
- [ ] Security Hub: zero CRITICAL/HIGH findings
- [ ] Azure AD: no users with Global Admin unnecessarily
- [ ] Azure Defender for Cloud enabled
- [ ] GCP: org policies enforce no external IPs, no public buckets
- [ ] IaC scanned with checkov/tfsec before deploy
- [ ] Credential exposure scan (trufflehog) on all repos
