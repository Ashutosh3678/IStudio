import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/studio_event.dart';
import '../../providers/events_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/studio_app_bar.dart';
import '../../widgets/studio_card.dart';
import 'create_event_sheet.dart';
import 'event_details_screen.dart';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

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
    final allUpcoming = provider.upcomingEvents;

    final query = _searchController.text.trim().toLowerCase();
    final filtered = allUpcoming.where((event) {
      final matchesCategory = _selectedCategory == 'All' ||
          event.eventType.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = query.isEmpty ||
          event.title.toLowerCase().contains(query) ||
          event.clientName.toLowerCase().contains(query) ||
          event.location.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            StudioAppBar(
              title: 'Upcoming Events',
              subtitle: 'Scheduled shoots & bookings',
              leading: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.paper, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  tooltip: 'Add Event',
                  icon: const Icon(Icons.add_circle_outline_rounded,
                      color: AppColors.aqua, size: 24),
                  onPressed: () => CreateEventSheet.show(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: AppColors.paper, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search upcoming shoots, clients, venues...',
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
                          Icon(Icons.calendar_today_rounded,
                              size: 48,
                              color: AppColors.muted.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'No upcoming events found',
                            style: TextStyle(
                              color: AppColors.paper,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.aqua,
                              foregroundColor: AppColors.ink,
                            ),
                            onPressed: () => CreateEventSheet.show(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('+ Add Event'),
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
                        return _buildUpcomingEventCard(context, event);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEventCard(BuildContext context, StudioEvent event) {
    final dateStr = DateFormat('d MMM yyyy').format(event.startsAt);
    final dayStr = DateFormat('EEEE').format(event.startsAt);
    final remaining = event.remainingAmount;

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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.aqua.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.aqua,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
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
                      'Client: ${event.clientName} · ${event.eventType}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(event.status),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.ink.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    color: AppColors.aqua, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$dateStr · $dayStr',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.paper,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.location_on_outlined,
                    color: AppColors.muted, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  remaining > 0
                      ? '${_currency.format(remaining)} due'
                      : 'Fully Paid',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: remaining > 0
                        ? const Color(0xFFE8B86D)
                        : AppColors.aqua,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Total: ${_currency.format(event.totalAmount)}',
                  maxLines: 1,
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
    );
  }

  Widget _buildStatusBadge(EventStatus status) {
    Color color;
    switch (status) {
      case EventStatus.completed:
        color = AppColors.aqua;
        break;
      case EventStatus.inProgress:
        color = const Color(0xFF64B5F6);
        break;
      case EventStatus.paymentDue:
        color = const Color(0xFFE8B86D);
        break;
      case EventStatus.upcoming:
        color = const Color(0xFF81C784);
        break;
      case EventStatus.cancelled:
        color = const Color(0xFFFF7A8A);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
