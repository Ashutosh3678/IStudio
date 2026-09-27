const mongoose = require('mongoose');
const dataSecurity = require('../services/dataSecurity');

const clientSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  name: { type: String, required: true, trim: true, maxlength: 160 },
  phone: { type: String, required: true, trim: true, maxlength: 256 },
  email: { type: String, default: '', trim: true, maxlength: 256 },
  address: { type: String, default: '', trim: true, maxlength: 1000 },
  notes: { type: String, default: '', trim: true, maxlength: 2000 },
  status: {
    type: String,
    enum: ['information', 'comingUp', 'completed', 'notResponded'],
    default: 'information',
  },
}, { timestamps: true });

clientSchema.index({ userId: 1, name: 1 });

clientSchema.plugin(dataSecurity.encryptedFieldsPlugin, {
  deterministicFields: ['phone'],
  fields: ['email', 'address', 'notes'],
});

clientSchema.methods.toPublicJSON = function toPublicJSON() {
  const plainPhone = dataSecurity.decrypt(this.phone || '');
  const plainEmail = dataSecurity.decrypt(this.email || '');
  return {
    id: this._id.toString(),
    name: this.name,
    phone: plainPhone,
    maskedPhone: dataSecurity.maskPhone(plainPhone),
    email: plainEmail,
    maskedEmail: dataSecurity.maskEmail(plainEmail),
    address: dataSecurity.decrypt(this.address || ''),
    notes: dataSecurity.decrypt(this.notes || ''),
    status: this.status || 'information',
    createdAt: this.createdAt,
  };
};

module.exports = mongoose.model('Client', clientSchema);
