const mongoose = require('mongoose');
const dataSecurity = require('../services/dataSecurity');

const dataDeletionRequestSchema = new mongoose.Schema(
  {
    email: { type: String, required: true, trim: true, lowercase: true },
    phone: { type: String, required: true, trim: true },
    status: {
      type: String,
      enum: ['pending', 'processing', 'completed', 'rejected'],
      default: 'pending',
      index: true,
    },
  },
  { timestamps: true },
);

dataDeletionRequestSchema.plugin(dataSecurity.encryptedFieldsPlugin, {
  fields: ['email', 'phone'],
});

module.exports = mongoose.model('DataDeletionRequest', dataDeletionRequestSchema);