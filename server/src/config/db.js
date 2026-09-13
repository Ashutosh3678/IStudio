const mongoose = require('mongoose');
const memoryUsers = require('../store/memoryUsers');

function hasRealMongoUri() {
  const uri = process.env.MONGODB_URI || '';
  return Boolean(
    uri &&
      !uri.includes('<username>') &&
      !uri.includes('<cluster>') &&
      !uri.includes('<password>'),
  );
}

async function connectDb() {
  if (!hasRealMongoUri()) {
    memoryUsers.enabled = true;
    console.warn(
      'MongoDB URI is not set yet. Auth is using an in-memory store until you add MONGODB_URI to server/.env.',
    );
    return;
  }

  mongoose.set('strictQuery', true);
  await mongoose.connect(process.env.MONGODB_URI);
  console.log('MongoDB connected');
}

module.exports = { connectDb };
