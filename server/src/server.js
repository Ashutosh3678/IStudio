const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');

dotenv.config({ path: path.join(__dirname, '..', '.env') });

const express = require('express');
const swaggerUi = require('swagger-ui-express');
const cors = require('cors');
const helmet = require('helmet');
const { rateLimit } = require('express-rate-limit');
const { validateRuntimeConfig, parseCorsOrigins } = require('./config/runtime');
const { checkCloudinaryReadiness } = require('./config/cloudinary');
const logger = require('./config/logger');
const { requestLogger } = require('./middleware/requestLogger');

const { connectDb } = require('./config/db');
const authRoutes = require('./routes/auth');
const invoiceRoutes = require('./routes/invoices');
const clientRoutes = require('./routes/clients');
const eventRoutes = require('./routes/events');
const eventChildRoutes = require('./routes/eventChildren');

const app = express();
app.set('trust proxy', 1);
const openApiPath = path.join(__dirname, '..', '..', 'openapi.yaml');
validateRuntimeConfig();
const port = Number(process.env.PORT) || 5000;
const allowedOrigins = parseCorsOrigins();
const authRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 20,
  standardHeaders: 'draft-8',
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many authentication attempts. Please try again later.',
  },
});

app.use(helmet());
app.use(requestLogger);
app.use(cors({
  origin(origin, callback) {
    if (!origin || allowedOrigins.has(origin)) return callback(null, true);
    return callback(new Error('Origin is not allowed.'));
  },
}));
app.use(express.json({ limit: '6mb' }));

app.get('/openapi.yaml', (_req, res) => {
  if (fs.existsSync(openApiPath)) {
    return res.type('yaml').sendFile(openApiPath);
  }
  return res.status(404).json({ success: false, message: 'OpenAPI specification is not available.' });
});
app.use('/api-docs', (req, res, next) => {
  if (!fs.existsSync(openApiPath)) {
    return res.status(404).json({ success: false, message: 'API documentation is not available.' });
  }
  return next();
}, swaggerUi.serve, swaggerUi.setup(null, {
  swaggerOptions: { url: '/openapi.yaml' },
  customSiteTitle: 'Lumen Studio API Docs',
}));

app.get('/', (_req, res) => {
  res.json({
    success: true,
    service: 'lumen-studio-api',
    message: 'Lumen Studio API is running.',
    routes: {
      health: 'GET /api/health',
      signup: 'POST /api/auth/signup',
      login: 'POST /api/auth/login',
      me: 'GET /api/auth/me',
      profile: 'PATCH /api/auth/profile',
      logo: 'POST /api/auth/logo',
      invoices: 'GET /api/invoices',
      createInvoice: 'POST /api/invoices',
      invoice: 'GET /api/invoices/:id',
      updateInvoice: 'PATCH /api/invoices/:id',
      deleteInvoice: 'DELETE /api/invoices/:id',
      markPaid: 'POST /api/invoices/:id/paid',
      markPartial: 'POST /api/invoices/:id/partial',
      extendDueDate: 'PATCH /api/invoices/:id/due-date',
      clients: 'GET /api/clients',
      events: 'GET /api/events',
      payments: 'GET /api/events/:eventId/payments',
      expenses: 'GET /api/events/:eventId/expenses',
      deliverables: 'GET /api/events/:eventId/deliverables',
    },
  });
});

app.get('/privacy-policy', (_req, res) => {
  res.type('html').send(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Privacy Policy - LUMEN Studio</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; max-width: 800px; margin: 40px auto; padding: 0 20px; color: #222; background: #fafafa; }
    h1, h2 { color: #111; }
    .card { background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 28px; box-shadow: 0 2px 6px rgba(0,0,0,0.04); }
    .footer { margin-top: 30px; font-size: 0.9em; color: #64748b; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Privacy Policy for LUMEN Studio (Clients Hub)</h1>
    <p><strong>Effective Date:</strong> September 2026</p>
    <p>LUMEN Studio ("Clients Hub", "we", "us", or "our") respects your privacy. This Privacy Policy describes how we collect, store, and process your personal and business data when you use our mobile application and backend services.</p>
    <h2>1. Information We Collect</h2>
    <ul>
      <li><strong>Account Information:</strong> Studio name, username, phone number, email address, password hash, and optional profile branding logo.</li>
      <li><strong>Business Records:</strong> Client contact details, booking schedules, deliverables, payment totals, expenses, and invoices.</li>
      <li><strong>Uploaded Media:</strong> Studio logos and payment receipt proofs uploaded to secure storage.</li>
    </ul>
    <h2>2. How We Use and Protect Your Data</h2>
    <p>Your data is used solely to provide photography studio management, client relationship management, and invoice generation. Sensitive information is encrypted at rest using AES-256 and transmitted exclusively over HTTPS.</p>
    <h2>3. Data Retention & Account Deletion</h2>
    <p>You retain full ownership of your data. You may delete your account and all associated client, booking, and invoice records at any time directly within the mobile application under <strong>Profile &gt; Security &gt; Delete Account</strong>, or by emailing our support team.</p>
    <h2>4. Third-Party Services</h2>
    <p>We use trusted infrastructure providers including MongoDB Atlas for database storage, Cloudinary for media uploads, and Google OAuth for authentication.</p>
    <h2>5. Contact Us</h2>
    <p>If you have any questions about this Privacy Policy or your data, please contact us at: <a href="mailto:thakursaiprakashsingh@gmail.com">thakursaiprakashsingh@gmail.com</a>.</p>
    <div class="footer">&copy; 2026 LUMEN Studio. All rights reserved.</div>
  </div>
</body>
</html>`);
});

app.get('/api/health', (_req, res) => {
  res.json({ success: true, service: 'lumen-studio-api' });
});
app.get('/api/health/live', (_req, res) => {
  res.json({ success: true, status: 'live' });
});
app.get('/api/health/ready', async (_req, res) => {
  const mongoReady = require('mongoose').connection.readyState === 1;
  const cloudinary = await checkCloudinaryReadiness({ ping: process.env.NODE_ENV === 'production' });
  const ready = mongoReady && cloudinary.configured && cloudinary.reachable;
  return res.status(ready ? 200 : 503).json({
    success: ready,
    status: ready ? 'ready' : 'not_ready',
    dependencies: { mongodb: mongoReady, cloudinary },
  });
});

app.use('/api/auth', authRateLimit, authRoutes);
app.use('/api/invoices', invoiceRoutes);
app.use('/api/clients', clientRoutes);
app.use('/api/events', eventRoutes);
app.use('/api', eventChildRoutes);

app.use((error, req, res, _next) => {
  if (error.message === 'Origin is not allowed.') {
    logger.warn('CORS origin rejected', { requestId: req.requestId, origin: req.headers.origin });
    return res.status(403).json({ success: false, message: 'Origin is not allowed.' });
  }
  logger.error('Unhandled request error', logger.fromRequest(req, error));
  return res.status(500).json({ success: false, message: 'Unable to process the request.' });
});

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `No route for ${req.method} ${req.originalUrl}`,
  });
});

async function start() {
  process.on('unhandledRejection', (reason) => {
    logger.error('Unhandled promise rejection', reason instanceof Error ? reason : { error: reason });
  });
  process.on('uncaughtException', (error) => {
    logger.error('Uncaught exception', error);
    process.exit(1);
  });

  try {
    validateRuntimeConfig();
    await connectDb();
    app.listen(port, '0.0.0.0', () => {
      console.log(`Server running on port ${port}`);
      logger.info('API listening', {
        port,
        env: process.env.NODE_ENV || 'development',
        logLevel: logger.level,
      });
    });
  } catch (error) {
    logger.error('Failed to start API', error);
    process.exit(1);
  }
}

if (require.main === module) {
  start();
}

module.exports = { app, start };
