# Core modules and entities

Starting point for the domain model. Every tenant-owned table also has `id (uuid v7)`, `tenant_id`, `created_at`, `created_by`, `updated_at`, `updated_by`, `version`, and master data has `archived_at`.

## Core
- **Tenant / Company**: legal name, address, VAT ID (USt-IdNr.), tax number, commercial register, bank accounts, logo, default currency, fiscal year start, number ranges.
- **User, Role, Permission, Team**; **AuditLog** (entity, entity_id, action, actor, diff jsonb, at); **Attachment**; **Note**; **Task** (assignee, due, status, related entity); **Tag**; **CustomField** definitions + values.

## CRM
- **Account** (company): name, type (lead/customer/supplier/partner), industry, size, addresses (billing/shipping), VAT ID, payment terms, price list, owner, status.
- **Contact**: person, role, email, phone, consent flags (marketing, with timestamp and source), linked accounts.
- **Lead**: source, campaign, score, status, converted_to (account/deal).
- **Deal / Opportunity**: account, pipeline, stage, amount, currency, probability, expected close, owner, lost reason.
- **Activity**: type (call, email, meeting), timestamp, participants, outcome, linked records.
- **Pipeline / Stage** definitions per tenant.

## Sales
- **Product / Service**: SKU, name, description, unit, tax category, prices (per price list, validity), cost price, stock-tracked flag, variants.
- **Quote** -> **SalesOrder** -> **DeliveryNote** -> **Invoice** -> **CreditNote**: number, dates, account, addresses snapshot, lines (product, description, qty, unit, unit price, discount, tax rate, line total), totals per tax rate, currency, payment terms, status, document PDF, e-invoice XML.
- **Payment**: amount, date, method, reference, allocations to invoices; **DunningRun** with levels and fees.

## Inventory
- **Warehouse / Location / Bin**; **StockMovement** (product, qty +/-, from/to location, type, reference document, batch/serial, cost); **StockLevel** (product, location, on_hand, reserved, available); **Reservation**; **StockCount** (inventory count with differences posted as adjustments); reorder points.

## Purchasing
- **Supplier** (Account type), **PurchaseRequest**, **PurchaseOrder**, **GoodsReceipt**, **SupplierInvoice** (incl. incoming e-invoice parsing, 3-way match: PO / receipt / invoice), approval limits.

## Accounting
- **ChartOfAccounts** (SKR03/SKR04 mapping), **JournalEntry** + **JournalLine** (account, debit, credit, tax code, cost center) - balanced, append-only; **FiscalPeriod** (open/closed); **CostCenter**; **BankTransaction** import (CAMT.053) and reconciliation; DATEV export batches.

## HR (if needed - highly sensitive, field-level permissions)
- **Employee**, **Contract**, **Absence** (vacation, sick leave with approval), **TimeEntry** (working time recording per German law), **Document** storage with retention.

## Projects / Services
- **Project** (customer, budget, status), **Task**, **TimeEntry** (billable, rate), **Expense**, project invoicing (time & material, fixed price, milestones).

## Integration surface
- REST API with API keys / OAuth per tenant, webhooks (signed, retried), import/export (CSV/Excel), e-invoice (XRechnung, ZUGFeRD), DATEV, banking (CAMT/SEPA), email (IMAP/SMTP or provider API), calendar (CalDAV/Google/Microsoft).
