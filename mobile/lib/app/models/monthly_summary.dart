/// A manually entered financial summary for a past month.
class MonthlySummary {
  const MonthlySummary({
    required this.id,
    required this.year,
    required this.month,
    required this.shootCount,
    required this.totalBooked,
    required this.totalExpenses,
    this.notes = '',
  });

  final String id;
  final int year;
  final int month;
  final int shootCount;
  final double totalBooked;
  final double totalExpenses;
  final String notes;

  double get profit => totalBooked - totalExpenses;

  bool isFor(DateTime date) => date.year == year && date.month == month;

  Map<String, dynamic> toJson() => {
    'year': year,
    'month': month,
    'shootCount': shootCount,
    'totalBooked': totalBooked,
    'totalExpenses': totalExpenses,
    'notes': notes,
  };

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    double num_(dynamic v) => (v as num?)?.toDouble() ?? 0;
    return MonthlySummary(
      id: (json['id'] ?? '').toString(),
      year: (json['year'] as num?)?.toInt() ?? 0,
      month: (json['month'] as num?)?.toInt() ?? 1,
      shootCount: (json['shootCount'] as num?)?.toInt() ?? 0,
      totalBooked: num_(json['totalBooked']),
      totalExpenses: num_(json['totalExpenses']),
      notes: (json['notes'] ?? '').toString(),
    );
  }
}
