import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/studio_event.dart';
import '../../providers/events_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/studio_app_bar.dart';
import '../../widgets/studio_button.dart';
import '../../widgets/studio_card.dart';
import '../../widgets/studio_text_field.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({
    super.key,
    required this.eventId,
  });

  final String eventId;

  static final _currency =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventsProvider>();
    final event = provider.getById(eventId);

    if (event == null) {
      return Scaffold(
        backgroundColor: AppColors.ink,
        appBar: const StudioAppBar(
          title: 'Event Not Found',
          subtitle: 'Lumen studio',
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This event could not be found.',
                  style: TextStyle(color: AppColors.paper)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            StudioAppBar(
              title: event.title,
              subtitle: '${event.eventType} Details',
              leading: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.paper, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  tooltip: 'Edit Event',
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.aqua, size: 20),
                  onPressed: () => _showEditEventDialog(context, event),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  // A. Event Header
                  _buildEventHeader(context, event),
                  const SizedBox(height: 16),

                  // B. Financial Summary
                  _buildFinancialSummary(context, event),
                  const SizedBox(height: 16),

                  // C. Payment History
                  _buildPaymentHistory(context, event),
                  const SizedBox(height: 16),

                  // D. Expense Summary
                  _buildExpenseSummary(context, event),
                  const SizedBox(height: 16),

                  // E. Work / Deliverables Progress
                  _buildWorkProgress(context, event),
                  const SizedBox(height: 16),

                  // F. Event Notes
                  _buildNotesSection(context, event),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= A. Header =================
  Widget _buildEventHeader(BuildContext context, StudioEvent event) {
    final dateStr = DateFormat('d MMMM yyyy').format(event.startsAt);
    final dayStr = DateFormat('EEEE').format(event.startsAt);

    return StudioCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.paper,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.eventType} · Client: ${event.clientName}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(event.status),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.ink.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.slate.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined,
                        color: AppColors.aqua, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$dateStr ($dayStr) · ${event.startTime} - ${event.endTime}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.paper,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.aqua, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.location,
                        style: const TextStyle(
                          color: AppColors.paper,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(EventStatus status) {
    Color color;
    IconData icon;
    switch (status) {
      case EventStatus.completed:
        color = AppColors.aqua;
        icon = Icons.check_circle_outline_rounded;
        break;
      case EventStatus.inProgress:
        color = const Color(0xFF64B5F6);
        icon = Icons.timelapse_rounded;
        break;
      case EventStatus.paymentDue:
        color = const Color(0xFFE8B86D);
        icon = Icons.error_outline_rounded;
        break;
      case EventStatus.upcoming:
        color = const Color(0xFF81C784);
        icon = Icons.schedule_rounded;
        break;
      case EventStatus.cancelled:
        color = const Color(0xFFFF7A8A);
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ================= B. Financial Summary =================
  Widget _buildFinancialSummary(BuildContext context, StudioEvent event) {
    final remaining = event.remainingAmount;
    final hasRemaining = remaining > 0;

    return StudioCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Event Financials',
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.paper,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (hasRemaining)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8B86D).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE8B86D).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      '${_currency.format(remaining)} Due',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFE8B86D),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.aqua.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Fully Paid',
                    style: TextStyle(
                      color: AppColors.aqua,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Financial Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.ink.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.slate.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: [
                _buildFinanceRow(
                  label: 'Total Package',
                  value: _currency.format(event.totalAmount),
                  valueColor: AppColors.paper,
                ),
                const Divider(color: Color(0x22FFFFFF), height: 16),
                _buildFinanceRow(
                  label: 'Amount Received',
                  value: _currency.format(event.amountReceived),
                  valueColor: AppColors.aqua,
                ),
                const Divider(color: Color(0x22FFFFFF), height: 16),
                _buildFinanceRow(
                  label: 'Remaining Balance',
                  value: _currency.format(event.remainingAmount),
                  valueColor: hasRemaining
                      ? const Color(0xFFE8B86D)
                      : AppColors.muted,
                  subtitle: hasRemaining ? 'Pending client settlement' : 'Settled',
                ),
                const Divider(color: Color(0x22FFFFFF), height: 16),
                _buildFinanceRow(
                  label: 'Total Expenses',
                  value: _currency.format(event.totalExpenses),
                  valueColor: const Color(0xFFFF7A8A),
                  subtitle: '${event.expenses.length} recorded items',
                ),
                const Divider(color: Color(0x445BC0BE), height: 20),
                // Prominent Net Profit
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Net Profit',
                          style: TextStyle(
                            color: AppColors.paper,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Received − Expenses',
                          style: TextStyle(
                            color: AppColors.muted.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _currency.format(event.netProfit),
                      style: GoogleFonts.playfairDisplay(
                        color: event.netProfit >= 0
                            ? AppColors.aqua
                            : const Color(0xFFFF7A8A),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceRow({
    required String label,
    required String value,
    required Color valueColor,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.muted.withValues(alpha: 0.6),
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
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ================= C. Payment History =================
  Widget _buildPaymentHistory(BuildContext context, StudioEvent event) {
    return StudioCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payments',
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.paper,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _showAddPaymentSheet(context, event.id),
                icon: const Icon(Icons.add, size: 16, color: AppColors.aqua),
                label: const Text(
                  'Add Payment',
                  style: TextStyle(color: AppColors.aqua, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (event.payments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'No payments logged yet.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            )
          else
            ...event.payments.map((p) {
              final dateStr = DateFormat('d MMM yyyy').format(p.paidAt);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.slate.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.aqua.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(p.method.icon,
                              color: AppColors.aqua, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.title,
                                style: const TextStyle(
                                  color: AppColors.paper,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.slate
                                          .withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      p.method.label,
                                      style: const TextStyle(
                                        color: AppColors.paper,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _currency.format(p.amount),
                          style: const TextStyle(
                            color: AppColors.aqua,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    if (p.reference != null || p.hasProof) ...[
                      const SizedBox(height: 6),
                      const Divider(color: Color(0x18FFFFFF), height: 1),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (p.reference != null)
                            Text(
                              'Ref: ${p.reference}',
                              style: TextStyle(
                                color: AppColors.muted.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          if (p.hasProof)
                            InkWell(
                              onTap: () => _showProofDialog(context, p),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.aqua.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.aqua.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.attachment_rounded,
                                        size: 11, color: AppColors.aqua),
                                    SizedBox(width: 3),
                                    Text(
                                      'View Proof',
                                      style: TextStyle(
                                        color: AppColors.aqua,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Received',
                style: TextStyle(
                  color: AppColors.paper,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                _currency.format(event.amountReceived),
                style: const TextStyle(
                  color: AppColors.aqua,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= D. Expense Summary =================
  Widget _buildExpenseSummary(BuildContext context, StudioEvent event) {
    return StudioCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Event Expenses',
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.paper,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _showAddExpenseSheet(context, event.id),
                icon: const Icon(Icons.add, size: 16, color: AppColors.aqua),
                label: const Text(
                  '+ Add Expense',
                  style: TextStyle(color: AppColors.aqua, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (event.expenses.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'No expenses recorded yet.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            )
          else
            ...event.expenses.map((ex) {
              return Dismissible(
                key: Key(ex.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A8A).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) {
                  context.read<EventsProvider>().deleteExpense(event.id, ex.id);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.slate.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7A8A).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_outlined,
                            color: Color(0xFFFF7A8A), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ex.title,
                              style: const TextStyle(
                                color: AppColors.paper,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${ex.category} · ${DateFormat('d MMM').format(ex.incurredAt)}',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _currency.format(ex.amount),
                        style: const TextStyle(
                          color: Color(0xFFFF7A8A),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Expenses',
                style: TextStyle(
                  color: AppColors.paper,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                _currency.format(event.totalExpenses),
                style: const TextStyle(
                  color: Color(0xFFFF7A8A),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= E. Work Progress =================
  Widget _buildWorkProgress(BuildContext context, StudioEvent event) {
    final completed = event.completedTasksCount;
    final total = event.totalTasksCount;
    final percent = (event.progressRatio * 100).round();
    DeliverableTask? nextTask;
    for (final task in event.deliverables) {
      if (!task.isCompleted) {
        nextTask = task;
        break;
      }
    }
    final stages = _workflowStages(event.deliverables);

    return StudioCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Work Progress',
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.paper,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  '$completed / $total',
                  key: ValueKey('progress-count-$completed-$total'),
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.aqua,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              '$percent% Complete',
              key: ValueKey('progress-percent-$percent'),
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: event.progressRatio),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: AppColors.slate.withValues(alpha: 0.35),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.aqua),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          if (event.deliverables.isEmpty)
            const Text(
              'No deliverables listed for this shoot.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            )
          else ...[
            if (nextTask == null)
              _buildAllWorkCompleteCard(completed, total)
            else
              _buildNextTaskCard(context, event.id, nextTask),
            const SizedBox(height: 18),
            ...stages.map(
              (stage) => _buildStageSection(context, event.id, stage),
            ),
          ],
        ],
      ),
    );
  }

  List<_WorkflowStage> _workflowStages(List<DeliverableTask> tasks) {
    final grouped = <String, List<DeliverableTask>>{
      'Shoot': [],
      'Post Production': [],
      'Delivery': [],
    };

    for (final task in tasks) {
      grouped[_stageForTask(task.title)]!.add(task);
    }

    return grouped.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => _WorkflowStage(entry.key, entry.value))
        .toList();
  }

  String _stageForTask(String title) {
    final value = title.toLowerCase();
    if (value.contains('selection') ||
        value.contains('edit') ||
        value.contains('retouch') ||
        value.contains('color') ||
        value.contains('grade') ||
        value.contains('cinematic') ||
        value.contains('highlight')) {
      return 'Post Production';
    }
    if (value.contains('album') ||
        value.contains('print') ||
        value.contains('delivery') ||
        value.contains('deliver') ||
        value.contains('gallery') ||
        value.contains('cloud') ||
        value.contains('keepsake')) {
      return 'Delivery';
    }
    return 'Shoot';
  }

  String _stageLabel(String stage) => stage.toUpperCase();

  String _taskSubtitle(DeliverableTask task) => _stageForTask(task.title);

  IconData _taskIcon(String title) {
    final value = title.toLowerCase();
    if (value.contains('video') || value.contains('cinematic')) {
      return value.contains('edit') ? Icons.movie_outlined : Icons.videocam;
    }
    if (value.contains('backup') || value.contains('raw')) {
      return Icons.storage_rounded;
    }
    if (value.contains('selection') || value.contains('gallery')) {
      return Icons.photo_library_outlined;
    }
    if (value.contains('edit') ||
        value.contains('retouch') ||
        value.contains('color')) {
      return Icons.auto_awesome;
    }
    if (value.contains('album')) {
      return Icons.menu_book_outlined;
    }
    if (value.contains('print')) {
      return Icons.print_outlined;
    }
    if (value.contains('delivery') ||
        value.contains('deliver') ||
        value.contains('keepsake') ||
        value.contains('packaging')) {
      return Icons.inventory_2_outlined;
    }
    if (value.contains('brief') || value.contains('consult')) {
      return Icons.assignment_outlined;
    }
    return Icons.camera_alt_outlined;
  }

  void _toggleTask(BuildContext context, String eventId, String taskId) {
    context.read<EventsProvider>().toggleDeliverable(eventId, taskId);
  }

  Widget _buildNextTaskCard(
    BuildContext context,
    String eventId,
    DeliverableTask task,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NEXT UP',
          style: TextStyle(
            color: AppColors.aqua.withValues(alpha: 0.85),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _toggleTask(context, eventId, task.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.aqua.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.aqua.withValues(alpha: 0.36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.aqua.withValues(alpha: 0.08),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.aqua.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _taskIcon(task.title),
                      color: AppColors.aqua,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.paper,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Continue ${_taskSubtitle(task).toLowerCase()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'START ->',
                    style: TextStyle(
                      color: AppColors.aqua,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllWorkCompleteCard(int completed, int total) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.aqua.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.aqua.withValues(alpha: 0.42)),
        boxShadow: [
          BoxShadow(
            color: AppColors.aqua.withValues(alpha: 0.10),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.verified_rounded,
            color: AppColors.aqua,
            size: 28,
          ),
          const SizedBox(height: 8),
          const Text(
            'ALL WORK COMPLETED',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.paper,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$completed / $total tasks finished',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageSection(
    BuildContext context,
    String eventId,
    _WorkflowStage stage,
  ) {
    final completed = stage.tasks.where((task) => task.isCompleted).length;
    final total = stage.tasks.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _stageLabel(stage.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.aqua.withValues(alpha: 0.82),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$completed / $total',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...stage.tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildTaskCard(context, eventId, task),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    String eventId,
    DeliverableTask task,
  ) {
    final isCompleted = task.isCompleted;
    final statusColor = isCompleted ? AppColors.aqua : AppColors.muted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _toggleTask(context, eventId, task.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.aqua.withValues(alpha: 0.10)
                : AppColors.ink.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? AppColors.aqua.withValues(alpha: 0.38)
                  : AppColors.slate.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Container(
                  key: ValueKey('${task.id}-$isCompleted'),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.aqua : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? AppColors.aqua : AppColors.muted,
                      width: 1.4,
                    ),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_rounded : Icons.circle_outlined,
                    color: isCompleted ? AppColors.ink : Colors.transparent,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                _taskIcon(task.title),
                color: statusColor,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCompleted
                            ? AppColors.paper.withValues(alpha: 0.78)
                            : AppColors.paper,
                        fontSize: 14,
                        fontWeight:
                            isCompleted ? FontWeight.w600 : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _taskSubtitle(task),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isCompleted ? 'COMPLETED' : 'PENDING',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= F. Notes =================
  Widget _buildNotesSection(BuildContext context, StudioEvent event) {
    return StudioCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.paper,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            event.notes.isNotEmpty
                ? event.notes
                : 'No notes recorded for this event.',
            style: const TextStyle(
              color: AppColors.paper,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ================= Dialogs / Sheets =================
  void _showAddPaymentSheet(BuildContext context, String eventId) {
    final titleController = TextEditingController(text: 'Payment');
    final amountController = TextEditingController();
    final refController = TextEditingController();
    final proofController = TextEditingController();

    PaymentMethod selectedMethod = PaymentMethod.upi;
    bool attachProof = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Record Payment',
                          style: GoogleFonts.playfairDisplay(
                            color: AppColors.paper,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.muted),
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StudioTextField(
                      label: 'Payment Description',
                      hint: 'e.g. Advance, Second Payment, Balance',
                      controller: titleController,
                    ),
                    const SizedBox(height: 14),
                    StudioTextField(
                      label: 'Amount (₹)',
                      hint: 'e.g. 25000',
                      controller: amountController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),

                    // Payment Method selector
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        color: AppColors.paper,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: PaymentMethod.values.map((method) {
                        final isSelected = selectedMethod == method;
                        return ChoiceChip(
                          avatar: Icon(
                            method.icon,
                            size: 14,
                            color: isSelected ? AppColors.ink : AppColors.muted,
                          ),
                          label: Text(method.label),
                          selected: isSelected,
                          selectedColor: AppColors.aqua,
                          backgroundColor: AppColors.ink.withValues(alpha: 0.6),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.ink : AppColors.paper,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => selectedMethod = method);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    StudioTextField(
                      label: 'Reference / Txn ID (Optional)',
                      hint: 'e.g. UPI/2026/10294 or Bank Ref',
                      controller: refController,
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Attach Payment Proof',
                          style: TextStyle(
                            color: AppColors.paper,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Switch(
                          value: attachProof,
                          activeThumbColor: AppColors.aqua,
                          onChanged: (val) {
                            setModalState(() {
                              attachProof = val;
                              if (val && proofController.text.isEmpty) {
                                proofController.text =
                                    'receipt_${selectedMethod.name}_${DateTime.now().millisecondsSinceEpoch % 10000}.jpg';
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if (attachProof) ...[
                      const SizedBox(height: 6),
                      StudioTextField(
                        label: 'Proof Document / Image File',
                        hint: 'e.g. payment_receipt.jpg',
                        controller: proofController,
                      ),
                    ],

                    const SizedBox(height: 20),
                    StudioButton(
                      label: 'Log Payment',
                      onPressed: () {
                        final amount = double.tryParse(amountController.text.trim());
                        if (amount != null && amount > 0) {
                          final payment = PaymentRecord(
                            id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
                            title: titleController.text.trim().isEmpty
                                ? 'Payment'
                                : titleController.text.trim(),
                            amount: amount,
                            paidAt: DateTime.now(),
                            method: selectedMethod,
                            reference: refController.text.trim().isNotEmpty
                                ? refController.text.trim()
                                : null,
                            proof: attachProof && proofController.text.trim().isNotEmpty
                                ? proofController.text.trim()
                                : null,
                          );
                          context
                              .read<EventsProvider>()
                              .addPayment(eventId, payment);
                          Navigator.of(sheetContext).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showProofDialog(BuildContext context, PaymentRecord payment) {
    final dateStr = DateFormat('d MMMM yyyy, h:mm a').format(payment.paidAt);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Proof & Receipt',
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.paper,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.muted),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.aqua.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.aqua.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_outlined,
                        color: AppColors.aqua,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currency.format(payment.amount),
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.paper,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Payment Verified · ${payment.method.label}',
                      style: const TextStyle(
                        color: AppColors.aqua,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0x22FFFFFF), height: 1),
                    const SizedBox(height: 14),
                    _buildProofDetailRow('Description', payment.title),
                    const SizedBox(height: 8),
                    _buildProofDetailRow('Date & Time', dateStr),
                    const SizedBox(height: 8),
                    _buildProofDetailRow(
                        'Transaction Ref', payment.reference ?? 'REF-AUTO-9281'),
                    const SizedBox(height: 8),
                    _buildProofDetailRow(
                        'Attachment File', payment.proof ?? 'receipt_doc.pdf'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              StudioButton(
                label: 'Done',
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProofDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.paper,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddExpenseSheet(BuildContext context, String eventId) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'Crew';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Event Expense',
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.paper,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StudioTextField(
                    label: 'Expense Description',
                    hint: 'e.g. Freelancer Photographer, Travel, Printing',
                    controller: titleController,
                  ),
                  const SizedBox(height: 14),
                  StudioTextField(
                    label: 'Amount (₹)',
                    hint: 'e.g. 15000',
                    controller: amountController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Category',
                    style: TextStyle(color: AppColors.blush, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Crew', 'Travel', 'Equipment', 'Printing', 'Studio']
                        .map((cat) {
                      final selected = category == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: selected,
                        onSelected: (val) {
                          if (val) setModalState(() => category = cat);
                        },
                        selectedColor: AppColors.aqua.withValues(alpha: 0.25),
                        backgroundColor: AppColors.ink.withValues(alpha: 0.6),
                        labelStyle: TextStyle(
                          color: selected ? AppColors.aqua : AppColors.paper,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  StudioButton(
                    label: 'Save Expense',
                    onPressed: () {
                      final amount =
                          double.tryParse(amountController.text.trim());
                      if (amount != null &&
                          amount > 0 &&
                          titleController.text.trim().isNotEmpty) {
                        final expense = ExpenseRecord(
                          id: 'exp-${DateTime.now().millisecondsSinceEpoch}',
                          title: titleController.text.trim(),
                          amount: amount,
                          category: category,
                          incurredAt: DateTime.now(),
                        );
                        context
                            .read<EventsProvider>()
                            .addExpense(eventId, expense);
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditEventDialog(BuildContext context, StudioEvent event) {
    EventStatus selectedStatus = event.status;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.navy,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Update Event Status',
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.paper,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: EventStatus.values.map((status) {
                  final isSelected = selectedStatus == status;
                  return InkWell(
                    onTap: () {
                      setDialogState(() => selectedStatus = status);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.aqua.withValues(alpha: 0.15)
                            : AppColors.ink.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.aqua
                              : AppColors.slate.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? AppColors.aqua
                                : AppColors.muted,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            status.label,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.paper
                                  : AppColors.blush,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.muted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.aqua,
                    foregroundColor: AppColors.ink,
                  ),
                  onPressed: () {
                    context.read<EventsProvider>().updateEvent(
                          event.copyWith(status: selectedStatus),
                        );
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _WorkflowStage {
  const _WorkflowStage(this.name, this.tasks);

  final String name;
  final List<DeliverableTask> tasks;
}
