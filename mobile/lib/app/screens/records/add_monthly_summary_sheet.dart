import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/monthly_summary.dart';
import '../../providers/events_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/studio_button.dart';
import '../../widgets/studio_text_field.dart';

/// Enter shoot count, booked amount and expenses for a past month.
class AddMonthlySummarySheet extends StatefulWidget {
  const AddMonthlySummarySheet({super.key, this.initialMonth});

  final DateTime? initialMonth;

  static Future<void> show(BuildContext context, {DateTime? initialMonth}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => AddMonthlySummarySheet(initialMonth: initialMonth),
    );
  }

  @override
  State<AddMonthlySummarySheet> createState() => _AddMonthlySummarySheetState();
}

class _AddMonthlySummarySheetState extends State<AddMonthlySummarySheet> {
  final _formKey = GlobalKey<FormState>();
  final _shootsController = TextEditingController();
  final _bookedController = TextEditingController();
  final _expensesController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _month;
  double _booked = 0;
  double _expenses = 0;
  bool _saving = false;

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final base = widget.initialMonth ?? DateTime(now.year, now.month - 1);
    _month = DateTime(base.year, base.month);
    _bookedController.addListener(_recalc);
    _expensesController.addListener(_recalc);
    _loadExisting();
  }

  void _loadExisting() {
    final existing = context.read<EventsProvider>().summaryFor(_month);
    if (existing == null) return;
    _shootsController.text = existing.shootCount.toString();
    _bookedController.text = existing.totalBooked.toStringAsFixed(0);
    _expensesController.text = existing.totalExpenses.toStringAsFixed(0);
    _notesController.text = existing.notes;
  }

  void _recalc() {
    setState(() {
      _booked = double.tryParse(_bookedController.text.trim()) ?? 0;
      _expenses = double.tryParse(_expensesController.text.trim()) ?? 0;
    });
  }

  @override
  void dispose() {
    _shootsController.dispose();
    _bookedController.dispose();
    _expensesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _month.isAfter(now) ? now : _month,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year, now.month + 1, 0),
      helpText: 'SELECT MONTH & YEAR',
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: Theme.of(c).colorScheme.copyWith(
            primary: context.accentColor,
            surface: context.cardBg,
            onSurface: context.textMain,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _month = DateTime(picked.year, picked.month));
    _shootsController.clear();
    _bookedController.clear();
    _expensesController.clear();
    _notesController.clear();
    _loadExisting();
  }

  String? _amount(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Enter amount';
    final n = double.tryParse(t);
    if (n == null) return 'Invalid amount';
    if (n < 0) return 'Cannot be negative';
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await context.read<EventsProvider>().saveMonthlySummary(
        MonthlySummary(
          id: '',
          year: _month.year,
          month: _month.month,
          shootCount: int.parse(_shootsController.text.trim()),
          totalBooked: _booked,
          totalExpenses: _expenses,
          notes: _notesController.text.trim(),
        ),
      );
      if (!mounted) return;
      final root = Navigator.of(context, rootNavigator: true).context;
      Navigator.of(context).pop();
      if (root.mounted) {
        AppSnackBar.success(
          root,
          'Summary for ${DateFormat('MMMM yyyy').format(_month)} saved.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(
          context,
          e is ApiException ? e.message : 'Could not save summary.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final textMain = context.textMain;
    final textMuted = context.textMuted;
    final accent = context.accentColor;
    final profit = _booked - _expenses;
    final hasExisting =
        context.read<EventsProvider>().summaryFor(_month) != null;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.88,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xF5121622) : const Color(0xF8FFFFFF),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: AppColors.sky.withValues(alpha: isDark ? 0.28 : 0.18),
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Monthly Summary',
                            style: GoogleFonts.plusJakartaSans(
                              color: textMain,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Enter shoot count, expenses and profit for a previous month',
                            style: TextStyle(color: textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Divider(
                color: context.cardBorder.withValues(alpha: 0.3),
                height: 1,
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      Text(
                        'Month & Year',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickMonth,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: context.cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: context.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month_rounded,
                                  color: accent, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  DateFormat('MMMM yyyy').format(_month),
                                  style: TextStyle(
                                    color: textMain,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  color: textMuted),
                            ],
                          ),
                        ),
                      ),
                      if (hasExisting) ...[
                        const SizedBox(height: 8),
                        Text(
                          'A summary already exists for this month. Saving will replace it.',
                          style: TextStyle(
                            color: AppColors.urgencyWarning(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      StudioTextField(
                        label: 'Number of Shoots',
                        controller: _shootsController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.camera_alt_outlined,
                        validator: (v) {
                          final n = int.tryParse(v?.trim() ?? '');
                          if (n == null) return 'Enter number of shoots';
                          if (n < 0) return 'Cannot be negative';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      StudioTextField(
                        label: 'Total Booked Amount (₹)',
                        controller: _bookedController,
                        keyboardType: TextInputType.number,
                        validator: _amount,
                      ),
                      const SizedBox(height: 14),
                      StudioTextField(
                        label: 'Total Expenses (₹)',
                        controller: _expensesController,
                        keyboardType: TextInputType.number,
                        validator: _amount,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: accent.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Profit (Net)',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              _currency.format(profit),
                              style: TextStyle(
                                color: profit >= 0
                                    ? const Color(0xFF10B981)
                                    : AppColors.urgencyCritical(context),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      StudioTextField(
                        label: 'Notes (Optional)',
                        controller: _notesController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 28),
                      StudioButton(
                        label: 'Save Records',
                        onPressed: _saving ? null : _save,
                        isLoading: _saving,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
