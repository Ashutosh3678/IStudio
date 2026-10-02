const { randomUUID } = require('crypto');
const DataDeletionRequest = require('../models/DataDeletionRequest');
const memoryUsers = require('../store/memoryUsers');

const inMemoryRequests = [];

async function createDataDeletionRequest(
  data,
  { model = DataDeletionRequest, useMemoryStore = memoryUsers.enabled } = {},
) {
  if (useMemoryStore) {
    const request = {
      id: randomUUID(),
      email: data.email,
      phone: data.phone,
      status: 'pending',
      createdAt: new Date(),
    };
    inMemoryRequests.push(request);
    return request;
  }

  const request = await model.create(data);
  return {
    id: request._id.toString(),
    email: data.email,
    phone: data.phone,
    createdAt: request.createdAt,
  };
}

module.exports = { createDataDeletionRequest };