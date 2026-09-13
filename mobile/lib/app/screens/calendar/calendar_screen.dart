import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/studio_demo_data.dart';
import '../../models/studio_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/month_calendar.dart';
import '../../widgets/studio_app_bar.dart';
import '../../widgets/studio_card.dart';

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

  List<StudioSession> get _daySessions {
    return StudioDemoData.sessions.where((session) {
      final date = session.startsAt;
      return date.year == _selected.year &&
          date.month == _selected.month &&
          date.day == _selected.day;
    }).toList();
  }

  Set<DateTime> get _marked {
    return StudioDemoData.sessions
        .map(
          (session) => DateTime(
            session.startsAt.year,
            session.startsAt.month,
            session.startsAt.day,
          ),
        )
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _daySessions;

    return SafeArea(
      child: Column(
        children: [
          const StudioAppBar(
            title: 'Calendar',
            subtitle: 'Booked sessions',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                StudioCard(
                  child: MonthCalendar(
                    visibleMonth: _month,
                    selectedDay: _selected,
                    markedDays: _marked,
                    onMonthChanged: (value) => setState(() => _month = value),
                    onDaySelected: (value) => setState(() => _selected = value),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  DateFormat('EEEE, d MMMM').format(_selected),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.paper,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (sessions.isEmpty)
                  StudioCard(
                    child: Text(
                      'No shoots booked for this day.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  )
                else
                  ...sessions.map(
                    (session) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: StudioCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.title,
                              style: const TextStyle(
                                color: AppColors.paper,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${session.clientName} · ${DateFormat.jm().format(session.startsAt)}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.muted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              session.location,
                              style: const TextStyle(color: AppColors.aqua),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
