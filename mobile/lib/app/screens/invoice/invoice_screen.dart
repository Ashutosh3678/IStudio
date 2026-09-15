import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/studio_app_bar.dart';
import 'create_invoice_form.dart';
import 'invoice_history_tab.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  bool _isCreate = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          StudioAppBar(
            title: 'Invoices',
            subtitle: _isCreate
                ? 'Create and send a bill'
                : 'Payments, pending and overdue',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: _InvoiceModeToggle(
              isCreate: _isCreate,
              onChanged: (value) => setState(() => _isCreate = value),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _isCreate ? 0 : 1,
              children: [
                CreateInvoiceForm(
                  onSaved: (_) => setState(() => _isCreate = false),
                ),
                const InvoiceHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceModeToggle extends StatelessWidget {
  const _InvoiceModeToggle({
    required this.isCreate,
    required this.onChanged,
  });

  final bool isCreate;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Semantics(
      label: isCreate ? 'Create selected' : 'History selected',
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: context.innerBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.cardBorder),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = (constraints.maxWidth - 4) / 2;
            return Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  alignment: isCreate
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    width: tabWidth,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [AppColors.aqua, AppColors.slate]
                            : const [AppColors.lightPrimary, Color(0xFF0F766E)],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    _Tab(
                      label: 'Create',
                      selected: isCreate,
                      onTap: () => onChanged(true),
                    ),
                    _Tab(
                      label: 'History',
                      selected: !isCreate,
                      onTap: () => onChanged(false),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: selected
                    ? (context.isDark ? AppColors.paper : Colors.white)
                    : context.textMuted,
                fontWeight: FontWeight.w600,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
