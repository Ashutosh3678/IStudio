const { randomUUID } = require('crypto');
const mongoose = require('mongoose');

const { Invoice, invoiceTotals } = require('../models/Invoice');
const memoryUsers = require('../store/memoryUsers');
const memoryInvoices = require('../store/memoryInvoices');

function usesMemory() {
  return memoryUsers.enabled;
}

function normalizeDeliverables(items = []) {
  return items.map((item) => ({
    id: String(item.id || randomUUID()),
    name: String(item.name || '').trim(),
    cost: Number(item.cost) || 0,
  }));
}

async function listByUser(userId) {
  if (usesMemory()) {
    return memoryInvoices.listByUser(userId);
  }
  return Invoice.find({ userId }).sort({ issuedOn: -1, createdAt: -1 });
}

async function findByIdForUser(id, userId) {
  if (usesMemory()) {
    return memoryInvoices.findByIdForUser(id, userId);
  }
  if (!mongoose.Types.ObjectId.isValid(id)) return null;
  const invoice = await Invoice.findById(id);
  if (!invoice || invoice.userId.toString() !== String(userId)) return null;
  return invoice;
}

async function nextNumber(userId) {
  if (usesMemory()) {
    return memoryInvoices.nextNumber(userId);
  }

  const invoices = await Invoice.find({ userId }).select('number').lean();
  let max = 1000;
  const pattern = /INV-(\d+)/i;
  for (const invoice of invoices) {
    const match = pattern.exec(invoice.number || '');
    if (!match) continue;
    const value = Number(match[1]) || 0;
    if (value > max) max = value;
  }
  return `INV-${max + 1}`;
}

async function createInvoice(fields) {
  const deliverables = normalizeDeliverables(fields.deliverables);
  const totals = invoiceTotals(deliverables, fields.amountReceived);
  const payload = {
    userId: fields.userId,
    number: fields.number || (await nextNumber(fields.userId)),
    eventName: fields.eventName,
    contactName: fields.contactName,
    phone: fields.phone,
    address: fields.address,
    issuedOn: fields.issuedOn || new Date(),
    dueDate: fields.dueDate,
    deliverables,
    upiId: fields.upiId || '',
    amountReceived: totals.received,
  };

  if (usesMemory()) {
    return memoryInvoices.create(payload);
  }
  return Invoice.create(payload);
}

async function updateInvoice(id, userId, fields) {
  if (usesMemory()) {
    const next = { ...fields };
    if (fields.deliverables) {
      next.deliverables = normalizeDeliverables(fields.deliverables);
    }
    if (fields.amountReceived !== undefined || fields.deliverables) {
      const current = memoryInvoices.findByIdForUser(id, userId);
      if (!current) return null;
      const deliverables = next.deliverables || current.deliverables;
      const amount =
        fields.amountReceived !== undefined
          ? fields.amountReceived
          : current.amountReceived;
      const totals = invoiceTotals(deliverables, amount);
      next.amountReceived = totals.received;
    }
    return memoryInvoices.update(id, userId, next);
  }

  const invoice = await findByIdForUser(id, userId);
  if (!invoice) return null;

  if (fields.deliverables) {
    invoice.deliverables = normalizeDeliverables(fields.deliverables);
  }
  const allowed = [
    'eventName',
    'contactName',
    'phone',
    'address',
    'issuedOn',
    'dueDate',
    'upiId',
    'amountReceived',
  ];
  for (const key of allowed) {
    if (fields[key] !== undefined) invoice[key] = fields[key];
  }
  const totals = invoiceTotals(invoice.deliverables, invoice.amountReceived);
  invoice.amountReceived = totals.received;
  await invoice.save();
  return invoice;
}

async function deleteInvoice(id, userId) {
  if (usesMemory()) {
    return memoryInvoices.remove(id, userId);
  }
  const invoice = await findByIdForUser(id, userId);
  if (!invoice) return false;
  await invoice.deleteOne();
  return true;
}

module.exports = {
  listByUser,
  findByIdForUser,
  nextNumber,
  createInvoice,
  updateInvoice,
  deleteInvoice,
};
