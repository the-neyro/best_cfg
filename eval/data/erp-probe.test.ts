// Independent probe for both ERP invoice modules. Adapter selected by env VARIANT.
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';

const V = process.env.VARIANT!;
const mod: any = V === 'base' ? await import(process.env.ROOT + '/src/index.ts') : await import(process.env.ROOT + '/src/invoicing/index.ts');
const dbmod: any = V === 'base' ? mod : await import(process.env.ROOT + '/src/db/database.ts');

const line = (quantity: number, unitPriceCents: number, vatRate: number) => ({ description: 'Pos', quantity, unitPriceCents, vatRate });
const input = (lines: any[]) => V === 'base'
  ? { customer: { name: 'Autohaus Müller GmbH', address: 'Hauptstr. 1, 80331 München' }, serviceDate: '2026-11-20', items: lines }
  : { customer: { name: 'Autohaus Müller GmbH', street: 'Hauptstr. 1', postalCode: '80331', city: 'München' }, serviceDate: '2026-11-20', lines };
const tot = (i: any) => V === 'base' ? { net: i.netCents, vat: i.vatCents, gross: i.grossCents, lines: i.items.map((x: any) => x.netCents) } : { net: i.netTotalCents, vat: i.taxTotalCents, gross: i.grossTotalCents, lines: i.lines.map((x: any) => x.netCents ?? x.netAmountCents ?? x.lineNetCents) };
const cancelled = (i: any) => String(i.status).toLowerCase() === 'cancelled';

let dir: string, db: any, svc: any;
const fixedNow = () => new Date('2026-11-27T10:00:00Z');
beforeEach(() => { dir = mkdtempSync(join(tmpdir(), 'probe-')); db = dbmod.openDatabase(join(dir, 't.db')); svc = new mod.InvoiceService(db, { now: fixedNow }); });
afterEach(() => { db.close(); rmSync(dir, { recursive: true, force: true }); });

describe(`probe ${V}`, () => {
  it('numbers are sequential and gapless', () => {
    const n = [1, 2, 3].map(() => svc.createInvoice(input([line(1, 1000, 19)])).number);
    const c = n.map((x: string) => Number(x.match(/(\d+)$/)![1]));
    expect(c).toEqual([c[0], c[0] + 1, c[0] + 2]);
    expect(n[0]).toMatch(/2026/);
  });
  it('rounding: fractional qty and mixed VAT reconcile', () => {
    const t = tot(svc.createInvoice(input([line(3, 333, 19), line(1.5, 1999, 7)])));
    console.log(V, 'totals', JSON.stringify(t));
    expect(t.gross).toBe(t.net + t.vat);
    expect(t.lines.reduce((a: number, b: number) => a + b, 0)).toBe(t.net);
    expect(t.net).toBe(999 + 2999);
    expect(t.vat).toBe(190 + 210);
  });
  it('storno: own number, original cancelled, no double storno', () => {
    const a = svc.createInvoice(input([line(2, 5000, 19)]));
    const s = svc.cancelInvoice(a.id, { reason: 'Falscher Kunde' });
    expect(s.number).not.toBe(a.number);
    expect(cancelled(svc.getInvoice(a.id))).toBe(true);
    expect(Math.abs(tot(s).gross)).toBe(Math.abs(tot(a).gross));
    expect(() => svc.cancelInvoice(a.id, { reason: 'nochmal' })).toThrow();
  });
  it('rejects invalid input', () => {
    for (const bad of [[line(1, 1000, 16)], [line(0, 1000, 19)], [line(1, -1, 19)], [line(1, 12.5, 19)], []]) {
      expect(() => svc.createInvoice(input(bad))).toThrow();
    }
  });
  it('issued invoices cannot be changed or deleted in the DB', () => {
    const a = svc.createInvoice(input([line(1, 1000, 19)]));
    expect(() => db.prepare('UPDATE invoices SET notes = ? WHERE id = ?').run('manipuliert', a.id)).toThrow();
    expect(() => db.prepare('DELETE FROM invoices WHERE id = ?').run(a.id)).toThrow();
  });
  it('year rollover restarts the counter', () => {
    svc.createInvoice(input([line(1, 1000, 19)]));
    const svc27 = new mod.InvoiceService(db, { now: () => new Date('2027-01-02T10:00:00Z') });
    const inp: any = input([line(1, 1000, 19)]); inp.serviceDate = '2027-01-02';
    const n = svc27.createInvoice(inp).number;
    expect(n).toMatch(/2027/);
    expect(Number(n.match(/(\d+)$/)![1])).toBe(1);
  });
});
