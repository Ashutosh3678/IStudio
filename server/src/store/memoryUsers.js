const { randomUUID } = require('crypto');

const users = [];

function toDoc(user, withPassword = false) {
  return {
    _id: user.id,
    username: user.username,
    phone: user.phone,
    password: withPassword ? user.password : undefined,
    toPublicJSON() {
      return {
        id: user.id,
        username: user.username,
        phone: user.phone,
      };
    },
  };
}

const memoryUsers = {
  enabled: false,
  findByPhone(phone, withPassword = false) {
    const user = users.find((item) => item.phone === phone);
    return user ? toDoc(user, withPassword) : null;
  },
  findByUsername(username) {
    const user = users.find(
      (item) => item.username.toLowerCase() === username.toLowerCase(),
    );
    return user ? toDoc(user) : null;
  },
  findById(id) {
    const user = users.find((item) => item.id === id);
    return user ? toDoc(user) : null;
  },
  create({ username, phone, password }) {
    const user = {
      id: randomUUID(),
      username,
      phone,
      password,
    };
    users.push(user);
    return toDoc(user);
  },
};

module.exports = memoryUsers;
