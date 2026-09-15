const assert = require('assert');

const { invoiceTotals, invoiceStatus, toPublicInvoice } = require('../src/models/Invoice');

const totals = invoiceTotals(
  [
    { name: 'Coverage', cost: 50000 },
    { name: 'Album', cost: 20000 },
  ],
  20000,
);

assert.strictEqual(totals.total, 70000);
assert.strictEqual(totals.received, 20000);
assert.strictEqual(totals.pending, 50000);
assert.strictEqual(invoiceStatus(new Date('2099-01-01'), totals), 'partial');
assert.strictEqual(
  invoiceStatus(new Date('2099-01-01'), invoiceTotals([{ cost: 100 }], 100)),
  'paid',
);
assert.strictEqual(
  invoiceStatus(new Date('2020-01-01'), invoiceTotals([{ cost: 100 }], 0)),
  'overdue',
);

const json = toPublicInvoice({
  id: 'inv-1',
  number: 'INV-1001',
  eventName: 'Wedding',
  contactName: 'Aanya',
  phone: '9876543210',
  address: 'Mumbai',
  issuedOn: '2026-08-01T00:00:00.000Z',
  dueDate: '2099-12-31T00:00:00.000Z',
  upiId: 'studio@okaxis',
  amountReceived: 0,
  deliverables: [{ id: 'd1', name: 'Coverage', cost: 55000 }],
});

assert.strictEqual(json.number, 'INV-1001');
assert.strictEqual(json.total, 55000);
assert.strictEqual(json.status, 'pending');

console.log('invoice model checks passed');
