const mongoose = require('mongoose');
const dataSecurity = require('../services/dataSecurity');

const userSchema = new mongoose.Schema(
  {
    username: {
      type: String,
      required: true,
      trim: true,
      minlength: 3,
      maxlength: 24,
      unique: true,
    },
    googleId: {
      type: String,
      unique: true,
      sparse: true,
      default: null,
    },
    phone: {
      type: String,
      required: false,
      default: '',
      sparse: true,
      validate: {
        validator: function (v) {
          if (!v) return true;
          return /^\d{10}$/.test(v);
        },
        message: 'Phone number must be a valid 10-digit number',
      },
    },
    password: {
      type: String,
      required: false,
      minlength: 8,
      select: false,
    },
    studioName: { type: String, default: '', trim: true },
    ownerName: { type: String, default: '', trim: true },
    email: { type: String, default: '', trim: true, lowercase: true, index: true },
    city: { type: String, default: '', trim: true },
    address: { type: String, default: '', trim: true },
    about: { type: String, default: '', trim: true },
    instagram: { type: String, default: '', trim: true },
    youtube: { type: String, default: '', trim: true },
    website: { type: String, default: '', trim: true },
    specialties: { type: String, default: '', trim: true },
    logoUrl: { type: String, default: '' },
    paymentQrUrl: { type: String, default: '' },
  },
  {
    timestamps: true,
  },
);

userSchema.plugin(dataSecurity.encryptedFieldsPlugin, {
  deterministicFields: [],
  fields: ['address'],
});

userSchema.methods.toPublicJSON = function toPublicJSON() {
  // Phone and email are stored as plain text. dataSecurity.decrypt is
  // backwards-compatible: plain values pass through unchanged.
  const plainPhone = dataSecurity.decrypt(this.phone || '');
  const plainEmail = dataSecurity.decrypt(this.email || '');
  return {
    id: this._id.toString(),
    username: this.username,
    phone: plainPhone,
    maskedPhone: dataSecurity.maskPhone(plainPhone),
    studioName: this.studioName || '',
    ownerName: this.ownerName || this.username,
    email: plainEmail,
    maskedEmail: dataSecurity.maskEmail(plainEmail),
    city: this.city || '',
    address: dataSecurity.decrypt(this.address || ''),
    about: this.about || '',
    instagram: this.instagram || '',
    youtube: this.youtube || '',
    website: this.website || '',
    specialties: this.specialties || '',
    logoUrl: this.logoUrl || '',
    paymentQrUrl: this.paymentQrUrl || '',
    googleId: this.googleId || '',
  };
};

module.exports = mongoose.model('User', userSchema);
