const path = require('path');
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

const { connectDb } = require('./config/db');
const authRoutes = require('./routes/auth');
const invoiceRoutes = require('./routes/invoices');

dotenv.config({ path: path.join(__dirname, '..', '.env') });

if (!process.env.JWT_SECRET || process.env.JWT_SECRET.includes('replace_with')) {
  console.error('Set JWT_SECRET in server/.env before starting the API.');
  process.exit(1);
}

const app = express();
const port = Number(process.env.PORT) || 5000;

app.use(cors());
app.use(express.json({ limit: '6mb' }));
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

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
    },
  });
});

app.get('/api/health', (_req, res) => {
  res.json({ success: true, service: 'lumen-studio-api' });
});

app.use('/api/auth', authRoutes);
app.use('/api/invoices', invoiceRoutes);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `No route for ${req.method} ${req.originalUrl}`,
  });
});

async function start() {
  try {
    await connectDb();
    app.listen(port, '0.0.0.0', () => {
      console.log(`Lumen API listening on http://localhost:${port}`);
      console.log(`Phone / LAN access: http://192.168.1.9:${port}`);
    });
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}

start();
