'use strict';

const assert = require('node:assert/strict');
const { describe, it, before } = require('node:test');

process.env.DATA_ENCRYPTION_KEY = 'd7a9f8b4c2e105829374650192837465f1e2d3c4b5a697887766554433221100';
process.env.JWT_SECRET = 'test-jwt-secret-key-32chars-min!!';

const userRepository = require('../src/repositories/userRepository');
const memoryUsers = require('../src/store/memoryUsers');
const otpService = require('../src/services/otpService');

describe('New Auth & Plain Phone Storage Requirements', () => {
  before(() => {
    memoryUsers.enabled = true;
  });

  it('stores phone numbers directly in plaintext without AES encryption', async () => {
    const plainNumber = '9876543210';
    const username = `plain_user_${Date.now()}`;
    const user = await userRepository.createUser({
      username,
      phone: plainNumber,
      email: 'test@plainphone.com',
      password: 'hashed_password_123',
    });

    assert.equal(user.phone, plainNumber);
    assert.equal(user.phone.startsWith('enc:'), false);

    const publicJson = user.toPublicJSON();
    assert.equal(publicJson.phone, plainNumber);
    assert.equal(publicJson.phone.startsWith('enc:'), false);
  });

  it('generates and verifies email OTP successfully', async () => {
    const testEmail = `verify_${Date.now()}@photostudio.com`;
    const res = await otpService.generateAndSendEmailOtp(testEmail, 'TestCreator');

    assert.equal(res.success, true);
    assert.ok(res.debugOtp);
    assert.equal(res.debugOtp.length, 6);

    // Verify correct OTP
    const isValid = await otpService.verifyEmailOtp(testEmail, res.debugOtp);
    assert.equal(isValid, true);
  });

  it('rejects incorrect email OTP', async () => {
    const testEmail = `wrongotp_${Date.now()}@photostudio.com`;
    await otpService.generateAndSendEmailOtp(testEmail, 'TestUser');

    await assert.rejects(
      async () => {
        await otpService.verifyEmailOtp(testEmail, '000000');
      },
      /Incorrect verification code/
    );
  });

  it('finds user by email or by username for login', async () => {
    const username = `login_user_${Date.now()}`;
    const email = `${username}@studio.com`;
    await userRepository.createUser({
      username,
      email,
      phone: '9123456789',
      password: 'hashed_password',
    });

    const byUser = await userRepository.findByUsername(username);
    assert.ok(byUser);
    assert.equal(byUser.username, username);

    const byEmail = await userRepository.findByEmail(email);
    assert.ok(byEmail);
    assert.equal(byEmail.email, email);
  });
});
