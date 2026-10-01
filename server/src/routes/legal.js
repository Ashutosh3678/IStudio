const express = require('express');
const { APP_NAME, CONTACT_EMAIL, LAST_UPDATED, privacy, terms } = require('../legal/legalContent');

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

router.get(pages.privacy.path, (_req, res) => res.type('html').send(privacyHtml));
router.get(pages.terms.path, (_req, res) => res.type('html').send(termsHtml));
router.get('/terms', (_req, res) => res.redirect(301, pages.terms.path));

module.exports = router;
