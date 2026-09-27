const crypto = require('crypto');
const logger = require('../config/logger');

/**
 * Production-grade Data Security Service
 *
 * Provides:
 * 1. AES-256-GCM authenticated encryption for sensitive fields at rest (database storage)
 * 2. Deterministic AES-256 encryption for indexable/searchable fields (phone lookups)
 * 3. Transparent decryption when loading records from the database
 * 4. Display/API masking for phone numbers, emails, and financial references (Play Store compliance)
 */

function getDerivedKey() {
  const secret =
    process.env.DATA_ENCRYPTION_KEY ||
    process.env.JWT_SECRET ||
    'lumen_studio_production_encryption_key_fallback_2026';
  return crypto.createHash('sha256').update(String(secret)).digest();
}

/**
 * Check if a given value is already encrypted.
 */
function isEncrypted(value) {
  return typeof value === 'string' && value.startsWith('enc:');
}

/**
 * Encrypt a value using AES-256-GCM with a random IV.
 * Best for non-searchable sensitive fields (e.g. email, address, notes, reference).
 * Format: enc:v1:<iv_hex>:<auth_tag_hex>:<ciphertext_hex>
 */
function encrypt(plainText) {
  if (plainText === null || plainText === undefined || plainText === '') {
    return plainText;
  }
  const str = String(plainText);
  if (isEncrypted(str)) {
    return str; // Idempotent
  }

  try {
    const key = getDerivedKey();
    const iv = crypto.randomBytes(12);
    const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);

    let encrypted = cipher.update(str, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    const authTag = cipher.getAuthTag().toString('hex');

    return `enc:v1:${iv.toString('hex')}:${authTag}:${encrypted}`;
  } catch (err) {
    logger.error('Encryption failure', { error: err.message });
    return str;
  }
}

/**
 * Encrypt a value deterministically using AES-256-CBC.
 * Same input produces the same ciphertext for the same key, allowing exact-match DB queries.
 * Format: enc:det:<iv_hex>:<ciphertext_hex>
 */
function encryptDeterministic(plainText) {
  if (plainText === null || plainText === undefined || plainText === '') {
    return plainText;
  }
  const str = String(plainText);
  if (isEncrypted(str)) {
    return str; // Idempotent
  }

  try {
    const key = getDerivedKey();
    // Deterministic 16-byte IV derived from HMAC of input
    const iv = crypto
      .createHmac('sha256', key)
      .update(str)
      .digest()
      .subarray(0, 16);

    const cipher = crypto.createCipheriv('aes-256-cbc', key, iv);
    let encrypted = cipher.update(str, 'utf8', 'hex');
    encrypted += cipher.final('hex');

    return `enc:det:${iv.toString('hex')}:${encrypted}`;
  } catch (err) {
    logger.error('Deterministic encryption failure', { error: err.message });
    return str;
  }
}

/**
 * Decrypt a value previously encrypted with either encrypt() or encryptDeterministic().
 * If the value is unencrypted plaintext, returns it unchanged (100% backwards compatible).
 */
function decrypt(cipherText) {
  if (typeof cipherText !== 'string' || !cipherText.startsWith('enc:')) {
    return cipherText;
  }

  const parts = cipherText.split(':');
  const scheme = parts[1];

  try {
    const key = getDerivedKey();

    // 1. AES-256-GCM scheme (enc:v1:<iv>:<tag>:<ciphertext>)
    if (scheme === 'v1' && parts.length === 5) {
      const iv = Buffer.from(parts[2], 'hex');
      const authTag = Buffer.from(parts[3], 'hex');
      const ciphertext = parts[4];

      const decipher = crypto.createDecipheriv('aes-256-gcm', key, iv);
      decipher.setAuthTag(authTag);
      let decrypted = decipher.update(ciphertext, 'hex', 'utf8');
      decrypted += decipher.final('utf8');
      return decrypted;
    }

    // 2. Deterministic AES-256-CBC scheme (enc:det:<iv>:<ciphertext>)
    if (scheme === 'det' && parts.length === 4) {
      const iv = Buffer.from(parts[2], 'hex');
      const ciphertext = parts[3];

      const decipher = crypto.createDecipheriv('aes-256-cbc', key, iv);
      let decrypted = decipher.update(ciphertext, 'hex', 'utf8');
      decrypted += decipher.final('utf8');
      return decrypted;
    }

    return cipherText;
  } catch (err) {
    logger.warn('Decryption failed, falling back to original value', {
      error: err.message,
    });
    return cipherText;
  }
}

/**
 * Display / API Masking Helpers
 */

/**
 * Mask phone numbers for logs, OTP responses, and public displays.
 * Example: '9876543210' -> '98****10'
 */
function maskPhone(phone) {
  if (!phone) return '';
  const plain = decrypt(String(phone));
  const digits = plain.replace(/\D/g, '');
  if (digits.length < 4) return '[redacted]';
  return `${digits.slice(0, 2)}****${digits.slice(-2)}`;
}

/**
 * Mask email addresses for safe API previews and audit logs.
 * Example: 'alex.creator@example.com' -> 'a***r@example.com'
 */
function maskEmail(email) {
  if (!email) return '';
  const plain = decrypt(String(email)).trim();
  const atIdx = plain.indexOf('@');
  if (atIdx <= 1) return '***@' + (plain.split('@')[1] || '');

  const userPart = plain.slice(0, atIdx);
  const domainPart = plain.slice(atIdx);

  if (userPart.length <= 2) {
    return `${userPart[0]}***${domainPart}`;
  }
  return `${userPart[0]}***${userPart[userPart.length - 1]}${domainPart}`;
}

/**
 * Mask payment or bank transaction reference IDs.
 * Example: 'TXN123456789' -> 'TXN****6789'
 */
function maskReference(ref) {
  if (!ref) return '';
  const plain = decrypt(String(ref)).trim();
  if (plain.length < 8) return '****';
  const prefix = plain.slice(0, Math.min(3, Math.floor(plain.length / 3)));
  const suffix = plain.slice(-Math.min(4, Math.floor(plain.length / 3)));
  return `${prefix}****${suffix}`;
}

/**
 * Mask an object's sensitive properties for safe client responses or logs.
 */
function maskObject(obj, fields = ['phone', 'email', 'reference']) {
  if (!obj || typeof obj !== 'object') return obj;
  const copy = { ...obj };
  if (fields.includes('phone') && copy.phone) copy.phone = maskPhone(copy.phone);
  if (fields.includes('email') && copy.email) copy.email = maskEmail(copy.email);
  if (fields.includes('reference') && copy.reference) {
    copy.reference = maskReference(copy.reference);
  }
  return copy;
}

/**
 * Mongoose Plugin for transparent field-level encryption.
 * Automatically encrypts specified fields on save/update and decrypts on fetch.
 */
function encryptedFieldsPlugin(schema, { fields = [], deterministicFields = [] } = {}) {
  // Pre-save hook: encrypt fields before writing to database
  schema.pre('save', function (next) {
    for (const field of deterministicFields) {
      if (this.isModified(field) && this[field]) {
        this[field] = encryptDeterministic(this[field]);
      }
    }
    for (const field of fields) {
      if (this.isModified(field) && this[field]) {
        this[field] = encrypt(this[field]);
      }
    }
    next();
  });

  // Post-init hook: decrypt fields when loaded from database
  schema.post('init', function (doc) {
    for (const field of [...deterministicFields, ...fields]) {
      if (doc[field] && isEncrypted(doc[field])) {
        doc[field] = decrypt(doc[field]);
      }
    }
  });

  // Post-save hook: keep in-memory document decrypted for callers
  schema.post('save', function (doc) {
    for (const field of [...deterministicFields, ...fields]) {
      if (doc[field] && isEncrypted(doc[field])) {
        doc[field] = decrypt(doc[field]);
      }
    }
  });
}

module.exports = {
  encrypt,
  encryptDeterministic,
  decrypt,
  isEncrypted,
  maskPhone,
  maskEmail,
  maskReference,
  maskObject,
  encryptedFieldsPlugin,
};
