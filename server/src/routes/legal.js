const express = require('express');
const { rateLimit } = require('express-rate-limit');
const { APP_NAME, CONTACT_EMAIL, LAST_UPDATED, privacy, terms } = require('../legal/legalContent');
const { createDataDeletionRequest } = require('../services/dataDeletionRequestService');
const { sendDeletionRequestNotification } = require('../services/emailService');
const logger = require('../config/logger');

const router = express.Router();

const escapeHtml = (value) =>
  String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');

const emailLink = `<a href="mailto:${CONTACT_EMAIL}">${escapeHtml(CONTACT_EMAIL)}</a>`;
const withEmail = (text) => escapeHtml(text).replace('{email}', emailLink);

function renderSection(section, index) {
  const body = section.body ? `<p>${withEmail(section.body)}</p>` : '';
  const points = section.points?.length
    ? `<ul>${section.points.map((p) => `<li>${withEmail(p)}</li>`).join('')}</ul>`
    : '';
  return `
    <section class="card">
      <h2><span class="num">${index + 1}</span>${escapeHtml(section.title)}</h2>
      ${body}${points}
    </section>`;
}

function renderPage(doc, otherDoc) {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${escapeHtml(doc.title)} - ${APP_NAME}</title>
  <style>
    :root { --ink: #0f172a; --body: #334155; --muted: #64748b; --accent: #4f46e5; --line: #e2e8f0; }
    * { box-sizing: border-box; }
    body { margin: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      line-height: 1.65; color: var(--body); background: #f8fafc; }
    main { max-width: 820px; margin: 0 auto; padding: 40px 20px 56px; }
    .brand { font-size: 13px; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: var(--accent); }
    h1 { margin: 6px 0 4px; font-size: 34px; color: var(--ink); }
    .updated { color: var(--muted); font-size: 14px; margin: 0 0 18px; }
    .intro { font-size: 16px; margin: 0 0 28px; }
    .card { background: #fff; border: 1px solid var(--line); border-radius: 14px; padding: 20px 22px;
      margin-bottom: 14px; box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04); }
    h2 { display: flex; align-items: center; gap: 10px; margin: 0 0 8px; font-size: 18px; color: var(--ink); }
    .num { display: inline-flex; align-items: center; justify-content: center; flex: none; width: 28px; height: 28px;
      border-radius: 50%; background: #eef2ff; color: var(--accent); font-size: 13px; font-weight: 800; }
    p { margin: 0; }
    ul { margin: 8px 0 0; padding-left: 22px; }
    li { margin-bottom: 6px; }
    a { color: var(--accent); }
    footer { margin-top: 28px; padding-top: 18px; border-top: 1px solid var(--line); font-size: 14px; color: var(--muted);
      display: flex; flex-wrap: wrap; justify-content: space-between; gap: 8px; }
  </style>
</head>
<body>
  <main>
    <div class="brand">${APP_NAME}</div>
    <h1>${escapeHtml(doc.title)}</h1>
    <p class="updated">Last updated ${LAST_UPDATED}</p>
    <p class="intro">${escapeHtml(doc.intro)}</p>
    ${doc.sections.map(renderSection).join('')}
    <footer>
      <span>&copy; ${new Date().getFullYear()} ${APP_NAME}. All rights reserved.</span>
      <a href="${otherDoc.path}">${escapeHtml(otherDoc.title)}</a>
    </footer>
  </main>
</body>
</html>`;
}

const pages = {
  privacy: { ...privacy, path: '/privacy-policy' },
  terms: { ...terms, path: '/terms-and-conditions' },
};
const privacyHtml = renderPage(pages.privacy, pages.terms);
const termsHtml = renderPage(pages.terms, pages.privacy);

function renderDeleteDataPage({ submitted = false, error = '' } = {}) {
  const result = submitted
    ? `<section class="result" role="status"><h2>Request received</h2><p>If an account matches these details, we’ll verify ownership before processing deletion. We may contact you at the email provided if more information is needed.</p></section>`
    : '';
  const errorMessage = error
    ? `<p class="error" role="alert">${escapeHtml(error)}</p>`
    : '';
  const form = submitted
    ? ''
    : `<form method="post" action="/delete-data" novalidate>
        ${errorMessage}
        <label for="email">Account email</label>
        <input id="email" name="email" type="email" autocomplete="email" maxlength="254" required>
        <label for="phone">Account phone number</label>
        <input id="phone" name="phone" type="tel" inputmode="tel" autocomplete="tel" maxlength="24" placeholder="10-digit number" required>
        <div class="trap" aria-hidden="true"><label for="company">Leave this field empty</label><input id="company" name="company" tabindex="-1" autocomplete="off"></div>
        <button type="submit">Submit deletion request</button>
      </form>`;

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="robots" content="noindex, follow">
  <title>Request data deletion - ${APP_NAME}</title>
  <style>
    :root { color-scheme: light; --ink: #241a20; --body: #4c4147; --muted: #766a70; --accent: #88304e; --line: #e5dce0; --paper: #fff; --ground: #f8f4f5; }
    * { box-sizing: border-box; }
    body { margin: 0; min-height: 100vh; background: radial-gradient(ellipse at 12% 0%, #f0e3e8 0, transparent 34rem), var(--ground); color: var(--body); font: 16px/1.55 system-ui, sans-serif; }
    main { width: min(100% - 32px, 620px); margin: 0 auto; padding: 48px 0 32px; }
    .brand { color: var(--accent); font-size: 13px; font-weight: 800; letter-spacing: 1.4px; text-transform: uppercase; }
    h1 { color: var(--ink); font: 700 34px/1.15 Georgia, serif; margin: 12px 0; }
    .intro { margin: 0 0 22px; }
    .panel { background: var(--paper); border: 1px solid var(--line); border-radius: 8px; padding: 24px; box-shadow: 0 12px 32px rgba(50, 20, 35, .06); }
    .notice { border-left: 3px solid var(--accent); padding: 10px 14px; background: #fbf6f8; font-size: 14px; margin-bottom: 22px; }
    label { display: block; color: var(--ink); font-size: 14px; font-weight: 700; margin: 16px 0 6px; }
    input { display: block; width: 100%; min-height: 48px; padding: 11px 12px; border: 1px solid #cfc2c8; border-radius: 5px; background: #fff; color: var(--ink); font: inherit; }
    input:focus { outline: 3px solid #88304e33; border-color: var(--accent); }
    button { display: inline-flex; justify-content: center; align-items: center; min-height: 48px; width: 100%; margin-top: 22px; padding: 10px 16px; border: 0; border-radius: 5px; background: var(--accent); color: #fff; font: inherit; font-weight: 700; cursor: pointer; }
    button:hover { background: #6f253f; }
    .error { color: #a12632; font-size: 14px; font-weight: 600; }
    .result h2 { margin: 0 0 8px; color: var(--ink); font-size: 20px; }
    .result p { margin: 0; }
    .trap { position: absolute; left: -10000px; width: 1px; height: 1px; overflow: hidden; }
    .help { margin: 18px 0 0; font-size: 14px; color: var(--muted); }
    a { color: var(--accent); }
    footer { display: flex; flex-wrap: wrap; gap: 8px 18px; border-top: 1px solid var(--line); margin-top: 28px; padding-top: 16px; font-size: 13px; }
    @media (max-width: 480px) { main { padding-top: 28px; } h1 { font-size: 29px; } .panel { padding: 19px; } }
  </style>
</head>
<body>
  <main>
    <div class="brand">${APP_NAME}</div>
    <h1>Request data deletion</h1>
    <p class="intro">Submit the email address and phone number linked to your account. We use them to locate your account and verify your request before deleting associated data.</p>
    <section class="panel">
      <div class="notice">Submitting this form does not immediately delete an account. If you can sign in, use Profile &gt; Account Settings &gt; Delete Account to complete deletion in the app.</div>
      ${result}${form}
    </section>
    <p class="help">Need help? Contact <a href="mailto:${CONTACT_EMAIL}">${escapeHtml(CONTACT_EMAIL)}</a>. Never send your password.</p>
    <footer><a href="/privacy-policy">Privacy policy</a><a href="/terms-and-conditions">Terms and conditions</a></footer>
  </main>
</body>
</html>`;
}

const deletionRequestLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 5,
  standardHeaders: 'draft-8',
  legacyHeaders: false,
  handler: (_req, res) => res.status(429).type('html').send(renderDeleteDataPage({
    error: 'Too many requests. Please try again later.',
  })),
});

router.get(pages.privacy.path, (_req, res) => res.type('html').send(privacyHtml));
router.get(pages.terms.path, (_req, res) => res.type('html').send(termsHtml));
router.get('/terms', (_req, res) => res.redirect(301, pages.terms.path));
router.get('/delete-data', (_req, res) => res.type('html').send(renderDeleteDataPage()));
router.post('/delete-data', deletionRequestLimiter, async (req, res) => {
  if (String(req.body?.company || '').trim()) {
    return res.type('html').send(renderDeleteDataPage({ submitted: true }));
  }

  const email = String(req.body?.email || '').trim().toLowerCase();
  const rawPhone = String(req.body?.phone || '').trim();
  const phoneDigits = rawPhone.replace(/\D/g, '');
  const phone =
    phoneDigits.length === 12 && phoneDigits.startsWith('91')
      ? phoneDigits.slice(2)
      : phoneDigits.length === 11 && phoneDigits.startsWith('0')
        ? phoneDigits.slice(1)
        : phoneDigits;

  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 254) {
    return res.status(400).type('html').send(renderDeleteDataPage({
      error: 'Enter a valid account email address.',
    }));
  }
  if (!/^\d{10}$/.test(phone)) {
    return res.status(400).type('html').send(renderDeleteDataPage({
      error: 'Enter the 10-digit phone number linked to your account.',
    }));
  }

  try {
    const request = await createDataDeletionRequest({ email, phone });
    const notification = await sendDeletionRequestNotification({
      requestId: request.id,
      email,
      phone,
      createdAt: request.createdAt,
    });
    if (!notification.sent) {
      logger.warn('Data deletion request saved without email notification', {
        requestId: request.id,
        reason: notification.reason,
      });
    }
    return res.type('html').send(renderDeleteDataPage({ submitted: true }));
  } catch (error) {
    logger.error('Unable to save data deletion request', { error });
    return res.status(503).type('html').send(renderDeleteDataPage({
      error: 'We could not save your request right now. Please try again or contact support.',
    }));
  }
});

module.exports = router;
