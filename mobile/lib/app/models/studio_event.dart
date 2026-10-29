import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';

enum EventStatus {
  upcoming,
  inProgress,
  paymentDue,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case EventStatus.upcoming:
        return 'Upcoming';
      case EventStatus.inProgress:
        return 'In Progress';
      case EventStatus.paymentDue:
        return 'Payment Due';
      case EventStatus.completed:
        return 'Completed';
      case EventStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum PaymentMethod {
  cash,
  upi,
  bankTransfer,
  card,
  other;

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.payments_outlined;
      case PaymentMethod.upi:
        return Icons.qr_code_2_rounded;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance_outlined;
      case PaymentMethod.card:
        return Icons.credit_card_outlined;
      case PaymentMethod.other:
        return Icons.receipt_outlined;
    }
  }

  static PaymentMethod fromString(String? value) {
    if (value == null) return PaymentMethod.upi;
    for (final method in PaymentMethod.values) {
      if (method.name.toLowerCase() == value.toLowerCase() ||
          method.label.toLowerCase() == value.toLowerCase()) {
        return method;
      }
    }
    return PaymentMethod.upi;
  }
}

@immutable
class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidAt,
    this.method = PaymentMethod.upi,
    this.reference,
    this.proof,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime paidAt;
  final PaymentMethod method;
  final String? reference;
  final String? proof;

  bool get hasProof => proof != null && proof!.trim().isNotEmpty;

  PaymentRecord copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? paidAt,
    PaymentMethod? method,
    String? reference,
    String? proof,
  }) {
    return PaymentRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      paidAt: paidAt ?? this.paidAt,
      method: method ?? this.method,
      reference: reference ?? this.reference,
      proof: proof ?? this.proof,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'paidAt': paidAt.toIso8601String(),
    'method': method.name,
    'reference': reference,
    'proof': proof,
  };

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidAt: DateTime.parse(json['paidAt'] as String),
      method: PaymentMethod.fromString(json['method'] as String?),
      reference: json['reference'] as String?,
      proof: json['proof'] as String?,
    );
  }
}

@immutable
class ExpenseRecord {
  const ExpenseRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.incurredAt,
  });

  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime incurredAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'incurredAt': incurredAt.toIso8601String(),
  };

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) {
    return ExpenseRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String? ?? 'General',
      incurredAt: DateTime.parse(json['incurredAt'] as String),
    );
  }
}

@immutable
class DeliverableTask {
  const DeliverableTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final bool isCompleted;

  DeliverableTask copyWith({bool? isCompleted}) {
    return DeliverableTask(
      id: id,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
  };

  factory DeliverableTask.fromJson(Map<String, dynamic> json) {
    return DeliverableTask(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

@immutable
class StudioEvent {
  const StudioEvent({
    required this.id,
    this.clientId,
    required this.title,
    required this.clientName,
    required this.eventType,
    required this.startsAt,
    this.endsAt,
    this.startTime = '10:00 AM',
    this.endTime = '04:00 PM',
    required this.location,
    this.latitude,
    this.longitude,
    required this.status,
    required this.totalAmount,
    double? amountReceived,
    this.payments = const [],
    this.expenses = const [],
    this.deliverables = const [],
    this.notes = '',
  }) : _customAmountReceived = amountReceived;

  final String id;
  final String? clientId;
  final String title;
  final String clientName;
  final String
  eventType; // Wedding, Maternity, Commercial, Newborn, Portrait, etc.
  final DateTime startsAt;
  final DateTime? endsAt;
  final String startTime;
  final String endTime;
  final String location;
  final double? latitude;
  final double? longitude;
  final EventStatus status;
  final double totalAmount;
  final double? _customAmountReceived;
  final List<PaymentRecord> payments;
  final List<ExpenseRecord> expenses;
  final List<DeliverableTask> deliverables;
  final String notes;


  /// Effective end date. If endsAt is null, falls back to startsAt (single-day event).
  DateTime get effectiveEndsAt => endsAt ?? startsAt;

  /// Duration of the event in days (inclusive: a 1-day event returns 1, 5-day returns 5).
  int get durationInDays {
    final start = DateTime(startsAt.year, startsAt.month, startsAt.day);
    final end = DateTime(effectiveEndsAt.year, effectiveEndsAt.month, effectiveEndsAt.day);
    final diff = end.difference(start).inDays;
    return diff >= 0 ? diff + 1 : 1;
  }

  /// Whether this shoot spans more than 1 day.
  bool get isMultiDay => durationInDays > 1;

  /// Returns every distinct calendar day in the event's date range.
  List<DateTime> get eventDays {
    final start = DateTime(startsAt.year, startsAt.month, startsAt.day);
    final days = <DateTime>[];
    for (int i = 0; i < durationInDays; i++) {
      days.add(start.add(Duration(days: i)));
    }
    return days;
  }

  /// Checks if [day] falls within this event's date range (inclusive).
  bool isOccurringOn(DateTime day) {
    final target = DateTime(day.year, day.month, day.day);
    final start = DateTime(startsAt.year, startsAt.month, startsAt.day);
    final end = DateTime(effectiveEndsAt.year, effectiveEndsAt.month, effectiveEndsAt.day);
    return !target.isBefore(start) && !target.isAfter(end);
  }

  /// Formatted date range: e.g. "1 Nov 2026 - 5 Nov 2026 (5 Days)" or "1 Nov 2026".
  String dateRangeFormatted([String format = 'd MMM yyyy']) {
    final startStr = DateFormat(format).format(startsAt);
    if (!isMultiDay) return startStr;
    final endStr = DateFormat(format).format(effectiveEndsAt);
    return '$startStr - $endStr ($durationInDays Days)';
  }

  /// Amount received is calculated dynamically from payments if present,
  /// otherwise falling back to explicit amountReceived or 0.
  double get amountReceived {
    if (payments.isNotEmpty) {
      return payments.fold(0.0, (acc, item) => acc + item.amount);
    }
    return _customAmountReceived ?? 0.0;
  }

  /// Remaining amount = Total agreed - Amount received
  double get remainingAmount =>
      (totalAmount - amountReceived).clamp(0.0, double.infinity);

  /// Total expenses = Sum of all recorded expenses
  double get totalExpenses =>
      expenses.fold(0.0, (acc, item) => acc + item.amount);

  /// Net Profit = Amount Received - Total Expenses
  double get netProfit => amountReceived - totalExpenses;

  /// Deliverables count
  int get completedTasksCount =>
      deliverables.where((task) => task.isCompleted).length;

  int get totalTasksCount => deliverables.length;

  double get progressRatio =>
      totalTasksCount == 0 ? 0.0 : (completedTasksCount / totalTasksCount);

  /// Calculates exact target start DateTime by parsing startTime (e.g. 10:00 AM or 02:30 PM)
  DateTime get fullStartDateTime {
    int hour = 10;
    int minute = 0;
    try {
      final clean = startTime.trim().toUpperCase();
      final isPm = clean.contains('PM');
      final isAm = clean.contains('AM');
      final parts = clean.replaceAll(RegExp(r'[^\d:]'), '').split(':');
      if (parts.isNotEmpty) {
        hour = int.tryParse(parts[0]) ?? 10;
        if (parts.length > 1) {
          minute = int.tryParse(parts[1]) ?? 0;
        }
        if (isPm && hour < 12) hour += 12;
        if (isAm && hour == 12) hour = 0;
      }
    } catch (_) {}
    return DateTime(startsAt.year, startsAt.month, startsAt.day, hour, minute);
  }

  /// Live duration until event begins
  Duration get timeUntilStart => fullStartDateTime.difference(DateTime.now());

  /// True if scheduled to start in <= 7 days and has not completed/ended
  bool get isWithin7Days {
    if (status == EventStatus.completed || status == EventStatus.cancelled) {
      return false;
    }
    final remaining = timeUntilStart;
    return remaining.inSeconds > -86400 && remaining <= const Duration(days: 7);
  }

  bool get isImminent => isWithin7Days && timeUntilStart.inHours <= 24;

  int get daysUntilStart => timeUntilStart.inDays;
  int get hoursUntilStart => timeUntilStart.inHours % 24;
  int get minutesUntilStart => timeUntilStart.inMinutes % 60;

  /// Formatted notification copy: "2 days and 14 hours left" or "18 hours left"
  String get countdownFormatted {
    final remaining = timeUntilStart;
    if (remaining.inSeconds <= 0) {
      return 'Today / Ongoing';
    }
    final days = daysUntilStart;
    final hours = hoursUntilStart;
    if (days >= 1) {
      final dayStr = days == 1 ? 'day' : 'days';
      final hourStr = hours == 1 ? 'hour' : 'hours';
      return '$days $dayStr, $hours $hourStr left';
    } else if (hours >= 1) {
      final hourStr = hours == 1 ? 'hour' : 'hours';
      return '$hours $hourStr left';
    } else {
      return '$minutesUntilStart mins left';
    }
  }

  /// Compact chip copy: "⏳ 2d 14h left"
  String get countdownChip {
    final remaining = timeUntilStart;
    if (remaining.inSeconds <= 0) return '🔥 Today';
    final days = daysUntilStart;
    final hours = hoursUntilStart;
    if (days >= 1) {
      return '⏳ ${days}d ${hours}h left';
    } else if (hours >= 1) {
      return '🚨 ${hours}h left';
    } else {
      return '🚨 ${minutesUntilStart}m left';
    }
  }

  /// Effective human-readable status considering both the event's lifecycle status
  /// and its scheduled date relative to [relativeTo] (defaults to current date).
  ///
  /// Classification rules:
  /// - Cancelled → Cancelled
  /// - Future event date → Upcoming
  /// - Today → Today
  /// - Past date + Completed → Completed
  /// - Past date + In Progress → Past · In Progress
  /// - Past date + Upcoming/stale status → Past / Needs Update, never Upcoming
  String effectiveStatusLabel([DateTime? relativeTo]) {
    if (status == EventStatus.cancelled) {
      return 'Cancelled';
    }

    final now = relativeTo ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventStart = DateTime(startsAt.year, startsAt.month, startsAt.day);
    final eventEnd = DateTime(effectiveEndsAt.year, effectiveEndsAt.month, effectiveEndsAt.day);

    if (eventStart.isAfter(today)) {
      return 'Upcoming';
    }

    if (!today.isBefore(eventStart) && !today.isAfter(eventEnd)) {
      return 'Today';
    }

    // Past date (eventDay.isBefore(today))
    if (status == EventStatus.completed) {
      return 'Completed';
    }
    if (status == EventStatus.inProgress) {
      return 'Past · In Progress';
    }
    return 'Past / Needs Update';
  }

  /// Reusable convenience getter for effective display status.
  String get displayStatus => effectiveStatusLabel();

  /// Status badge color corresponding to effective display status.
  Color effectiveStatusColor(BuildContext context, [DateTime? relativeTo]) =>
      AppColors.eventDisplayStatusColor(
        context,
        effectiveStatusLabel(relativeTo),
      );

  /// Status badge icon corresponding to effective display status.
  IconData effectiveStatusIcon([DateTime? relativeTo]) {
    final label = effectiveStatusLabel(relativeTo);
    switch (label) {
      case 'Completed':
        return Icons.check_circle_rounded;
      case 'Upcoming':
        return Icons.schedule_rounded;
      case 'Today':
        return Icons.today_rounded;
      case 'Past · In Progress':
        return Icons.timelapse_rounded;
      case 'Past / Needs Update':
        return Icons.history_rounded;
      case 'Cancelled':
      default:
        return Icons.cancel_outlined;
    }
  }

  bool get isPast =>
      status == EventStatus.completed ||
      effectiveEndsAt.isBefore(DateTime.now().subtract(const Duration(days: 1)));

  StudioEvent copyWith({
    String? id,
    String? clientId,
    String? title,
    String? clientName,
    String? eventType,
    DateTime? startsAt,
    DateTime? endsAt,
    bool clearEndsAt = false,
    String? startTime,
    String? endTime,
    String? location,
    double? latitude,
    double? longitude,
    bool clearLocationCoordinates = false,
    EventStatus? status,
    double? totalAmount,
    double? amountReceived,
    List<PaymentRecord>? payments,
    List<ExpenseRecord>? expenses,
    List<DeliverableTask>? deliverables,
    String? notes,
  }) {
    return StudioEvent(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      title: title ?? this.title,
      clientName: clientName ?? this.clientName,
      eventType: eventType ?? this.eventType,
      startsAt: startsAt ?? this.startsAt,
      endsAt: clearEndsAt ? null : endsAt ?? this.endsAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      latitude: clearLocationCoordinates ? null : latitude ?? this.latitude,
      longitude: clearLocationCoordinates ? null : longitude ?? this.longitude,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      amountReceived: amountReceived ?? this.amountReceived,
      payments: payments ?? this.payments,
      expenses: expenses ?? this.expenses,
      deliverables: deliverables ?? this.deliverables,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'clientId': clientId,
    'title': title,
    'clientName': clientName,
    'eventType': eventType,
    'startsAt': startsAt.toIso8601String(),
    'endsAt': endsAt?.toIso8601String(),
    'startTime': startTime,
    'endTime': endTime,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'status': status.name,
    'totalAmount': totalAmount,
    'amountReceived': _customAmountReceived,
    'payments': payments.map((item) => item.toJson()).toList(),
    'expenses': expenses.map((item) => item.toJson()).toList(),
    'deliverables': deliverables.map((item) => item.toJson()).toList(),
    'notes': notes,
  };

  factory StudioEvent.fromJson(Map<String, dynamic> json) {
    final payments = (json['payments'] as List<dynamic>? ?? [])
        .map(
          (item) =>
              PaymentRecord.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
    final expenses = (json['expenses'] as List<dynamic>? ?? [])
        .map(
          (item) =>
              ExpenseRecord.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
    final deliverables = (json['deliverables'] as List<dynamic>? ?? [])
        .map(
          (item) =>
              DeliverableTask.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
    final statusName = json['status'] as String? ?? EventStatus.upcoming.name;
    final status = EventStatus.values.firstWhere(
      (item) => item.name == statusName,
      orElse: () => EventStatus.upcoming,
    );
    return StudioEvent(
      id: json['id'] as String? ?? '',
      clientId: json['clientId'] as String?,
      title: json['title'] as String? ?? '',
      clientName: json['clientName'] as String? ?? '',
      eventType: json['eventType'] as String? ?? '',
      startsAt:
          DateTime.tryParse(json['startsAt'] as String? ?? '') ??
          DateTime.now(),
      endsAt: json['endsAt'] != null ? DateTime.tryParse(json['endsAt'] as String? ?? '') : null,
      startTime: json['startTime'] as String? ?? '10:00 AM',
      endTime: json['endTime'] as String? ?? '04:00 PM',
      location: json['location'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: status,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      amountReceived: (json['amountReceived'] as num?)?.toDouble(),
      payments: payments,
      expenses: expenses,
      deliverables: deliverables,
      notes: json['notes'] as String? ?? '',
    );
  }
}
