---
name: payments
description: Accept money safely - Stripe (Checkout, Payment Element, Billing/subscriptions, Customer Portal, Connect), SEPA, PayPal, invoices and VAT for Germany/EU, webhooks, refunds, dunning and failed payments. Use for any payment, checkout, subscription, pricing-plan or billing feature.
when_to_use: 'Triggers: Stripe, страйп, оплата, платеж, подписка, checkout, payment, Zahlung, bezahlen, Abo, Abonnement, billing, subscription, SEPA, PayPal, Rechnung bezahlen, refund, возврат'
---

# Payments

Money bugs are the most expensive bugs. The rules: **the server and the payment provider decide what was paid - never the client; every payment event is processed exactly once; every amount is an integer in minor units.**

## Architecture defaults (Stripe)
- **Hosted first**: Stripe Checkout (or the Payment Element) for one-off payments and subscriptions; Stripe Customer Portal for plan changes, payment methods and invoices. Building card forms yourself only with the Payment Element - never handle raw card data (PCI scope).
- Prices and products live in Stripe (or are validated server-side); the client sends a price/plan ID, never an amount.
- One Stripe `customer` per user/organization, stored in your DB; metadata links Stripe objects to your IDs.
- **Fulfil only from webhooks** (`checkout.session.completed`, `invoice.paid`, `invoice.payment_failed`, `customer.subscription.updated/deleted`, `charge.refunded`), not from the success-page redirect.
- Webhooks: verify the signature on the raw body, store `event.id` and skip duplicates (idempotent handler), return 2xx fast and do heavy work in a job, handle out-of-order events by re-fetching the object from Stripe.
- Outgoing API calls that create money movements use idempotency keys.
- Subscription state in your DB is a cache of Stripe's; access checks use it, webhooks keep it fresh; a nightly reconciliation job fixes drift.
- Local development: `stripe listen --forward-to localhost:3000/api/stripe/webhook`; test cards and test clocks for renewals/dunning; separate test/live keys and webhook secrets per environment.

## Germany / EU
- Prices for consumers shown **including VAT**; B2B may show net with "zzgl. MwSt.". Reverse charge for EU B2B with valid VAT ID (validate via VIES).
- Stripe Tax or your own VAT logic with rates by country (OSS for EU consumer sales).
- Invoices with all § 14 UStG fields, gapless numbering, immutable after issue (see `business-apps`); e-invoice (XRechnung/ZUGFeRD) for B2B.
- Payment methods customers expect: cards, SEPA Direct Debit, PayPal, Klarna, Apple/Google Pay. SCA/3-D Secure handled by Stripe - never bypass.
- Withdrawal right (Widerrufsrecht) for consumers, clear cancellation path ("Kündigungsbutton" for subscriptions), button text "Zahlungspflichtig bestellen" / "Jetzt kaufen" (Button-Lösung).

## Failure paths (design them, they are not edge cases)
- Card declined, 3-D Secure abandoned, SEPA returned days later, partial refund, dispute/chargeback, subscription past_due, plan downgrade mid-period, currency mismatch, webhook delivered twice or late.
- Dunning: Smart Retries + emails + grace period, then downgrade - never delete data on first failure.

## Verify before shipping
- End-to-end in test mode: purchase, renewal (test clock), failed payment, refund, cancellation, webhook replay (duplicate) - all leave the DB correct.
- Security review (`secure-coding`): webhook signature, authz on billing endpoints, no amount from client, secrets only server-side.
