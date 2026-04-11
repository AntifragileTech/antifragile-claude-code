# /stripe-debug — Stripe Integration Debugging Skill

## Trigger
User says: "stripe-debug", "payment issue", "webhook failing", "subscription problem", "billing debug", "stripe error"

## Purpose
Debug Stripe billing, webhooks, and subscription issues in the codebase.

## Steps

### 1. Configuration Check
```bash
# Verify environment variables are set
env | grep STRIPE
# Check for test vs live mode
echo $STRIPE_SECRET_KEY | head -c 7  # Should show sk_test_ or sk_live_
```
- Verify `tax_id_collection` is configured (known requirement in this codebase)
- Verify `customer_update[address]` is set (known requirement)

### 2. Webhook Debugging
```bash
# List recent webhook events (requires Stripe CLI)
stripe events list --limit 10
# Listen to webhooks locally
stripe listen --forward-to localhost:PORT/api/webhooks/stripe
# Trigger a test event
stripe trigger checkout.session.completed
```
- Check webhook endpoint URL is correct in Stripe Dashboard
- Verify webhook signing secret matches `STRIPE_WEBHOOK_SECRET`
- Check for 2xx response from webhook handler

### 3. Subscription Issues
```bash
# Check customer details
stripe customers retrieve CUSTOMER_ID
# List subscriptions
stripe subscriptions list --customer CUSTOMER_ID --limit 5
# Check specific subscription
stripe subscriptions retrieve SUB_ID
```
- Verify price IDs match between code and Stripe Dashboard
- Check subscription status: active, past_due, canceled, trialing
- Look for failed payment intents on the subscription

### 4. Common Error Patterns
- `resource_missing`: Check if using test-mode IDs against live-mode key (or vice versa)
- `authentication_error`: Wrong API key or key not set
- `card_declined`: Expected in test mode with specific test card numbers
- `webhook_signature_verification_failed`: Signing secret mismatch or raw body not preserved

### 5. Code-level Debug
- Search for Stripe initialization: `grep -rn "new Stripe\|stripe(" --include="*.ts" --include="*.tsx"`
- Find webhook handler: `grep -rn "webhooks/stripe\|webhook.*stripe" --include="*.ts"`
- Check middleware preserves raw body for webhook signature verification

## Rules
- NEVER log or echo full Stripe secret keys
- NEVER run charges against live mode without user confirmation
- Always verify test/live mode before any Stripe CLI commands
- Watch for `tax_id_collection` and `customer_update[address]` config requirements
