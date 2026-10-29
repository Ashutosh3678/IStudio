import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/client.dart';
import '../../models/studio_event.dart';
import '../../providers/events_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/validators.dart';
import '../../widgets/studio_button.dart';
import '../../widgets/studio_text_field.dart';

/// Records a shoot that already happened. Mirrors the "Create New Event"
/// sheet, but the date is in the past, payments/expenses are entered directly
/// and the event is saved as completed.
class AddPastEventSheet extends StatefulWidget {
  const AddPastEventSheet({super.key, this.initialMonth});

  /// Pre-selects a date inside this month (used from Monthly Earnings).
  final DateTime? initialMonth;

  static Future<void> show(BuildContext context, {DateTime? initialMonth}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => AddPastEventSheet(initialMonth: initialMonth),
    );
  }

  @override
  State<AddPastEventSheet> createState() => _AddPastEventSheetState();
}

class _AddPastEventSheetState extends State<AddPastEventSheet> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  String? _formValidationError;
  bool _isSubmitting = false;

  Client? _selectedClient;

  final _nameController = TextEditingController();
  final _clientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _totalController = TextEditingController();
  final _receivedController = TextEditingController();
  final _expensesController = TextEditingController();
  final _customEventTypeController = TextEditingController();

  String _eventType = 'Wedding';
  late DateTime _startDate;
  late DateTime _endDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  PaymentMethod _method = PaymentMethod.upi;

  double _total = 0;
  double _received = 0;
  double _expenses = 0;

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static const _eventTypes = [
    'Wedding',
    'Maternity',
    'Commercial',
    'Newborn',
    'Pre-wedding',
    'Portrait',
    'Fashion',
    'Event',
    'Others',
  ];

  IconData _categoryIcon(String type) {
    switch (type.toLowerCase()) {
      case 'wedding':
        return Icons.favorite_rounded;
      case 'pre-wedding':
        return Icons.photo_camera_front_rounded;
      case 'maternity':
        return Icons.child_care_rounded;
      case 'newborn':
        return Icons.baby_changing_station_rounded;
      case 'portrait':
        return Icons.portrait_rounded;
      case 'fashion':
        return Icons.style_rounded;
      case 'commercial':
        return Icons.business_center_rounded;
      case 'event':
        return Icons.celebration_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  int get _durationInDays {
    final diff = _endDate.difference(_startDate).inDays;
    return diff >= 0 ? diff + 1 : 1;
  }

  double get _due => (_total - _received).clamp(0.0, double.infinity);
  double get _profit => _received - _expenses;

  @override
  void initState() {
    super.initState();
    var initial = _today.subtract(const Duration(days: 1));
    final m = widget.initialMonth;
    if (m != null) {
      final endOfMonth = DateTime(m.year, m.month + 1, 0);
      initial = endOfMonth.isAfter(_today) ? _today : endOfMonth;
    }
    _startDate = initial;
    _endDate = initial;
    _totalController.addListener(_onAmountChanged);
    _receivedController.addListener(_onAmountChanged);
    _expensesController.addListener(_onAmountChanged);
    _clientController.addListener(_onClientNameChanged);
  }

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _clientController,
      _phoneController,
      _locationController,
      _notesController,
      _totalController,
      _receivedController,
      _expensesController,
      _customEventTypeController,
    ]) {
      c.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    setState(() {
      _total = double.tryParse(_totalController.text.trim()) ?? 0;
      _received = double.tryParse(_receivedController.text.trim()) ?? 0;
      _expenses = double.tryParse(_expensesController.text.trim()) ?? 0;
    });
  }

  void _onClientNameChanged() {
    final name = _clientController.text.trim();
    if (name.isEmpty) return;
    final match = context.read<EventsProvider>().clients.where(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
    );
    if (match.isNotEmpty &&
        match.first.phone.isNotEmpty &&
        _phoneController.text.isEmpty) {
      _phoneController.text = Validators.normalizePhone(match.first.phone);
    }
  }

  ThemeData _pickerTheme(BuildContext context) => Theme.of(context).copyWith(
    colorScheme: Theme.of(context).colorScheme.copyWith(
      primary: context.accentColor,
      surface: context.cardBg,
      onSurface: context.textMain,
    ),
  );

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(_today.year - 10),
      lastDate: _today,
      helpText: 'SELECT SHOOT START DATE',
      builder: (c, child) => Theme(data: _pickerTheme(c), child: child!),
    );
    if (picked == null) return;
    setState(() {
      final span = _endDate.difference(_startDate).inDays;
      _startDate = picked;
      var end = span > 0 ? picked.add(Duration(days: span)) : picked;
      if (end.isAfter(_today)) end = _today;
      _endDate = end;
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: _today,
      helpText: 'SELECT SHOOT END DATE',
      builder: (c, child) => Theme(data: _pickerTheme(c), child: child!),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (c, child) => Theme(data: _pickerTheme(c), child: child!),
    );
    if (picked == null) return;
    setState(() => isStart ? _startTime = picked : _endTime = picked);
  }

  void _scrollTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.heavyImpact();
      setState(() {
        _formValidationError =
            'Please fix the highlighted required fields above.';
      });
      AppSnackBar.error(context, 'Please fill in the required fields.');
      _scrollTop();
      return;
    }
    if (_received > _total) {
      AppSnackBar.error(context, 'Amount received cannot exceed the total amount.');
      return;
    }
    setState(() => _formValidationError = null);
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<EventsProvider>();
      final startsAt = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );
      final endsAt = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );
      final startLabel = _startTime.format(context);
      final endLabel = _endTime.format(context);

      String clientId;
      String clientName;
      if (_selectedClient != null) {
        clientId = _selectedClient!.id;
        clientName = _selectedClient!.name;
      } else {
        clientName = _clientController.text.trim();
        final existing = provider.clients.where(
          (c) => c.name.toLowerCase() == clientName.toLowerCase(),
        );
        if (existing.isNotEmpty) {
          clientId = existing.first.id;
        } else {
          final created = await provider.addClient(
            Client(
              id: 'cli-${DateTime.now().millisecondsSinceEpoch}',
              name: clientName,
              phone: _phoneController.text.trim(),
              email: '',
              status: ClientStatus.completed,
              createdAt: DateTime.now(),
            ),
          );
          clientId = created.id;
        }
      }

      final type =
          (_eventType == 'Others' &&
              _customEventTypeController.text.trim().isNotEmpty)
          ? _customEventTypeController.text.trim()
          : _eventType;
      final loc = _locationController.text.trim();
      final stamp = DateTime.now().millisecondsSinceEpoch;

      final event = StudioEvent(
        id: 'evt-$stamp',
        title: _nameController.text.trim(),
        eventType: type,
        clientId: clientId,
        clientName: clientName,
        status: EventStatus.completed,
        location: loc.isEmpty ? 'Studio / On Location' : loc,
        startsAt: startsAt,
        endsAt: endsAt,
        startTime: startLabel,
        endTime: endLabel,
        totalAmount: _total,
        payments: [
          if (_received > 0)
            PaymentRecord(
              id: 'pay-$stamp',
              title: 'Payment Received',
              amount: _received,
              paidAt: endsAt,
              method: _method,
            ),
        ],
        expenses: [
          if (_expenses > 0)
            ExpenseRecord(
              id: 'exp-$stamp',
              title: 'Event Expenses',
              amount: _expenses,
              category: 'Other',
              incurredAt: endsAt,
            ),
        ],
        notes: _notesController.text.trim(),
        deliverables: const [],
      );

      await provider.addPastEvent(event);
      if (!mounted) return;
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      Navigator.of(context).pop();
      if (rootContext.mounted) {
        AppSnackBar.success(
          rootContext,
          'Past event "${event.title}" added to records.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(
          context,
          e is ApiException
              ? e.message
              : 'Could not save past event. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ---------------------------------------------------------------- UI

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: context.textMain,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: context.cardBorder.withValues(alpha: 0.3),
            thickness: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _pickerTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: context.accentColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(color: context.textMuted, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.textMain,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    final accent = context.accentColor;
    final isDark = context.isDark;
    final textMain = context.textMain;
    final textMuted = context.textMuted;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141926) : const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3245) : const Color(0xFFE2E8F0),
          width: 1.4,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            value: _eventType,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: accent),
            dropdownColor: isDark ? const Color(0xFF1A2035) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            items: _eventTypes.map((type) {
              final selected = type == _eventType;
              return DropdownMenuItem<String>(
                value: type,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: selected ? 0.18 : 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _categoryIcon(type),
                        size: 16,
                        color: selected ? accent : textMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.tr(type),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected ? accent : textMain,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) {
                HapticFeedback.lightImpact();
                setState(() => _eventType = v);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _clientSection() {
    final accent = context.accentColor;
    final isDark = context.isDark;
    if (_selectedClient != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accent.withValues(alpha: isDark ? 0.35 : 0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.withValues(alpha: 0.4), context.cardBorder],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _selectedClient!.name.isNotEmpty
                    ? _selectedClient!.name[0].toUpperCase()
                    : 'C',
                style: TextStyle(
                  color: context.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedClient!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.textMain,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedClient!.phone,
                    style: TextStyle(color: context.textMuted, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _openClientPicker,
              child: const Text('Change'),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.person_search_rounded, size: 18),
            label: const Text('Select Existing Client Profile'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _openClientPicker,
          ),
        ),
        const SizedBox(height: 12),
        StudioTextField(
          label: 'Client Name *',
          controller: _clientController,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Please enter the client name'
              : null,
        ),
        const SizedBox(height: 12),
        StudioTextField(
          label: 'Client Phone Number *',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: Validators.phone,
        ),
      ],
    );
  }

  void _openClientPicker() {
    final clients = context.read<EventsProvider>().clients;
    final isDark = context.isDark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (pickerContext) {
        var query = '';
        return StatefulBuilder(
          builder: (ctx, setModal) {
            final q = query.trim().toLowerCase();
            final filtered = q.isEmpty
                ? clients
                : clients
                      .where(
                        (c) =>
                            c.name.toLowerCase().contains(q) ||
                            c.phone.contains(q),
                      )
                      .toList();
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.7,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16161E) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Select Client',
                            style: GoogleFonts.plusJakartaSans(
                              color: context.textMain,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: context.textMuted,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      onChanged: (v) => setModal(() => query = v),
                      decoration: const InputDecoration(
                        hintText: 'Search by name or phone',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              'No clients found',
                              style: TextStyle(color: context.textMuted),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final c = filtered[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    c.name.isNotEmpty
                                        ? c.name[0].toUpperCase()
                                        : 'C',
                                  ),
                                ),
                                title: Text(c.name),
                                subtitle: Text(c.phone),
                                onTap: () {
                                  setState(() {
                                    _selectedClient = c;
                                    _clientController.text = c.name;
                                    _phoneController.text =
                                        Validators.normalizePhone(c.phone);
                                  });
                                  Navigator.of(ctx).pop();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _summaryCard() {
    final accent = context.accentColor;
    final profitColor = _profit >= 0
        ? const Color(0xFF10B981)
        : AppColors.urgencyCritical(context);
    Widget row(String label, double value, {Color? color, bool bold = false}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: context.textMuted, fontSize: 13),
                ),
              ),
              Text(
                _currency.format(value),
                style: TextStyle(
                  color: color ?? context.textMain,
                  fontSize: bold ? 18 : 14,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          row('Amount Due', _due, color: accent),
          row('Profit (Net)', _profit, color: profitColor, bold: true),
        ],
      ),
    );
  }

  String? _amountValidator(String? v, {bool required = false}) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return required ? 'Enter amount' : null;
    final n = double.tryParse(t);
    if (n == null) return 'Invalid amount';
    if (n < 0) return 'Cannot be negative';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textMain = context.textMain;
    final textMuted = context.textMuted;
    final isDark = context.isDark;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('Add Past Event'),
                            style: GoogleFonts.plusJakartaSans(
                              color: textMain,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Enter details of a previous shoot',
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
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      _sectionHeader('Event Information'),
                      const SizedBox(height: 12),
                      StudioTextField(
                        label: 'Event Name',
                        controller: _nameController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter an event name'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        context.tr('Event Category'),
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _categoryDropdown(),
                      if (_eventType == 'Others') ...[
                        const SizedBox(height: 10),
                        StudioTextField(
                          label: 'Specify Event Type *',
                          controller: _customEventTypeController,
                          validator: (v) =>
                              (_eventType == 'Others' &&
                                  (v == null || v.trim().isEmpty))
                              ? 'Please specify the event type'
                              : null,
                        ),
                      ],
                      const SizedBox(height: 18),
                      _sectionHeader('Client Assignment'),
                      const SizedBox(height: 12),
                      _clientSection(),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Text(
                            context.tr('Shoot Schedule'),
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: context.accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color:
                                    context.accentColor.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              _durationInDays == 1
                                  ? '1 Day Shoot'
                                  : '$_durationInDays Days Shoot',
                              style: TextStyle(
                                color: context.accentColor,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _pickerTile(
                              icon: Icons.calendar_today_rounded,
                              title: context.tr('Start Date'),
                              value: DateFormat('d MMM yyyy').format(_startDate),
                              onTap: _pickStartDate,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _pickerTile(
                              icon: Icons.event_available_rounded,
                              title: context.tr('End Date'),
                              value: DateFormat('d MMM yyyy').format(_endDate),
                              onTap: _pickEndDate,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _pickerTile(
                              icon: Icons.access_time_rounded,
                              title: context.tr('Start Time'),
                              value: _startTime.format(context),
                              onTap: () => _pickTime(true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _pickerTile(
                              icon: Icons.access_time_filled_rounded,
                              title: context.tr('End Time'),
                              value: _endTime.format(context),
                              onTap: () => _pickTime(false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      StudioTextField(
                        label: 'Location / Venue',
                        controller: _locationController,
                        prefixIcon: Icons.place_outlined,
                      ),
                      const SizedBox(height: 14),
                      StudioTextField(
                        label: 'Notes (Optional)',
                        controller: _notesController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      _sectionHeader('Financial Information'),
                      const SizedBox(height: 12),
                      StudioTextField(
                        label: 'Total Agreed Amount (₹)',
                        controller: _totalController,
                        keyboardType: TextInputType.number,
                        validator: (v) => _amountValidator(v, required: true),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StudioTextField(
                              label: 'Amount Received (₹)',
                              controller: _receivedController,
                              keyboardType: TextInputType.number,
                              validator: _amountValidator,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StudioTextField(
                              label: 'Expenses (₹)',
                              controller: _expensesController,
                              keyboardType: TextInputType.number,
                              validator: _amountValidator,
                            ),
                          ),
                        ],
                      ),
                      if (_received > 0) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PaymentMethod.values.map((m) {
                            return ChoiceChip(
                              label: Text(m.label),
                              selected: _method == m,
                              onSelected: (_) => setState(() => _method = m),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _summaryCard(),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Event Status',
                              style: TextStyle(color: textMuted, fontSize: 13),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Completed',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_formValidationError != null) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: Color(0xFFEF4444),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _formValidationError!,
                                  style: const TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      StudioButton(
                        label: 'Save Event',
                        onPressed: _isSubmitting ? null : _submit,
                        isLoading: _isSubmitting,
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
