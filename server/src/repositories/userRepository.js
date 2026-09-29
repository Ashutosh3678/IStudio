const User = require('../models/User');
const memoryUsers = require('../store/memoryUsers');
const dataSecurity = require('../services/dataSecurity');

async function findByPhone(phone, { withPassword = false } = {}) {
  if (memoryUsers.enabled) {
    return memoryUsers.findByPhone(phone, withPassword);
  }

  const rawPhone = String(phone).trim();
  const encryptedPhone = dataSecurity.encryptDeterministic(rawPhone);
  const query = User.findOne({
    $or: [{ phone: encryptedPhone }, { phone: rawPhone }],
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
  const rawEmail = String(email).trim();
  const encryptedEmail = dataSecurity.encrypt(rawEmail);
  return User.findOne({
    $or: [
      { email: { $regex: new RegExp(`^${escapeRegex(rawEmail)}$`, 'i') } },
      { email: encryptedEmail },
    ],
  });
}

async function createUser(data) {
  const { username, phone = '', password = '', googleId = null, email = '', ownerName = '', logoUrl = '', address = '' } = data;
  if (memoryUsers.enabled) {
    return memoryUsers.create({ username, phone, password, googleId, email, ownerName: ownerName || username, logoUrl, address });
  }
  return User.create({
    username,
    phone: phone ? dataSecurity.encryptDeterministic(phone) : undefined,
    password: password || undefined,
    googleId: googleId || undefined,
    email: email ? dataSecurity.encrypt(email) : '',
    ownerName: ownerName || username,
    logoUrl: logoUrl || '',
    address: address ? dataSecurity.encrypt(address) : '',
  });
}

async function updateUser(id, fields) {
  const secureFields = { ...fields };
  if (secureFields.phone) {
    secureFields.phone = dataSecurity.encryptDeterministic(secureFields.phone);
  }
  if (secureFields.email) {
    secureFields.email = dataSecurity.encrypt(secureFields.email);
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
