import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/studio_event.dart';
import '../../providers/events_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/studio_app_bar.dart';
import '../../widgets/studio_card.dart';
import '../../widgets/payment_proof_preview.dart';
import '../../widgets/event_status_badge.dart';
import 'event_details_screen.dart';
import '../../routes/smooth_page_route.dart';

class PastEventsScreen extends StatefulWidget {
  const PastEventsScreen({super.key});

  @override
  State<PastEventsScreen> createState() => _PastEventsScreenState();
}

class _PastEventsScreenState extends State<PastEventsScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _newestFirst = true;

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static const _completedFilter = 'Completed';

  final List<String> _categories = [
    'All',
    _completedFilter,
    'Wedding',
    'Maternity',
    'Commercial',
    'Newborn',
    'Portrait',
    'Others',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _categoryCount(String cat, List<StudioEvent> events) {
    if (cat == 'All') return events.length;
    if (cat == _completedFilter) return events.where((e) => e.status == EventStatus.completed).length;
    if (cat == 'Others') {
      return events.where((e) =>
        !const ['wedding', 'maternity', 'commercial', 'newborn', 'portrait', 'pre-wedding', 'fashion', 'event']
            .contains(e.eventType.toLowerCase()) ||
        e.eventType.toLowerCase() == 'others'
      ).length;
    }
    return events.where((e) => e.eventType.toLowerCase() == cat.toLowerCase()).length;
  }

  Widget _buildFilterHamburger(BuildContext context, List<StudioEvent> allPast) {
    final hasActive = _selectedCategory != 'All';
    final accent = context.accentColor;

    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: 'Filter Past Shoots',
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showCategoryFilterSheet(context, allPast),
          child: Ink(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hasActive
                  ? accent.withValues(alpha: context.isDark ? 0.22 : 0.12)
                  : context.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasActive ? accent : context.cardBorder,
                width: hasActive ? 1.5 : 1,
              ),
              boxShadow: hasActive
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: hasActive ? accent : context.textMain,
                ),
                if (hasActive)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCategoryFilterSheet(BuildContext context, List<StudioEvent> allPast) async {
    HapticFeedback.lightImpact();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.72,
          ),
          padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + MediaQuery.paddingOf(context).bottom),
          decoration: BoxDecoration(
            color: sheetContext.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: sheetContext.cardBorder, width: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: sheetContext.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: sheetContext.accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.tune_rounded, color: sheetContext.accentColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Filter Past Shoots',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: sheetContext.textMain,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedCategory != 'All')
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedCategory = 'All');
                        Navigator.of(sheetContext).pop();
                      },
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: sheetContext.accentColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    final count = _categoryCount(cat, allPast);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                          Navigator.of(sheetContext).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? sheetContext.accentColor.withValues(alpha: sheetContext.isDark ? 0.18 : 0.1)
                                : sheetContext.innerBg.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? sheetContext.accentColor
                                  : sheetContext.cardBorder.withValues(alpha: 0.5),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                size: 18,
                                color: isSelected ? sheetContext.accentColor : sheetContext.textMuted,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  cat,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: sheetContext.textMain,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? sheetContext.accentColor.withValues(alpha: 0.2)
                                      : sheetContext.cardBorder.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? sheetContext.accentColor : sheetContext.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventsProvider>();
    final allPast = provider.pastEvents;
    final textMain = context.textMain;
    final textMuted = context.textMuted;
    final accent = context.accentColor;

    final query = _searchController.text.trim().toLowerCase();
    final filtered = allPast.where((event) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          (_selectedCategory == _completedFilter
              ? event.status == EventStatus.completed
              : _selectedCategory == 'Others'
              ? !const [
                      'wedding',
                      'maternity',
                      'commercial',
                      'newborn',
                      'portrait',
                      'pre-wedding',
                      'fashion',
                      'event',
                    ].contains(event.eventType.toLowerCase()) ||
                    event.eventType.toLowerCase() == 'others'
              : event.eventType.toLowerCase() ==
                    _selectedCategory.toLowerCase());
      final matchesSearch =
          query.isEmpty ||
          event.title.toLowerCase().contains(query) ||
          event.clientName.toLowerCase().contains(query) ||
          event.location.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    if (_newestFirst) {
      filtered.sort((a, b) => b.startsAt.compareTo(a.startsAt));
    } else {
      filtered.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              children: [
                StudioAppBar(
                  title: 'Past Shoots',
                  subtitle: 'Past shoots',
                  leading: IconButton(
                    tooltip: 'Back',
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: textMain,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    IconButton(
                      tooltip: _newestFirst ? 'Sort: Newest' : 'Sort: Oldest',
                      icon: Icon(
                        _newestFirst
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: accent,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _newestFirst = !_newestFirst);
                      },
                    ),
                  ],
                ),
                // Search Bar & Filter chips
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              style: TextStyle(color: textMain, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Search past shoots, clients, locations...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: textMuted,
                                  size: 20,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: textMuted,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {});
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: context.cardBg,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterHamburger(context, allPast),
                        ],
                      ),
                      if (_selectedCategory != 'All') ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Filtered by:',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => setState(() => _selectedCategory = 'All'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedCategory,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: accent,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.close_rounded, size: 14, color: accent),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => setState(() => _selectedCategory = 'All'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Clear',
                                style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history_toggle_off_rounded,
                                size: 48,
                                color: textMuted.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No past shoots match your filter',
                                style: TextStyle(
                                  color: textMain,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final event = filtered[index];
                            return _buildPastEventCard(context, event);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPastEventCard(BuildContext context, StudioEvent event) {
    final dateStr = DateFormat('d MMM yyyy').format(event.startsAt);
    final textMain = context.textMain;
    final textMuted = context.textMuted;
    final statusColor = event.effectiveStatusColor(context);

    return StudioCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.of(context).push(
          SmoothPageRoute(
            builder: (_) => EventDetailsScreen(eventId: event.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  Icons.photo_camera_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: textMain,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$dateStr · ${event.eventType} · ${event.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: EventStatusBadge(event: event),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Financial snapshot row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: context.innerBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.cardBorder.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildCompactMetric(
                    context,
                    'Total',
                    _currency.format(event.totalAmount),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: context.cardBorder.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildCompactMetric(
                    context,
                    'Received',
                    _currency.format(event.amountReceived),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: context.cardBorder.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildCompactMetric(
                    context,
                    'Expenses',
                    _currency.format(event.totalExpenses),
                    valueColor: AppColors.expense(context),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: context.cardBorder.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildCompactMetric(
                    context,
                    'Net Profit',
                    _currency.format(event.netProfit),
                    valueColor: AppColors.profit(context),
                    isBold: true,
                  ),
                ),
              ],
            ),
          ),
          if (event.payments.any((payment) => payment.hasProof)) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: PaymentProofPreviewButton(payments: event.payments),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactMetric(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              color: valueColor ?? context.textMain,
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
