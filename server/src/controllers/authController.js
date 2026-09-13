const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { validationResult } = require('express-validator');

const userRepository = require('../repositories/userRepository');

function normalizePhone(value = '') {
  let digits = String(value).replace(/\D/g, '');
  if (digits.startsWith('91') && digits.length === 12) {
    digits = digits.slice(2);
  }
  if (digits.startsWith('0') && digits.length === 11) {
    digits = digits.slice(1);
  }
  return digits;
}

function signToken(user) {
  return jwt.sign(
    {
      id: user._id.toString(),
      username: user.username,
      phone: user.phone,
    },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' },
  );
}

function sendValidationError(req, res) {
  const errors = validationResult(req);
  if (errors.isEmpty()) return false;

  return res.status(400).json({
    success: false,
    message: errors.array()[0].msg,
  });
}

async function signup(req, res) {
  if (sendValidationError(req, res)) return;

  try {
    const username = String(req.body.username || '').trim();
    const phone = normalizePhone(req.body.phone);
    const password = String(req.body.password || '');

    const existingPhone = await userRepository.findByPhone(phone);
    if (existingPhone) {
      return res.status(409).json({
        success: false,
        message: 'An account with this phone number already exists.',
      });
    }

    const existingUsername = await userRepository.findByUsername(username);
    if (existingUsername) {
      return res.status(409).json({
        success: false,
        message: 'That username is already taken.',
      });
    }

    const hashedPassword = await bcrypt.hash(password, 12);
    const user = await userRepository.createUser({
      username,
      phone,
      password: hashedPassword,
    });

    return res.status(201).json({
      success: true,
      token: signToken(user),
      user: user.toPublicJSON(),
    });
  } catch (error) {
    console.error('Signup error:', error);
    return res.status(500).json({
      success: false,
      message: 'Unable to create your account right now.',
    });
  }
}

async function login(req, res) {
  if (sendValidationError(req, res)) return;

  try {
    const phone = normalizePhone(req.body.phone);
    const password = String(req.body.password || '');

    const user = await userRepository.findByPhone(phone, { withPassword: true });
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Phone number or password is incorrect.',
      });
    }

    const matches = await bcrypt.compare(password, user.password);
    if (!matches) {
      return res.status(401).json({
        success: false,
        message: 'Phone number or password is incorrect.',
      });
    }

    return res.json({
      success: true,
      token: signToken(user),
      user: user.toPublicJSON(),
    });
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({
      success: false,
      message: 'Unable to sign in right now.',
    });
  }
}

async function me(req, res) {
  try {
    const user = await userRepository.findById(req.userId);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Your session is no longer valid.',
      });
    }

    return res.json({
      success: true,
      user: user.toPublicJSON(),
    });
  } catch (error) {
    console.error('Session error:', error);
    return res.status(500).json({
      success: false,
      message: 'Unable to restore your session.',
    });
  }
}

module.exports = {
  signup,
  login,
  me,
  normalizePhone,
};
