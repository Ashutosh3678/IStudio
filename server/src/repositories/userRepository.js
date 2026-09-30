const User = require('../models/User');
const memoryUsers = require('../store/memoryUsers');
const dataSecurity = require('../services/dataSecurity');

async function findByPhone(phone, { withPassword = false } = {}) {
  if (memoryUsers.enabled) {
    return memoryUsers.findByPhone(phone, withPassword);
  }

  // Phone is stored as plain text. We also fall back to the legacy
  // deterministic-encrypted form so that any old records still match.
  const rawPhone = String(phone).trim();
  const encryptedPhone = dataSecurity.encryptDeterministic(rawPhone);
  const query = User.findOne({
    $or: [{ phone: rawPhone }, { phone: encryptedPhone }],
  });
  if (withPassword) query.select('+password');
  return query;
}

async function findByUsername(username) {
  if (memoryUsers.enabled) {
    return memoryUsers.findByUsername(username);
  }

  return User.findOne({
    username: { $regex: new RegExp(`^${escapeRegex(username)}$`, 'i') },
  });
}

async function findById(id, { withPassword = false } = {}) {
  if (memoryUsers.enabled) {
    return memoryUsers.findById(id, withPassword);
  }
  const query = User.findById(id);
  if (withPassword) query.select('+password');
  return query;
}

async function findByGoogleId(googleId) {
  if (!googleId) return null;
  if (memoryUsers.enabled) {
    return memoryUsers.findByGoogleId(googleId);
  }
  return User.findOne({ googleId });
}

async function findByEmail(email) {
  if (!email) return null;
  if (memoryUsers.enabled) {
    return memoryUsers.findByEmail(email);
  }
  const rawEmail = String(email).trim().toLowerCase();
  // Email is stored as plain text (case-insensitive lookup)
  return User.findOne({
    email: { $regex: new RegExp(`^${escapeRegex(rawEmail)}$`, 'i') },
  });
}

async function createUser(data) {
  const { username, phone = '', password = '', googleId = null, email = '', ownerName = '', logoUrl = '', address = '' } = data;
  const cleanPhone = String(phone || '').trim();
  const cleanEmail = String(email || '').trim().toLowerCase();

  if (memoryUsers.enabled) {
    return memoryUsers.create({ username, phone: cleanPhone, password, googleId, email: cleanEmail, ownerName: ownerName || username, logoUrl, address });
  }
  return User.create({
    username,
    phone: cleanPhone || '',
    password: password || undefined,
    googleId: googleId || undefined,
    email: cleanEmail || '',
    ownerName: ownerName || username,
    logoUrl: logoUrl || '',
    address: address ? dataSecurity.encrypt(address) : '',
  });
}

async function updateUser(id, fields) {
  const secureFields = { ...fields };
  if (secureFields.phone !== undefined) {
    secureFields.phone = String(secureFields.phone || '').trim();
  }
  if (secureFields.email !== undefined) {
    secureFields.email = String(secureFields.email || '').trim().toLowerCase();
  }
  if (secureFields.address) {
    secureFields.address = dataSecurity.encrypt(secureFields.address);
  }

  if (memoryUsers.enabled) {
    return memoryUsers.update(id, fields);
  }
  return User.findByIdAndUpdate(id, { $set: secureFields }, { new: true });
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

async function deleteUserAccount(userId) {
  if (memoryUsers.enabled) {
    memoryUsers.remove(userId);
    const memoryInvoices = require('../store/memoryInvoices');
    const userInvoices = memoryInvoices.listByUser(userId);
    for (const inv of userInvoices) {
      memoryInvoices.remove(inv.id, userId);
    }
    return true;
  }

  const Client = require('../models/Client');
  const Event = require('../models/Event');
  const Payment = require('../models/Payment');
  const Expense = require('../models/Expense');
  const Deliverable = require('../models/Deliverable');
  const { Invoice } = require('../models/Invoice');

  await Promise.all([
    Client.deleteMany({ userId }),
    Event.deleteMany({ userId }),
    Payment.deleteMany({ userId }),
    Expense.deleteMany({ userId }),
    Deliverable.deleteMany({ userId }),
    Invoice.deleteMany({ userId }),
    User.deleteOne({ _id: userId }),
  ]);
  return true;
}

module.exports = {
  findByPhone,
  findByUsername,
  findByGoogleId,
  findByEmail,
  findById,
  createUser,
  updateUser,
  deleteUserAccount,
};
