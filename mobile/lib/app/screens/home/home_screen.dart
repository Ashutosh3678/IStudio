import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/studio_event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/events_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/studio_app_bar.dart';
import '../../widgets/studio_button.dart';
import '../../widgets/studio_card.dart';
import '../events/create_event_sheet.dart';
import '../events/event_details_screen.dart';
import '../events/past_events_screen.dart';
import '../events/upcoming_events_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  int _currentCarouselIndex = 0;

  static final _currency =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final eventsProvider = context.watch<EventsProvider>();

    final upcoming = eventsProvider.upcomingEvents.take(5).toList();
    final past = eventsProvider.pastEvents.take(3).toList();
    final textMain = context.textMain;
    final textMuted = context.textMuted;

    return SafeArea(
      child: Column(
        children: [
          StudioAppBar(
            title: user?.displayStudioName ?? 'Lumen',
            subtitle: 'Studio desk',
            actions: [
              Semantics(
                button: true,
                label: 'Open profile',
                child: IconButton(
                  tooltip: 'Profile',
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder<void>(
                        transitionDuration: const Duration(milliseconds: 280),
                        pageBuilder: (_, _, _) => const ProfileScreen(),
                        transitionsBuilder: (_, animation, _, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  icon: ProfileAvatar(logoUrl: user?.logoUrl, size: 40),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              children: [
                // Welcome Message
                Text(
                  'Welcome back, ${user?.displayOwner ?? 'there'}',
                  style: GoogleFonts.playfairDisplay(
                    color: textMain,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sessions, invoices, and clients sit together on one desk.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textMuted,
                      ),
                ),
                const SizedBox(height: 24),

                // 1. Upcoming Events Section Header
                _buildSectionHeader(
                  context,
                  title: 'Upcoming Events',
                  actionLabel: 'View all →',
                  onAction: () {
                    Navigator.of(context).push(
                      PageRouteBuilder<void>(
                        transitionDuration: const Duration(milliseconds: 280),
                        pageBuilder: (_, _, _) => const UpcomingEventsScreen(),
                        transitionsBuilder: (_, animation, _, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // 1. Upcoming Events Carousel
                if (upcoming.isEmpty)
                  _buildEmptyUpcomingState(context)
                else
                  _buildUpcomingCarousel(context, upcoming),

                const SizedBox(height: 18),

                // 2. Add Event Button
                StudioButton(
                  label: '+ Add Event',
                  onPressed: () => CreateEventSheet.show(context),
                ),

                const SizedBox(height: 28),

                // 3. Past Events Section Header
                _buildSectionHeader(
                  context,
                  title: 'Past Events',
                  actionLabel: 'View all →',
                  onAction: () {
                    Navigator.of(context).push(
                      PageRouteBuilder<void>(
                        transitionDuration: const Duration(milliseconds: 280),
                        pageBuilder: (_, _, _) => const PastEventsScreen(),
                        transitionsBuilder: (_, animation, _, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // 3. Past Events List (2–3 recent completed)
                if (past.isEmpty)
                  StudioCard(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No past events recorded yet.',
                        style: TextStyle(
                          color: textMuted.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  ...past.map((event) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPastEventCard(context, event),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= Section Header with "View all →" =================
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
        ),
        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              actionLabel,
              style: TextStyle(
                color: context.accentColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= Carousel Widget =================
  Widget _buildUpcomingCarousel(BuildContext context, List<StudioEvent> events) {
    final accent = context.accentColor;
    final border = context.cardBorder;

    return Column(
      children: [
        SizedBox(
          height: 205,
          child: PageView.builder(
            controller: _pageController,
            itemCount: events.length,
            onPageChanged: (index) {
              setState(() => _currentCarouselIndex = index);
            },
            itemBuilder: (context, index) {
              final event = events[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: child,
                  );
                },
                child: _buildUpcomingCard(context, event),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(events.length, (index) {
            final isCurrent = index == _currentCarouselIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3.5),
              width: isCurrent ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isCurrent ? accent : border.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ================= Upcoming Event Card =================
  Widget _buildUpcomingCard(BuildContext context, StudioEvent event) {
    final dateStr = DateFormat('d MMM yyyy').format(event.startsAt);
    final dayStr = DateFormat('EEEE').format(event.startsAt);
    final remaining = event.remainingAmount;
    final accent = context.accentColor;
    final textMain = context.textMain;
    final textMuted = context.textMuted;
    final innerBg = context.innerBg;
    final cardBorder = context.cardBorder;

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: accent,
                  size: 22,
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
                        color: textMain,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Client: ${event.clientName} · ${event.eventType}',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(child: _buildStatusBadge(context, event.status)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: innerBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: cardBorder.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_outlined,
                    color: accent, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: dateStr,
                          style: TextStyle(
                            color: textMain,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: ' · $dayStr · ${event.location}',
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  remaining > 0
                      ? '${_currency.format(remaining)} due'
                      : 'Fully Paid',
                  style: TextStyle(
                    color: remaining > 0
                        ? (context.isDark
                            ? const Color(0xFFE8B86D)
                            : const Color(0xFFD97706))
                        : accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Details',
                    style: TextStyle(
                      color: accent.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: accent, size: 10),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= Empty Upcoming State =================
  Widget _buildEmptyUpcomingState(BuildContext context) {
    return StudioCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 42,
            color: context.textMuted.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 10),
          Text(
            'No upcoming events',
            style: TextStyle(
              color: context.textMain,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your upcoming photo sessions will appear here.',
            style: TextStyle(color: context.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.accentColor,
              foregroundColor: context.isDark ? AppColors.ink : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => CreateEventSheet.show(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('+ Add Event'),
          ),
        ],
      ),
    );
  }

  // ================= Past Event Compact Card =================
  Widget _buildPastEventCard(BuildContext context, StudioEvent event) {
    final dateStr = DateFormat('d MMM yyyy').format(event.startsAt);
    final textMain = context.textMain;
    final textMuted = context.textMuted;
    final statusColor = AppColors.statusColor(context, EventStatus.completed);

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        color: textMain,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$dateStr · ${event.eventType}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    'Completed',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Compact financial breakdown: Total, Received, Expenses, Net Profit
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: context.innerBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildCompactMetric(
                      context, 'Total', _currency.format(event.totalAmount)),
                ),
                Expanded(
                  child: _buildCompactMetric(
                      context, 'Received', _currency.format(event.amountReceived)),
                ),
                Expanded(
                  child: _buildCompactMetric(
                    context,
                    'Expenses',
                    _currency.format(event.totalExpenses),
                    valueColor: AppColors.expense(context),
                  ),
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

  Widget _buildStatusBadge(BuildContext context, EventStatus status) {
    final color = AppColors.statusColor(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
