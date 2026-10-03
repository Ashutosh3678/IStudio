'use strict';

const assert = require('node:assert/strict');
const { describe, it, before } = require('node:test');

process.env.DATA_ENCRYPTION_KEY = 'd7a9f8b4c2e105829374650192837465f1e2d3c4b5a697887766554433221100';
process.env.JWT_SECRET = 'test-jwt-secret-key-32chars-min!!';

const userRepository = require('../src/repositories/userRepository');
const memoryUsers = require('../src/store/memoryUsers');
const otpService = require('../src/services/otpService');
const emailService = require('../src/services/emailService');

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
    const originalSend = emailService.sendVerificationEmail;
    let sentOtp;
    emailService.sendVerificationEmail = async ({ otp }) => {
      sentOtp = otp;
      return { sent: true };
    };

    try {
      const res = await otpService.generateAndSendEmailOtp(testEmail, 'TestCreator');

      assert.equal(res.success, true);
      assert.equal(res.message, `Verification code sent to ${testEmail}.`);
      assert.equal('debugOtp' in res, false);
      assert.equal(sentOtp.length, 6);

      const isValid = await otpService.verifyEmailOtp(testEmail, sentOtp);
      assert.equal(isValid, true);
    } finally {
      emailService.sendVerificationEmail = originalSend;
    }
  });

  it('rejects incorrect email OTP', async () => {
    const testEmail = `wrongotp_${Date.now()}@photostudio.com`;
    const originalSend = emailService.sendVerificationEmail;
    let sentOtp;
    emailService.sendVerificationEmail = async ({ otp }) => {
      sentOtp = otp;
      return { sent: true };
    };

    try {
      await otpService.generateAndSendEmailOtp(testEmail, 'TestUser');

      await assert.rejects(
        async () => {
          await otpService.verifyEmailOtp(testEmail, sentOtp === '000000' ? '000001' : '000000');
        },
        /Incorrect verification code/
      );
    } finally {
      emailService.sendVerificationEmail = originalSend;
    }
  });

  it('does not issue or retain an email OTP when delivery fails', async () => {
    const testEmail = `undelivered_${Date.now()}@photostudio.com`;
    const originalSend = emailService.sendVerificationEmail;
    emailService.sendVerificationEmail = async () => ({ sent: false });

    try {
      await assert.rejects(
        () => otpService.generateAndSendEmailOtp(testEmail, 'TestUser'),
        { statusCode: 503 },
      );
      await assert.rejects(
        () => otpService.verifyEmailOtp(testEmail, '123456'),
        /No active verification code/
      );
    } finally {
      emailService.sendVerificationEmail = originalSend;
    }
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
