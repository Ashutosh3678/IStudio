import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/invoice.dart';
import '../../theme/app_colors.dart';
import '../../widgets/studio_button.dart';
import '../../widgets/studio_text_field.dart';

enum InvoiceSheetAction { paid, partial, extendDue, share, delete }

class AddDeliverableSheet extends StatefulWidget {
  const AddDeliverableSheet({super.key, this.existing});

  final InvoiceDeliverable? existing;

  static Future<List<InvoiceDeliverable>?> show(
    BuildContext context, {
    InvoiceDeliverable? existing,
  }) {
    return showModalBottomSheet<List<InvoiceDeliverable>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AddDeliverableSheet(existing: existing),
    );
  }

  @override
  State<AddDeliverableSheet> createState() => _AddDeliverableSheetState();
}

class _AddDeliverableSheetState extends State<AddDeliverableSheet> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _nameControllers = [];
  final List<FocusNode> _focusNodes = [];
  late final TextEditingController _costController;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameControllers.add(
        TextEditingController(text: widget.existing!.name),
      );
      _focusNodes.add(FocusNode());
      _costController = TextEditingController(
        text: widget.existing!.cost.toStringAsFixed(
          widget.existing!.cost.truncateToDouble() == widget.existing!.cost
              ? 0
              : 2,
        ),
      );
    } else {
      _nameControllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
      _costController = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _costController.dispose();
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _nameControllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes.last.requestFocus();
      }
    });
  }

  void _removeRow(int index) {
    setState(() {
      _nameControllers[index].dispose();
      _focusNodes[index].dispose();
      _nameControllers.removeAt(index);
      _focusNodes.removeAt(index);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final nonEmptyNames = _nameControllers
        .map((c) => c.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (nonEmptyNames.isEmpty) return;

    final totalCost = double.tryParse(_costController.text.trim()) ?? 0.0;

    final results = nonEmptyNames.asMap().entries.map((entry) {
      return InvoiceDeliverable(
        id: entry.key == 0 && widget.existing != null
            ? widget.existing!.id
            : 'del-${DateTime.now().millisecondsSinceEpoch}-${entry.key}',
        name: entry.value,
        cost: entry.key == 0 ? totalCost : 0.0,
      );
    }).toList();

    Navigator.of(context).pop(results);
  }

  @override
  Widget build(BuildContext context) {
    final textMuted = context.textMuted;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 12),
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Add Items',
                style: GoogleFonts.plusJakartaSans(
                  color: context.textMain,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Enter each service or item on its own line.',
                style: TextStyle(color: textMuted, fontSize: 13),
              ),
              const SizedBox(height: 18),
              ...List.generate(_nameControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameControllers[index],
                          focusNode: _focusNodes[index],
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => _addRow(),
                          decoration: InputDecoration(
                            labelText: 'Item ${index + 1}',
                            hintText: 'e.g. Photography, Videography...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          validator: (value) {
                            if (index == 0 &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Enter at least one item name';
                            }
                            return null;
                          },
                        ),
                      ),
                      if (_nameControllers.length > 1) ...[
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Remove item',
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: textMuted,
                          ),
                          onPressed: () => _removeRow(index),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add another item'),
              ),
              const SizedBox(height: 14),
              StudioTextField(
                label: 'Total Amount (₹)',
                controller: _costController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {
                  final parsed = double.tryParse(value?.trim() ?? '');
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      parsed == null) {
                    return 'Enter a valid amount';
                  }
                  if (parsed != null && parsed < 0) {
                    return 'Amount cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              StudioButton(
                label: 'Add Items',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvoiceActionsSheet extends StatelessWidget {
  const InvoiceActionsSheet({super.key, required this.invoice});

  final Invoice invoice;

  static Future<InvoiceSheetAction?> show(
    BuildContext context,
    Invoice invoice,
  ) {
    return showModalBottomSheet<InvoiceSheetAction>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => InvoiceActionsSheet(invoice: invoice),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textMain = context.textMain;
    final textMuted = context.textMuted;
    final paid = invoice.isPaid;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.number,
                    style: GoogleFonts.plusJakartaSans(
                      color: textMain,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${invoice.contactName} · ${invoice.statusLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.check_circle_outline_rounded,
              label: 'Mark paid ✓',
              enabled: !paid,
              onTap: () => Navigator.pop(context, InvoiceSheetAction.paid),
            ),
            _ActionTile(
              icon: Icons.payments_outlined,
              label: 'Record advance / part pay',
              enabled: !paid,
              onTap: () => Navigator.pop(context, InvoiceSheetAction.partial),
            ),
            _ActionTile(
              icon: Icons.event_repeat_rounded,
              label: 'Change due date',
              onTap: () => Navigator.pop(context, InvoiceSheetAction.extendDue),
            ),
            _ActionTile(
              icon: Icons.ios_share_rounded,
              label: 'Share receipt',
              onTap: () => Navigator.pop(context, InvoiceSheetAction.share),
            ),
            _ActionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete receipt',
              destructive: true,
              onTap: () => Navigator.pop(context, InvoiceSheetAction.delete),
            ),
          ],
        ),
      ),
    );
  }
}

class PartialPaymentSheet extends StatefulWidget {
  const PartialPaymentSheet({super.key, required this.invoice});

  final Invoice invoice;

  static Future<double?> show(
    BuildContext context, {
    required Invoice invoice,
  }) {
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PartialPaymentSheet(invoice: invoice),
    );
  }

  @override
  State<PartialPaymentSheet> createState() => _PartialPaymentSheetState();
}

class _PartialPaymentSheetState extends State<PartialPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  static final _money = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(double.parse(_amountController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.invoice.pendingAmount;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 12),
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Part payment',
                style: GoogleFonts.plusJakartaSans(
                  color: context.textMain,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Balance to pay ${_money.format(remaining)}',
                style: TextStyle(color: context.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              StudioTextField(
                label: 'Amount received (₹)',
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {
                  final parsed = double.tryParse(value?.trim() ?? '');
                  if (parsed == null) return 'Enter a valid amount';
                  if (parsed <= 0) return 'Amount must be greater than 0';
                  if (parsed > remaining + 0.009) {
                    return 'Cannot exceed remaining ${_money.format(remaining)}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              StudioButton(label: 'Save payment', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? context.textMuted.withValues(alpha: 0.45)
        : destructive
            ? (context.isDark
                ? const Color(0xFFFF7A8A)
                : const Color(0xFFDC2626))
            : context.textMain;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: ListTile(
        enabled: enabled,
        onTap: enabled ? onTap : null,
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
