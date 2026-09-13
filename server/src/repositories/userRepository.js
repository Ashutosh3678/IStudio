const User = require('../models/User');
const memoryUsers = require('../store/memoryUsers');

async function findByPhone(phone, { withPassword = false } = {}) {
  if (memoryUsers.enabled) {
    return memoryUsers.findByPhone(phone, withPassword);
  }

  const query = User.findOne({ phone });
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

async function findById(id) {
  if (memoryUsers.enabled) {
    return memoryUsers.findById(id);
  }
  return User.findById(id);
}

async function createUser({ username, phone, password }) {
  if (memoryUsers.enabled) {
    return memoryUsers.create({ username, phone, password });
  }
  return User.create({ username, phone, password });
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

module.exports = {
  findByPhone,
  findByUsername,
  findById,
  createUser,
};
