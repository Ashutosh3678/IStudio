import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/studio_event.dart';
import '../../providers/events_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/studio_app_bar.dart';
import '../../widgets/studio_card.dart';
import 'event_details_screen.dart';

class PastEventsScreen extends StatefulWidget {
  const PastEventsScreen({super.key});

  @override
  State<PastEventsScreen> createState() => _PastEventsScreenState();
}

class _PastEventsScreenState extends State<PastEventsScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _newestFirst = true;

  static final _currency =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  final List<String> _categories = [
    'All',
    'Wedding',
    'Maternity',
    'Commercial',
    'Newborn',
    'Portrait',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventsProvider>();
    final allPast = provider.pastEvents;

    final query = _searchController.text.trim().toLowerCase();
    final filtered = allPast.where((event) {
      final matchesCategory = _selectedCategory == 'All' ||
          event.eventType.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = query.isEmpty ||
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
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            StudioAppBar(
              title: 'Past Events',
              subtitle: 'Completed shoots & business history',
              leading: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.paper, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  tooltip: _newestFirst ? 'Sort: Newest' : 'Sort: Oldest',
                  icon: Icon(
                    _newestFirst
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: AppColors.aqua,
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
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: AppColors.paper, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search past shoots, clients, locations...',
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.muted, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: AppColors.muted, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.navy.withValues(alpha: 0.8),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final cat = _categories[idx];
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                          selectedColor: AppColors.aqua.withValues(alpha: 0.25),
                          backgroundColor: AppColors.navy.withValues(alpha: 0.7),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.aqua
                                : AppColors.slate.withValues(alpha: 0.35),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.aqua : AppColors.paper,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        );
                      },
                    ),
                  ),
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
                          Icon(Icons.history_rounded,
                              size: 48,
                              color: AppColors.muted.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'No completed events match your search',
                            style: TextStyle(
                              color: AppColors.paper,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Try adjusting your search query or category filters',
                            style: TextStyle(color: AppColors.muted, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final event = filtered[index];
                        return _buildPastEventCard(context, event);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastEventCard(BuildContext context, StudioEvent event) {
    final dateStr = DateFormat('d MMM yyyy').format(event.startsAt);

    return StudioCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 280),
            pageBuilder: (_, _, _) => EventDetailsScreen(eventId: event.id),
            transitionsBuilder: (_, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
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
                  color: AppColors.aqua.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  color: AppColors.aqua,
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
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.paper,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$dateStr · ${event.eventType} · ${event.location}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.aqua.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.aqua.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: AppColors.aqua, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Completed',
                      style: TextStyle(
                        color: AppColors.aqua,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Financial snapshot row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.ink.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.slate.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildCompactMetric(
                      'Total', _currency.format(event.totalAmount)),
                ),
                Container(
                    width: 1,
                    height: 24,
                    color: AppColors.slate.withValues(alpha: 0.3)),
                Expanded(
                  child: _buildCompactMetric(
                      'Received', _currency.format(event.amountReceived)),
                ),
                Container(
                    width: 1,
                    height: 24,
                    color: AppColors.slate.withValues(alpha: 0.3)),
                Expanded(
                  child: _buildCompactMetric(
                      'Expenses', _currency.format(event.totalExpenses),
                      valueColor: const Color(0xFFFF7A8A)),
                ),
                Container(
                    width: 1,
                    height: 24,
                    color: AppColors.slate.withValues(alpha: 0.3)),
                Expanded(
                  child: _buildCompactMetric(
                      'Net Profit', _currency.format(event.netProfit),
                      valueColor: AppColors.aqua, isBold: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMetric(
    String label,
    String value, {
    Color valueColor = AppColors.paper,
    bool isBold = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.muted,
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
              color: valueColor,
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
