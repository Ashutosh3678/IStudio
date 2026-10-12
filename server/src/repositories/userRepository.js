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
    return memoryUsers.create({ username, phone: cleanPhone, password, googleId, email: cleanEmail, ownerName: ownerName || username, logoUrl, address, categories: data.categories || [] });
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
    categories: Array.isArray(data.categories) ? data.categories : [],
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
  if (secureFields.categories !== undefined) {
    secureFields.categories = Array.isArray(secureFields.categories)
      ? secureFields.categories
      : [];
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

async function searchPhotographers({ userId, location, query, state, district, category, categories, limit = 50 }) {
  if (memoryUsers.enabled) {
    return memoryUsers.searchPhotographers({ userId, location, query, state, district, category, categories, limit });
  }

  const mongoose = require('mongoose');
  const filter = {};
  if (userId && mongoose.Types.ObjectId.isValid(userId)) {
    filter._id = { $ne: userId };
  }

  const conditions = [];
  const normalizedState = String(state || '').trim();
  const normalizedDistrict = String(district || '').trim();
  if (normalizedState) conditions.push({ state: { $regex: `^${escapeRegex(normalizedState)}$`, $options: 'i' } });
  if (normalizedDistrict) {
    conditions.push({
      $or: [
        { district: { $regex: `^${escapeRegex(normalizedDistrict)}$`, $options: 'i' } },
        // Legacy profiles have city but no district; exact city matching is safe backfill.
        { district: { $in: ['', null] }, city: { $regex: `^${escapeRegex(normalizedDistrict)}$`, $options: 'i' } },
      ],
    });
  }
  const loc = String(location || query || '').trim();
  if (loc) {
    const escaped = escapeRegex(loc);
    conditions.push({
      $or: [
        { city: { $regex: escaped, $options: 'i' } },
        { address: { $regex: escaped, $options: 'i' } },
        { studioName: { $regex: escaped, $options: 'i' } },
        { ownerName: { $regex: escaped, $options: 'i' } },
        { state: { $regex: escaped, $options: 'i' } },
        { district: { $regex: escaped, $options: 'i' } },
        { username: { $regex: escaped, $options: 'i' } },
      ],
    });
  }

  const catList = Array.isArray(categories) && categories.length > 0
    ? categories.map((c) => String(c).trim()).filter(Boolean)
    : (category && String(category).trim() ? [String(category).trim()] : []);

  if (catList.length > 0) {
    const catConditions = catList.map((catItem) => {
      const escapedCat = escapeRegex(catItem);
      return {
        $or: [
          { categories: { $elemMatch: { $regex: escapedCat, $options: 'i' } } },
          { specialties: { $regex: escapedCat, $options: 'i' } },
        ],
      };
    });
    // Match any selected category
    conditions.push({ $or: catConditions });
  }

  if (conditions.length > 0) {
    filter.$and = conditions;
  }

  return User.find(filter).limit(Number(limit) || 50);
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
  searchPhotographers,
};
