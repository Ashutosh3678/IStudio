const path = require('path');
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

const { connectDb } = require('./config/db');
const authRoutes = require('./routes/auth');

dotenv.config({ path: path.join(__dirname, '..', '.env') });

if (!process.env.JWT_SECRET || process.env.JWT_SECRET.includes('replace_with')) {
  process.env.JWT_SECRET = 'lumen-dev-secret-change-me';
  console.warn('Using a development JWT secret. Set JWT_SECRET in .env before production.');
}

const app = express();
const port = Number(process.env.PORT) || 5000;

app.use(cors());
app.use(express.json());

app.get('/api/health', (_req, res) => {
  res.json({ success: true, service: 'lumen-studio-api' });
});

app.use('/api/auth', authRoutes);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `No route for ${req.method} ${req.originalUrl}`,
  });
});

async function start() {
  try {
    await connectDb();
    app.listen(port, () => {
      console.log(`Lumen API listening on http://localhost:${port}`);
    });
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}

start();
