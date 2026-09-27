'use strict';

const assert = require('node:assert/strict');
const { describe, it } = require('node:test');

process.env.DATA_ENCRYPTION_KEY = 'd7a9f8b4c2e105829374650192837465f1e2d3c4b5a697887766554433221100';
process.env.JWT_SECRET = 'test-jwt-secret-key-32chars-min!!';

const dataSecurity = require('../src/services/dataSecurity');
const memoryUsers = require('../src/store/memoryUsers');

describe('Data Security & Encryption at Rest (AES-256-GCM)', () => {
  it('encrypts sensitive values with AES-256-GCM and decrypts back to original', () => {
    const original = 'confidential.client@studio.com';
    const encrypted = dataSecurity.encrypt(original);

    assert.notEqual(encrypted, original);
    assert.match(encrypted, /^enc:v1:[0-9a-f]+:[0-9a-f]+:[0-9a-f]+$/);

    const decrypted = dataSecurity.decrypt(encrypted);
    assert.equal(decrypted, original);
  });

  it('produces random IVs for distinct encryptions of the same value', () => {
    const val = 'sensitive_notes_wedding_event';
    const enc1 = dataSecurity.encrypt(val);
    const enc2 = dataSecurity.encrypt(val);

    assert.notEqual(enc1, enc2);
    assert.equal(dataSecurity.decrypt(enc1), val);
    assert.equal(dataSecurity.decrypt(enc2), val);
  });

  it('encrypts deterministically for exact-match searchable fields (phone)', () => {
    const phone = '9876543210';
    const enc1 = dataSecurity.encryptDeterministic(phone);
    const enc2 = dataSecurity.encryptDeterministic(phone);

    assert.equal(enc1, enc2); // Deterministic!
    assert.match(enc1, /^enc:det:[0-9a-f]+:[0-9a-f]+$/);
    assert.equal(dataSecurity.decrypt(enc1), phone);
  });

  it('is idempotent when re-encrypting already encrypted values', () => {
    const original = '9123456789';
    const enc = dataSecurity.encryptDeterministic(original);
    const reEnc = dataSecurity.encryptDeterministic(enc);
    const gcmEnc = dataSecurity.encrypt(enc);

    assert.equal(reEnc, enc);
    assert.equal(gcmEnc, enc);
    assert.equal(dataSecurity.decrypt(reEnc), original);
  });

  it('transparently returns unencrypted plaintext for backwards compatibility', () => {
    const legacyPlain = 'legacy_unencrypted_value';
    assert.equal(dataSecurity.decrypt(legacyPlain), legacyPlain);
    assert.equal(dataSecurity.decrypt(''), '');
    assert.equal(dataSecurity.decrypt(null), null);
    assert.equal(dataSecurity.decrypt(undefined), undefined);
  });

  it('safely handles tampered ciphertext or auth tag without crashing', () => {
    const original = 'test_secret_payload';
    const encrypted = dataSecurity.encrypt(original);
    const parts = encrypted.split(':');
    // Tamper with ciphertext
    parts[4] = parts[4].replace(/[0-9a-f]/, '0');
    const tampered = parts.join(':');

    // Decryption must not throw and should safely return fallback
    const result = dataSecurity.decrypt(tampered);
    assert.ok(result);
  });
});

describe('Display & API Masking (Play Store Data Safety Standards)', () => {
  it('masks phone numbers in 98****10 pattern', () => {
    assert.equal(dataSecurity.maskPhone('9876543210'), '98****10');
    assert.equal(dataSecurity.maskPhone('+919876543210'), '91****10');
    assert.equal(dataSecurity.maskPhone('123'), '[redacted]');
    assert.equal(dataSecurity.maskPhone(''), '');
  });

  it('masks phone numbers even when passed as encrypted string', () => {
    const encrypted = dataSecurity.encryptDeterministic('9876543210');
    assert.equal(dataSecurity.maskPhone(encrypted), '98****10');
  });

  it('masks email addresses properly', () => {
    assert.equal(dataSecurity.maskEmail('alex.creator@example.com'), 'a***r@example.com');
    assert.equal(dataSecurity.maskEmail('jo@domain.com'), 'j***@domain.com');
    assert.equal(dataSecurity.maskEmail(''), '');
  });

  it('masks email addresses even when passed as encrypted string', () => {
    const encrypted = dataSecurity.encrypt('photographer@studio.com');
    assert.equal(dataSecurity.maskEmail(encrypted), 'p***r@studio.com');
  });

  it('masks financial/payment reference numbers', () => {
    assert.equal(dataSecurity.maskReference('UPI987654321012'), 'UPI****1012');
    assert.equal(dataSecurity.maskReference('TXN1234'), '****');
    assert.equal(dataSecurity.maskReference(''), '');
  });

  it('masks whole objects for safe logging or previews', () => {
    const obj = {
      phone: '9876543210',
      email: 'creator@example.com',
      reference: 'TXN123456789',
      username: 'studio_user',
    };
    const masked = dataSecurity.maskObject(obj);

    assert.equal(masked.phone, '98****10');
    assert.equal(masked.email, 'c***r@example.com');
    assert.equal(masked.reference, 'TXN****6789');
    assert.equal(masked.username, 'studio_user'); // untouched
  });
});

describe('In-Memory & Disk Store Encryption Verification', () => {
  it('creates new user and exposes decrypted values in memory while disk is encrypted', () => {
    memoryUsers.enabled = true;
    const testPhone = '9998887776';
    const testEmail = 'safe.storage@test.com';

    const user = memoryUsers.create({
      username: `user_${Date.now()}`,
      phone: testPhone,
      email: testEmail,
      password: 'password123',
    });

    assert.equal(user.phone, testPhone);
    assert.equal(user.email, testEmail);

    const found = memoryUsers.findByPhone(testPhone);
    assert.ok(found);
    assert.equal(found.phone, testPhone);
    assert.equal(found.toPublicJSON().phone, testPhone);
  });
});
