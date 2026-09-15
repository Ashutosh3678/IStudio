const express = require('express');
const { body } = require('express-validator');

const { requireAuth } = require('../middleware/auth');
const {
  listInvoices,
  getInvoice,
  createInvoice,
  updateInvoice,
  deleteInvoice,
  markPaid,
  markPartial,
  extendDueDate,
} = require('../controllers/invoiceController');
const { normalizePhone } = require('../controllers/authController');

const router = express.Router();

router.use(requireAuth);

const createRules = [
  body('eventName').trim().notEmpty().withMessage('Enter the event name'),
  body('contactName')
    .trim()
    .notEmpty()
    .withMessage('Enter the contact person name'),
  body('phone')
    .customSanitizer(normalizePhone)
    .isLength({ min: 10, max: 10 })
    .withMessage('Enter a valid 10-digit phone number'),
  body('address').trim().notEmpty().withMessage('Enter a billing address'),
  body('dueDate').notEmpty().withMessage('Choose a due date'),
  body('deliverables')
    .isArray({ min: 1 })
    .withMessage('Add at least one deliverable'),
  body('deliverables.*.name')
    .trim()
    .notEmpty()
    .withMessage('Each deliverable needs a name'),
  body('deliverables.*.cost')
    .isFloat({ gt: 0 })
    .withMessage('Each deliverable needs a cost greater than 0'),
];

router.get('/', listInvoices);
router.post('/', createRules, createInvoice);
router.get('/:id', getInvoice);
router.patch('/:id', updateInvoice);
router.delete('/:id', deleteInvoice);
router.post('/:id/paid', markPaid);
router.post(
  '/:id/partial',
  [body('amount').isFloat({ gt: 0 }).withMessage('Enter a payment amount greater than 0')],
  markPartial,
);
router.patch(
  '/:id/due-date',
  [body('dueDate').notEmpty().withMessage('Enter a valid due date')],
  extendDueDate,
);

module.exports = router;
