const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const userRepository = require('../repositories/userRepository');

async function ensurePlayReviewAccount({
  email = process.env.PLAY_REVIEW_EMAIL,
  password = process.env.PLAY_REVIEW_PASSWORD,
  repository = userRepository,
} = {}) {
  const normalizedEmail = String(email || '').trim().toLowerCase();
  const reviewPassword = String(password || '');

  if (!normalizedEmail && !reviewPassword) return null;
  if (!normalizedEmail || !reviewPassword) {
    throw new Error('PLAY_REVIEW_EMAIL and PLAY_REVIEW_PASSWORD must both be set.');
  }
  if (!normalizedEmail.includes('@') || reviewPassword.length < 8) {
    throw new Error('Google Play review credentials are invalid.');
  }

  const existing = await repository.findByEmail(normalizedEmail);
  const hashedPassword = await bcrypt.hash(reviewPassword, 12);

  if (existing) {
    await repository.updateUser(existing._id || existing.id, { password: hashedPassword });
    return { created: false };
  }

  const usernameSuffix = crypto.createHash('sha256').update(normalizedEmail).digest('hex').slice(0, 12);
  await repository.createUser({
    username: `play_review_${usernameSuffix}`,
    email: normalizedEmail,
    ownerName: 'Google Play Reviewer',
    password: hashedPassword,
  });
  return { created: true };
}

module.exports = { ensurePlayReviewAccount };