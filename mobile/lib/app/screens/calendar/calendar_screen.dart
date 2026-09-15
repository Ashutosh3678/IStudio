import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/studio_event.dart';
import '../../providers/events_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/month_calendar.dart';
import '../../widgets/studio_app_bar.dart';
import '../../widgets/studio_card.dart';
import '../events/create_event_sheet.dart';
import '../events/event_details_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selected = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  static final _currency =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventsProvider>();
    final allEvents = provider.events;
    final today = _dateOnly(DateTime.now());

    final textMain = context.textMain;
    final textMuted = context.textMuted;
    final accent = context.accentColor;

    final dayEvents = allEvents.where((event) {
      final date = event.startsAt;
      return date.year == _selected.year &&
          date.month == _selected.month &&
          date.day == _selected.day;
    }).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    final upcomingEvents = allEvents
        .where((event) {
          final eventDay = _dateOnly(event.startsAt);
          final hasUpcomingStatus = event.status == EventStatus.upcoming ||
              event.status == EventStatus.inProgress;
          return hasUpcomingStatus && !eventDay.isBefore(today);
        })
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    final marked = allEvents
        .map(
          (event) => DateTime(
            event.startsAt.year,
            event.startsAt.month,
            event.startsAt.day,
          ),
        )
        .toSet();

    final upcomingDays =
        upcomingEvents.map((event) => _dateOnly(event.startsAt)).toSet();
    final nearestUpcomingDay = upcomingEvents.isEmpty
        ? null
        : _dateOnly(upcomingEvents.first.startsAt);

    return SafeArea(
      child: Column(
        children: [
          StudioAppBar(
            title: 'Calendar',
            subtitle: 'Booked sessions',
            actions: [
              IconButton(
                tooltip: 'Add Shoot',
                icon: Icon(Icons.add_circle_outline_rounded,
                    color: accent, size: 22),
                onPressed: () => CreateEventSheet.show(context),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                StudioCard(
                  child: MonthCalendar(
                    visibleMonth: _month,
                    selectedDay: _selected,
                    markedDays: marked,
                    upcomingDays: upcomingDays,
                    nearestUpcomingDay: nearestUpcomingDay,
                    onMonthChanged: (value) => setState(() => _month = value),
                    onDaySelected: (value) => setState(() => _selected = value),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  DateFormat('EEEE, d MMMM').format(_selected),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textMain,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (dayEvents.isEmpty)
                  StudioCard(
                    child: Text(
                      'No shoots booked for this day.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textMuted,
                      ),
                    ),
                  )
                else
                  ...dayEvents.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildEventCard(context, event),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openEventDetails(BuildContext context, StudioEvent event) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, _, _) => EventDetailsScreen(eventId: event.id),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, StudioEvent event) {
    final amountDue = event.remainingAmount;
    final amountText = amountDue > 0 ? _currency.format(amountDue) : 'None';
    final accent = context.accentColor;
    final textMain = context.textMain;
    final textMuted = context.textMuted;

    return StudioCard(
      onTap: () => _openEventDetails(context, event),
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
                      style: TextStyle(
                        color: textMain,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.clientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 118),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event.eventType,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _EventInfoRow(
            icon: Icons.schedule_rounded,
            text: '${event.startTime} – ${event.endTime}',
          ),
          const SizedBox(height: 8),
          _EventInfoRow(
            icon: Icons.account_balance_wallet_outlined,
            text: 'Amount due: $amountText',
            color: amountDue > 0
                ? (context.isDark
                    ? const Color(0xFFE8B86D)
                    : const Color(0xFFD97706))
                : accent,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: accent,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _openEventDetails(context, event),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  child: Text(
                    'Details →',
                    style: TextStyle(
                      color: accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventInfoRow extends StatelessWidget {
  const _EventInfoRow({
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final defaultMuted = context.textMuted;
    final rowColor = color ?? defaultMuted;

    return Row(
      children: [
        Icon(icon, color: context.accentColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: rowColor,
              fontSize: 13,
              fontWeight: color == null ? FontWeight.w500 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
