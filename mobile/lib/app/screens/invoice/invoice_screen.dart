import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/studio_demo_data.dart';
import '../../models/invoice.dart';
import '../../theme/app_colors.dart';
import '../../widgets/studio_app_bar.dart';
import '../../widgets/studio_card.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoices = StudioDemoData.invoices;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final textMain = context.textMain;
    final textMuted = context.textMuted;
    final accent = context.accentColor;

    return SafeArea(
      child: Column(
        children: [
          const StudioAppBar(
            title: 'Invoices',
            subtitle: 'Payments and drafts',
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: invoices.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return StudioCard(
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invoice.number,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textMain,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${invoice.clientName} · ${DateFormat('d MMM').format(invoice.issuedOn)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              currency.format(invoice.amount),
                              maxLines: 1,
                              style: TextStyle(
                                color: textMain,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _StatusChip(status: invoice.status),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final InvoiceStatus status;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final label = switch (status) {
      InvoiceStatus.paid => 'Paid',
      InvoiceStatus.due => 'Due',
      InvoiceStatus.draft => 'Draft',
    };
    final color = switch (status) {
      InvoiceStatus.paid => context.accentColor,
      InvoiceStatus.due =>
        isDark ? const Color(0xFFE8B86D) : const Color(0xFFD97706),
      InvoiceStatus.draft => context.textMuted,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
