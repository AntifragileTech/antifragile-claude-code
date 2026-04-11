# /email-preview — SendGrid Email Template Debugging Skill

## Trigger
User says: "email-preview", "test email", "email template", "sendgrid debug", "email not sending", "preview email"

## Purpose
Debug and preview SendGrid email templates in the backend.

## Steps

### 1. Find Email Templates
```bash
# Locate email-related code
grep -rn "sendgrid\|@sendgrid\|sgMail\|MailService" --include="*.ts" --include="*.tsx" -l
# Find template files
find . -path "*/email*" -o -path "*/mail*" | grep -E "\.(ts|tsx|html|hbs)$"
# Find email sending functions
grep -rn "sgMail.send\|sendMail\|sendEmail" --include="*.ts" -l
```

### 2. Configuration Check
```bash
# Verify SendGrid env vars
env | grep SENDGRID
# Check API key is set (don't print the full key)
echo $SENDGRID_API_KEY | head -c 10
```
- Verify sender email is configured and verified in SendGrid
- Check for `from` address in email config

### 3. Template Inspection
- Read the email template/function the user is working on
- Check for:
  - Dynamic variables are properly interpolated
  - HTML is well-formed (no unclosed tags)
  - Inline CSS (email clients don't support external stylesheets)
  - Images use absolute URLs (not relative paths)
  - Unsubscribe link is present (required for marketing emails)

### 4. Email Log Check
```bash
# Check email_logs table — uses sent_at NOT created_at
# First verify schema
npx prisma db execute --stdin <<< "SELECT column_name FROM information_schema.columns WHERE table_name = 'email_logs' LIMIT 20;"
# Then query recent logs
npx prisma db execute --stdin <<< "SELECT * FROM email_logs ORDER BY sent_at DESC LIMIT 5;"
```
- CRITICAL: `email_logs` uses `sent_at` column, NOT `created_at`
- Check for failed sends, bounces, or blocks

### 5. Test Send
- Suggest using SendGrid's test mode or a test recipient
- Generate a curl command for manual testing:
```bash
# Template for test send (user fills in details)
curl --request POST \
  --url https://api.sendgrid.com/v3/mail/send \
  --header "Authorization: Bearer $SENDGRID_API_KEY" \
  --header 'Content-Type: application/json' \
  --data '{"personalizations":[{"to":[{"email":"TEST_EMAIL"}]}],"from":{"email":"FROM_EMAIL"},"subject":"Test","content":[{"type":"text/html","value":"<p>Test</p>"}]}'
```

### 6. Common Issues
- **429 rate limit**: Check if too many emails sent in short period
- **403 forbidden**: API key doesn't have send permission
- **Bounced**: Recipient email invalid or mailbox full
- **Spam folder**: Check sender reputation, SPF/DKIM records
- **Template not rendering**: Variables not passed to template function

## Rules
- NEVER send to real users during debugging — always use test recipients
- NEVER log or echo full SendGrid API keys
- Always check `email_logs.sent_at` (NOT `created_at`) for send history
- Verify test/production mode before any send operations
