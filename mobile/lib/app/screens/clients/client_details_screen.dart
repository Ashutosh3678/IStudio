import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/client.dart';
import '../../models/studio_event.dart';
import '../../providers/events_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/studio_app_bar.dart';
import '../../widgets/studio_button.dart';
import '../../widgets/studio_card.dart';
import '../../widgets/studio_text_field.dart';
import '../events/event_details_screen.dart';

class ClientDetailsScreen extends StatelessWidget {
  const ClientDetailsScreen({
    super.key,
    required this.clientId,
  });

  final String clientId;

  static final _currency =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventsProvider>();
    final client = provider.getClientById(clientId);

    if (client == null) {
      return Scaffold(
        backgroundColor: AppColors.ink,
        appBar: const StudioAppBar(
          title: 'Client Not Found',
          subtitle: 'LUMEN Studio',
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This client could not be found.',
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

    final clientEvents = provider.getEventsForClient(client.id, clientName: client.name);
    final payments = provider.getPaymentsForClient(client.id, clientName: client.name);
    final totalValue = provider.getClientTotalValue(client.id, clientName: client.name);
    final totalReceived = provider.getClientTotalReceived(client.id, clientName: client.name);
    final totalRemaining = provider.getClientTotalRemaining(client.id, clientName: client.name);

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            StudioAppBar(
              title: client.name,
              subtitle: '${clientEvents.length} ${clientEvents.length == 1 ? 'Event' : 'Events'} Linked',
              leading: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.paper, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  tooltip: 'Edit Client',
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.aqua, size: 20),
                  onPressed: () => _showEditClientSheet(context, client),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  // A. Client Contact Details Card
                  _buildContactCard(context, client),
                  const SizedBox(height: 16),

                  // B. Financial Summary (Total Value, Received, Remaining - NO PROFIT)
                  _buildFinancialSummary(
                    context,
                    totalValue: totalValue,
                    totalReceived: totalReceived,
                    totalRemaining: totalRemaining,
                  ),
                  const SizedBox(height: 16),

                  // C. Events Belonging to Client (CORE RELATIONSHIP)
                  _buildEventsSection(context, client, clientEvents),
                  const SizedBox(height: 16),

                  // D. Payment History
                  _buildPaymentHistorySection(
                    context,
                    client: client,
                    events: clientEvents,
                    payments: payments,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= A. Contact Details Card =================
  Widget _buildContactCard(BuildContext context, Client client) {
    return StudioCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.aqua.withValues(alpha: 0.3),
                      AppColors.slate.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.aqua.withValues(alpha: 0.5)),
                ),
                alignment: Alignment.center,
                child: Text(
                  client.name.isNotEmpty ? client.name.characters.first.toUpperCase() : 'C',
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.paper,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.paper,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Client Contact Profile',
                      style: TextStyle(
                        color: AppColors.muted.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0x22FFFFFF), height: 1),
          const SizedBox(height: 14),

          // Phone Row
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: client.phone.isNotEmpty ? client.phone : 'Not provided',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Contact ${client.phone}'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: AppColors.navy,
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Email Row
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: client.email.isNotEmpty ? client.email : 'Not provided',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Emailing ${client.email}'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: AppColors.navy,
                ),
              );
            },
          ),

          // Address Row
          if (client.address.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: client.address,
            ),
          ],

          // Notes Row
          if (client.notes.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.slate.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.sticky_note_2_outlined,
                      size: 16, color: AppColors.aqua),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      client.notes,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.aqua.withValues(alpha: 0.85)),
            const SizedBox(width: 10),
            Text(
              '$label: ',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.paper,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.open_in_new_rounded,
                size: 14,
                color: AppColors.aqua.withValues(alpha: 0.6),
              ),
          ],
        ),
      ),
    );
  }

  // ================= B. Financial Summary (NO PROFIT) =================
  Widget _buildFinancialSummary(
    BuildContext context, {
    required double totalValue,
    required double totalReceived,
    required double totalRemaining,
  }) {
    final hasRemaining = totalRemaining > 0;

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
                  'Financial Summary',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.paper,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
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
                      '${_currency.format(totalRemaining)} Due',
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
                    'All Settled',
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
          // 3-Metric Grid
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
                  label: 'Total Event Value',
                  value: _currency.format(totalValue),
                  valueColor: AppColors.paper,
                ),
                const Divider(color: Color(0x22FFFFFF), height: 16),
                _buildFinanceRow(
                  label: 'Total Received',
                  value: _currency.format(totalReceived),
                  valueColor: AppColors.aqua,
                ),
                const Divider(color: Color(0x22FFFFFF), height: 16),
                _buildFinanceRow(
                  label: 'Total Remaining',
                  value: _currency.format(totalRemaining),
                  valueColor: hasRemaining
                      ? const Color(0xFFE8B86D)
                      : AppColors.muted,
                  subtitle: hasRemaining ? 'Pending client settlement' : 'Fully paid',
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

  // ================= C. Events Belonging to Client =================
  Widget _buildEventsSection(
    BuildContext context,
    Client client,
    List<StudioEvent> events,
  ) {
    return StudioCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Client Events',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          color: AppColors.paper,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.aqua.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${events.length}',
                        style: const TextStyle(
                          color: AppColors.aqua,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Tap to view',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (events.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'No events associated with this client yet.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            )
          else
            ...events.map((event) => _buildEventCard(context, event)),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, StudioEvent event) {
    final dateStr = DateFormat('d MMM yyyy').format(event.startsAt);
    final hasRemaining = event.remainingAmount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.slate.withValues(alpha: 0.35),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Tapping an event opens the existing EventDetailsScreen!
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EventDetailsScreen(eventId: event.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Title + Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              color: AppColors.paper,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.aqua.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  event.eventType,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.aqua,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.calendar_today_outlined,
                                  size: 12,
                                  color: AppColors.muted.withValues(alpha: 0.8)),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  dateStr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(event.status),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0x22FFFFFF), height: 1),
                const SizedBox(height: 12),

                // Financial Breakdown Row
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniFinanceItem(
                        label: 'Package',
                        value: _currency.format(event.totalAmount),
                        valueColor: AppColors.paper,
                      ),
                    ),
                    Expanded(
                      child: _buildMiniFinanceItem(
                        label: 'Received',
                        value: _currency.format(event.amountReceived),
                        valueColor: AppColors.aqua,
                      ),
                    ),
                    Expanded(
                      child: _buildMiniFinanceItem(
                        label: 'Remaining',
                        value: _currency.format(event.remainingAmount),
                        valueColor: hasRemaining
                            ? const Color(0xFFE8B86D)
                            : AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Tap prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View event details',
                      style: TextStyle(
                        color: AppColors.aqua.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: AppColors.aqua,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniFinanceItem({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ================= D. Payment History Section =================
  Widget _buildPaymentHistorySection(
    BuildContext context, {
    required Client client,
    required List<StudioEvent> events,
    required List<PaymentRecord> payments,
  }) {
    return StudioCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment History',
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
                onPressed: () {
                  if (events.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please create an event for this client first.'),
                        backgroundColor: AppColors.navy,
                      ),
                    );
                    return;
                  }
                  _showAddPaymentSheet(context, client: client, events: events);
                },
                icon: const Icon(Icons.add, size: 16, color: AppColors.aqua),
                label: const Text(
                  'Add Payment',
                  style: TextStyle(color: AppColors.aqua, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (payments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'No payments logged for this client yet.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            )
          else
            ...payments.map((p) => _buildPaymentItem(context, p, events)),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(
    BuildContext context,
    PaymentRecord payment,
    List<StudioEvent> events,
  ) {
    final dateStr = DateFormat('d MMM yyyy').format(payment.paidAt);

    // Find corresponding event title if possible
    String? matchingEventTitle;
    for (final e in events) {
      if (e.payments.any((pay) => pay.id == payment.id)) {
        matchingEventTitle = e.title;
        break;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.aqua.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(payment.method.icon,
                    color: AppColors.aqua, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.title,
                      style: const TextStyle(
                        color: AppColors.paper,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.slate.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            payment.method.label,
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
                _currency.format(payment.amount),
                style: const TextStyle(
                  color: AppColors.aqua,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          if (matchingEventTitle != null || payment.reference != null || payment.hasProof) ...[
            const SizedBox(height: 8),
            const Divider(color: Color(0x18FFFFFF), height: 1),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (matchingEventTitle != null)
                        Text(
                          'Event: $matchingEventTitle',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.muted.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      if (payment.reference != null)
                        Text(
                          'Ref: ${payment.reference}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.muted.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                if (payment.hasProof)
                  InkWell(
                    onTap: () => _showProofDialog(context, payment),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.aqua.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.aqua.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.attachment_rounded, size: 12, color: AppColors.aqua),
                          SizedBox(width: 4),
                          Text(
                            'View Proof',
                            style: TextStyle(
                              color: AppColors.aqua,
                              fontSize: 11,
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
  }

  // ================= Add Payment Sheet with Event Picker =================
  void _showAddPaymentSheet(
    BuildContext context, {
    required Client client,
    required List<StudioEvent> events,
  }) {
    final titleController = TextEditingController(text: 'Payment');
    final amountController = TextEditingController();
    final refController = TextEditingController();
    final proofController = TextEditingController();

    String selectedEventId = events.isNotEmpty ? events.first.id : '';
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
                    const SizedBox(height: 12),

                    // EVENT SELECTOR (Crucial when client has multiple events!)
                    if (events.length > 1) ...[
                      const Text(
                        'Select Event for Payment',
                        style: TextStyle(
                          color: AppColors.paper,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.ink.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.slate.withValues(alpha: 0.4),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedEventId,
                            isExpanded: true,
                            dropdownColor: AppColors.navy,
                            style: const TextStyle(
                              color: AppColors.paper,
                              fontSize: 14,
                            ),
                            items: events.map((e) {
                              return DropdownMenuItem<String>(
                                value: e.id,
                                child: Text(
                                  '${e.title} (${_currency.format(e.remainingAmount)} due)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedEventId = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.ink.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.slate.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_note_outlined,
                                color: AppColors.aqua, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Event: ${events.first.title}',
                                style: const TextStyle(
                                  color: AppColors.paper,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    StudioTextField(
                      label: 'Payment Title',
                      hint: 'e.g. Advance, Milestone 2, Final Settlement',
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

                    // PAYMENT METHODS
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

                    // Reference Number / Txn ID
                    StudioTextField(
                      label: 'Reference / Txn ID (Optional)',
                      hint: 'e.g. UPI/2026/892104 or Cheque #1042',
                      controller: refController,
                    ),
                    const SizedBox(height: 14),

                    // Payment Proof Attachment
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
                        hint: 'e.g. upi_screenshot_receipt.png',
                        controller: proofController,
                      ),
                    ],

                    const SizedBox(height: 24),
                    StudioButton(
                      label: 'Save Payment Record',
                      onPressed: () {
                        final amount = double.tryParse(amountController.text.trim());
                        if (amount != null && amount > 0 && selectedEventId.isNotEmpty) {
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
                              .addPayment(selectedEventId, payment);

                          Navigator.of(sheetContext).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Logged ${_currency.format(amount)} via ${selectedMethod.label}'),
                              backgroundColor: AppColors.navy,
                            ),
                          );
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

  // ================= Payment Proof Viewer Modal =================
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

              // Mock Receipt Card
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
          ),
        ),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

  // ================= Edit Client Sheet =================
  void _showEditClientSheet(BuildContext context, Client client) {
    final nameController = TextEditingController(text: client.name);
    final phoneController = TextEditingController(text: client.phone);
    final emailController = TextEditingController(text: client.email);
    final addressController = TextEditingController(text: client.address);
    final notesController = TextEditingController(text: client.notes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
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
                      'Edit Client Details',
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
                  label: 'Full Name',
                  controller: nameController,
                ),
                const SizedBox(height: 14),
                StudioTextField(
                  label: 'Phone Number',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                StudioTextField(
                  label: 'Email Address',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                StudioTextField(
                  label: 'Address / Studio Location',
                  controller: addressController,
                ),
                const SizedBox(height: 14),
                StudioTextField(
                  label: 'Notes / Preferences',
                  controller: notesController,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                StudioButton(
                  label: 'Save Changes',
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      final updated = client.copyWith(
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        email: emailController.text.trim(),
                        address: addressController.text.trim(),
                        notes: notesController.text.trim(),
                      );
                      context.read<EventsProvider>().updateClient(updated);
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
  }
}
