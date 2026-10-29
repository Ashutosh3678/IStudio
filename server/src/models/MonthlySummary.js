const mongoose = require('mongoose');

const monthlySummarySchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  year: { type: Number, required: true, min: 2000, max: 2100 },
  month: { type: Number, required: true, min: 1, max: 12 },
  shootCount: { type: Number, required: true, min: 0, default: 0 },
  totalBooked: { type: Number, required: true, min: 0, default: 0 },
  totalExpenses: { type: Number, required: true, min: 0, default: 0 },
  notes: { type: String, default: '', trim: true, maxlength: 2000 },
}, { timestamps: true });

monthlySummarySchema.index({ userId: 1, year: 1, month: 1 }, { unique: true });

monthlySummarySchema.methods.toPublicJSON = function toPublicJSON() {
  return {
    id: this._id.toString(),
    year: this.year,
    month: this.month,
    shootCount: this.shootCount,
    totalBooked: this.totalBooked,
    totalExpenses: this.totalExpenses,
    profit: this.totalBooked - this.totalExpenses,
    notes: this.notes || '',
    createdAt: this.createdAt,
    updatedAt: this.updatedAt,
  };
};

module.exports = mongoose.model('MonthlySummary', monthlySummarySchema);
