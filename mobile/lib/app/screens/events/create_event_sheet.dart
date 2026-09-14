import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/client.dart';
import '../../models/studio_event.dart';
import '../../providers/events_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/studio_button.dart';
import '../../widgets/studio_text_field.dart';

class CreateEventSheet extends StatefulWidget {
  const CreateEventSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.ink,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const CreateEventSheet(),
    );
  }

  @override
  State<CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends State<CreateEventSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _clientController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _advanceController = TextEditingController();

  String _eventType = 'Wedding';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);

  double _totalAmount = 0;
  double _advanceReceived = 0;

  static final _currency =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  final List<String> _eventTypes = [
    'Wedding',
    'Maternity',
    'Commercial',
    'Newborn',
    'Pre-wedding',
    'Portrait',
    'Fashion',
    'Event',
  ];

  @override
  void initState() {
    super.initState();
    _totalAmountController.addListener(_onAmountChanged);
    _advanceController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _totalAmountController.removeListener(_onAmountChanged);
    _advanceController.removeListener(_onAmountChanged);
    _nameController.dispose();
    _clientController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _totalAmountController.dispose();
    _advanceController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    setState(() {
      _totalAmount = double.tryParse(_totalAmountController.text.trim()) ?? 0;
      _advanceReceived = double.tryParse(_advanceController.text.trim()) ?? 0;
    });
  }

  double get _remainingAmount =>
      (_totalAmount - _advanceReceived).clamp(0.0, double.infinity);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.aqua,
              onPrimary: AppColors.ink,
              surface: AppColors.navy,
              onSurface: AppColors.paper,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.aqua,
              onPrimary: AppColors.ink,
              surface: AppColors.navy,
              onSurface: AppColors.paper,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.aqua,
              onPrimary: AppColors.ink,
              surface: AppColors.navy,
              onSurface: AppColors.paper,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final startsAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final payments = <PaymentRecord>[];
    if (_advanceReceived > 0) {
      payments.add(
        PaymentRecord(
          id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Advance Received',
          amount: _advanceReceived,
          paidAt: DateTime.now(),
          method: PaymentMethod.upi,
        ),
      );
    }

    final provider = context.read<EventsProvider>();
    final enteredClientName = _clientController.text.trim();
    String? clientId;

    final existingClient = provider.clients.firstWhere(
      (c) => c.name.toLowerCase() == enteredClientName.toLowerCase(),
      orElse: () => const Client(id: '', name: '', phone: '', email: ''),
    );

    if (existingClient.id.isNotEmpty) {
      clientId = existingClient.id;
    } else if (enteredClientName.isNotEmpty) {
      clientId = 'cli-${DateTime.now().millisecondsSinceEpoch}';
      provider.addClient(
        Client(
          id: clientId,
          name: enteredClientName,
          phone: '',
          email: '',
          createdAt: DateTime.now(),
        ),
      );
    }

    final newEvent = StudioEvent(
      id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
      clientId: clientId,
      title: _nameController.text.trim(),
      clientName: enteredClientName,
      eventType: _eventType,
      startsAt: startsAt,
      startTime: _startTime.format(context),
      endTime: _endTime.format(context),
      location: _locationController.text.trim().isEmpty
          ? 'Studio floor'
          : _locationController.text.trim(),
      status: EventStatus.upcoming,
      totalAmount: _totalAmount,
      payments: payments,
      notes: _notesController.text.trim(),
      deliverables: const [
        DeliverableTask(id: 't-1', title: 'Consultation & Moodboard', isCompleted: true),
        DeliverableTask(id: 't-2', title: 'Shoot Execution', isCompleted: false),
        DeliverableTask(id: 't-3', title: 'Backup & Selection', isCompleted: false),
        DeliverableTask(id: 't-4', title: 'Editing & Retouching', isCompleted: false),
        DeliverableTask(id: 't-5', title: 'Final Delivery', isCompleted: false),
      ],
    );

    provider.addEvent(newEvent);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event "${newEvent.title}" added to schedule.'),
        backgroundColor: AppColors.navy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Event',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          color: AppColors.paper,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Record shoot details & package financials',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0x22FFFFFF), height: 1),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  // SECTION 1: Event Information
                  _buildSectionHeader('Event Information'),
                  const SizedBox(height: 12),
                  StudioTextField(
                    label: 'Event Name',
                    hint: 'e.g. Wedding — Aanya & Rohan',
                    controller: _nameController,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter an event name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Event Category / Type',
                    style: TextStyle(
                      color: AppColors.blush,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _eventTypes.map((type) {
                      final selected = _eventType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: selected,
                        onSelected: (val) {
                          if (val) setState(() => _eventType = type);
                        },
                        selectedColor: AppColors.aqua.withValues(alpha: 0.28),
                        backgroundColor: AppColors.navy.withValues(alpha: 0.8),
                        side: BorderSide(
                          color: selected
                              ? AppColors.aqua
                              : AppColors.slate.withValues(alpha: 0.4),
                        ),
                        labelStyle: TextStyle(
                          color: selected ? AppColors.aqua : AppColors.paper,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  StudioTextField(
                    label: 'Client Name',
                    hint: 'e.g. Aanya Sharma',
                    controller: _clientController,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter the client name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  // Date & Time selection row
                  Row(
                    children: [
                      Expanded(
                        child: _buildPickerTile(
                          icon: Icons.calendar_month_outlined,
                          title: 'Date',
                          value: DateFormat('d MMM yyyy').format(_selectedDate),
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPickerTile(
                          icon: Icons.access_time_rounded,
                          title: 'Start',
                          value: _startTime.format(context),
                          onTap: _pickStartTime,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPickerTile(
                          icon: Icons.access_time_rounded,
                          title: 'End',
                          value: _endTime.format(context),
                          onTap: _pickEndTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  StudioTextField(
                    label: 'Location / Venue',
                    hint: 'e.g. Lotus Pavilion, Bangalore',
                    controller: _locationController,
                  ),
                  const SizedBox(height: 14),
                  StudioTextField(
                    label: 'Notes / Special Requests',
                    hint: 'e.g. Golden hour preference, 2 traditional outfits',
                    controller: _notesController,
                  ),
                  const SizedBox(height: 24),

                  // SECTION 2: Financial Information
                  _buildSectionHeader('Financial Information'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StudioTextField(
                          label: 'Total Package (₹)',
                          hint: 'e.g. 100000',
                          controller: _totalAmountController,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Enter total package amount';
                            }
                            if (double.tryParse(val.trim()) == null) {
                              return 'Invalid amount';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StudioTextField(
                          label: 'Advance Received (₹)',
                          hint: 'e.g. 30000',
                          controller: _advanceController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Automated Remaining Calculation Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _remainingAmount > 0
                            ? const Color(0xFFE8B86D).withValues(alpha: 0.4)
                            : AppColors.aqua.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Remaining Balance',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_currency.format(_totalAmount)} \u2212 ${_currency.format(_advanceReceived)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.blush,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _currency.format(_remainingAmount),
                            style: TextStyle(
                              color: _remainingAmount > 0
                                  ? const Color(0xFFE8B86D)
                                  : AppColors.aqua,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Save Button
                  StudioButton(
                    label: 'Create Event',
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            color: AppColors.paper,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(color: Color(0x33FFFFFF), thickness: 0.8),
        ),
      ],
    );
  }

  Widget _buildPickerTile({
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
          color: AppColors.navy.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.slate.withValues(alpha: 0.45),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.aqua, size: 14),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(color: AppColors.blush, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.paper,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
