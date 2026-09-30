const nodemailer = require('nodemailer');
const logger = require('../config/logger');

let transporter = null;

function getTransporter() {
  if (transporter) return transporter;

  const host = process.env.SMTP_HOST;
  const user = process.env.SMTP_USER || process.env.GMAIL_USER;
  const pass = process.env.SMTP_PASS || process.env.GMAIL_APP_PASSWORD;

  if (host && user && pass) {
    transporter = nodemailer.createTransport({
      host,
      port: Number(process.env.SMTP_PORT) || 587,
      secure: process.env.SMTP_SECURE === 'true' || process.env.SMTP_PORT === '465',
      auth: { user, pass },
    });
  } else if (process.env.GMAIL_USER && process.env.GMAIL_APP_PASSWORD) {
    transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.GMAIL_USER,
        pass: process.env.GMAIL_APP_PASSWORD,
      },
    });
  }

  return transporter;
}

function renderOtpEmailHtml({ otp, username }) {
  const brandName = 'CLIENTS HUB';
  const subTitle = 'STUDIO OS';

  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Your Verification Code - ${brandName}</title>
  <style>
    body {
      margin: 0;
      padding: 0;
      background-color: #0b0f17;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      color: #e2e8f0;
    }
    .wrapper {
      max-width: 560px;
      margin: 40px auto;
      padding: 32px 24px;
      background: #111827;
      border: 1px solid #1e293b;
      border-radius: 20px;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
    }
    .header {
      text-align: center;
      margin-bottom: 28px;
    }
    .brand-title {
      font-size: 24px;
      font-weight: 800;
      letter-spacing: 3px;
      color: #ffffff;
      margin: 0;
    }
    .brand-tag {
      display: inline-block;
      margin-top: 6px;
      font-size: 10px;
      font-weight: 700;
      letter-spacing: 2px;
      color: #60a5fa;
      background: rgba(96, 165, 250, 0.15);
      border: 1px solid rgba(96, 165, 250, 0.3);
      padding: 3px 10px;
      border-radius: 999px;
    }
    .greeting {
      font-size: 16px;
      color: #94a3b8;
      margin-bottom: 12px;
    }
    .message {
      font-size: 15px;
      line-height: 1.6;
      color: #cbd5e1;
      margin-bottom: 24px;
    }
    .otp-card {
      background: #1e293b;
      border: 1px solid #334155;
      border-radius: 14px;
      padding: 24px;
      text-align: center;
      margin: 28px 0;
    }
    .otp-code {
      font-size: 36px;
      font-weight: 800;
      letter-spacing: 8px;
      color: #38bdf8;
      font-family: monospace;
      margin: 0;
    }
    .otp-expiry {
      font-size: 12px;
      color: #94a3b8;
      margin-top: 10px;
    }
    .footer {
      border-top: 1px solid #1e293b;
      padding-top: 20px;
      margin-top: 32px;
      font-size: 12px;
      color: #64748b;
      text-align: center;
      line-height: 1.5;
    }
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="header">
      <h1 class="brand-title">${brandName}</h1>
      <span class="brand-tag">${subTitle}</span>
    </div>

    <p class="greeting">Hello${username ? ` <strong>${username}</strong>` : ''},</p>
    <p class="message">
      Thank you for joining <strong>${brandName}</strong>. Please use the following 6-digit verification code to verify your email address and complete your account setup:
    </p>

    <div class="otp-card">
      <div class="otp-code">${otp}</div>
      <div class="otp-expiry">Valid for 10 minutes • Do not share this code with anyone.</div>
    </div>

    <p class="message" style="font-size: 13px; color: #94a3b8;">
      If you did not request this verification code, you can safely ignore this email.
    </p>

    <div class="footer">
      © ${new Date().getFullYear()} ${brandName} (${subTitle}). All rights reserved.
    </div>
  </div>
</body>
</html>
  `;
}

async function sendVerificationEmail({ to, otp, username = '' }) {
  const mailTransporter = getTransporter();
  const subject = `Your Verification Code: ${otp} - Clients Hub`;
  const from = process.env.EMAIL_FROM || '"Clients Hub Studio" <no-reply@clientshub.com>';
  const text = `Hello${username ? ' ' + username : ''},\n\nYour Clients Hub verification code is: ${otp}\nThis code is valid for 10 minutes.\n\nIf you did not request this, please ignore this email.`;
  const html = renderOtpEmailHtml({ otp, username });

  if (!mailTransporter) {
    logger.info(`[EmailService] SMTP not configured. Verification code for ${to} is: ${otp}`);
    return { sent: false, reason: 'smtp_not_configured', otp };
  }

  try {
    const info = await mailTransporter.sendMail({
      from,
      to,
      subject,
      text,
      html,
    });
    logger.info('[EmailService] Verification email sent successfully', {
      to,
      messageId: info.messageId,
    });
    return { sent: true, messageId: info.messageId };
  } catch (err) {
    logger.error('[EmailService] Failed to send verification email', {
      to,
      error: err.message,
    });
    return { sent: false, error: err.message, otp };
  }
}

module.exports = {
  sendVerificationEmail,
};
