const express = require('express');
const { body, validationResult } = require('express-validator');
const mongoose = require('mongoose');
const { requireAuth } = require('../middleware/auth');
const { idempotency } = require('../middleware/idempotency');
const MonthlySummary = require('../models/MonthlySummary');

const router = express.Router();
router.use(requireAuth);

const writableFields = ['year', 'month', 'shootCount', 'totalBooked', 'totalExpenses', 'notes'];

const rules = [
  body('year').isInt({ min: 2000, max: 2100 }).withMessage('Enter a valid year.'),
  body('month').isInt({ min: 1, max: 12 }).withMessage('Enter a valid month.'),
  body('shootCount').isInt({ min: 0, max: 10000 }).withMessage('Enter a valid number of shoots.'),
  body('totalBooked').isFloat({ min: 0 }).withMessage('Enter a valid total booked amount.'),
  body('totalExpenses').isFloat({ min: 0 }).withMessage('Enter valid total expenses.'),
  body('notes').optional().trim().isLength({ max: 2000 }),
];

function pick(source) {
  const out = {};
  for (const key of writableFields) if (source[key] !== undefined) out[key] = source[key];
  return out;
}

function invalid(req, res) {
  const errors = validationResult(req);
  if (errors.isEmpty()) return false;
  res.status(400).json({ success: false, message: errors.array()[0].msg });
  return true;
}

router.get('/', async (req, res) => {
  const items = await MonthlySummary.find({ userId: req.userId }).sort({ year: -1, month: -1 });
  return res.json({ success: true, summaries: items.map((i) => i.toPublicJSON()) });
});

router.post('/', idempotency, rules, async (req, res) => {
  if (invalid(req, res)) return;
  try {
    const created = await MonthlySummary.create({ ...pick(req.body), userId: req.userId });
    return res.status(201).json({ success: true, summary: created.toPublicJSON() });
  } catch (error) {
    if (error && error.code === 11000) {
      return res.status(409).json({ success: false, message: 'A summary for this month already exists.' });
    }
    throw error;
  }
});

router.put('/:id', rules, async (req, res) => {
  if (!mongoose.isValidObjectId(req.params.id)) {
    return res.status(404).json({ success: false, message: 'Summary not found.' });
  }
  if (invalid(req, res)) return;
  try {
    const updated = await MonthlySummary.findOneAndUpdate(
      { _id: req.params.id, userId: req.userId },
      { $set: pick(req.body) },
      { new: true, runValidators: true },
    );
    if (!updated) return res.status(404).json({ success: false, message: 'Summary not found.' });
    return res.json({ success: true, summary: updated.toPublicJSON() });
  } catch (error) {
    if (error && error.code === 11000) {
      return res.status(409).json({ success: false, message: 'A summary for this month already exists.' });
    }
    throw error;
  }
});

router.delete('/:id', async (req, res) => {
  if (!mongoose.isValidObjectId(req.params.id)) {
    return res.status(404).json({ success: false, message: 'Summary not found.' });
  }
  const removed = await MonthlySummary.findOneAndDelete({ _id: req.params.id, userId: req.userId });
  if (!removed) return res.status(404).json({ success: false, message: 'Summary not found.' });
  return res.json({ success: true });
});

module.exports = router;
