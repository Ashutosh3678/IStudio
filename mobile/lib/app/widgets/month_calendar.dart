import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.visibleMonth,
    required this.selectedDay,
    required this.markedDays,
    required this.onMonthChanged,
    required this.onDaySelected,
    this.upcomingDays = const {},
    this.nearestUpcomingDay,
  });

  final DateTime visibleMonth;
  final DateTime selectedDay;

  /// All dates that have any event (used for backward-compat muted dot on past events).
  final Set<DateTime> markedDays;

  /// Dates of events with status upcoming/inProgress that are today or future.
  final Set<DateTime> upcomingDays;

  /// The single nearest upcoming event date (gets strongest highlight).
  final DateTime? nearestUpcomingDay;

  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  @override
  Widget build(BuildContext context) {
    final first = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth =
        DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final leading = first.weekday % 7; // 0 = Sunday start
    final today = _dateOnly(DateTime.now());

    final markedNorm = markedDays.map(_dateOnly).toSet();
    final upcomingNorm = upcomingDays.map(_dateOnly).toSet();
    final nearestNorm =
        nearestUpcomingDay != null ? _dateOnly(nearestUpcomingDay!) : null;

    return Column(
      children: [
        // Month nav
        Row(
          children: [
            IconButton(
              tooltip: 'Previous month',
              onPressed: () => onMonthChanged(
                DateTime(visibleMonth.year, visibleMonth.month - 1),
              ),
              icon: const Icon(Icons.chevron_left_rounded,
                  color: AppColors.paper),
            ),
            Expanded(
              child: Text(
                DateFormat('MMMM yyyy').format(visibleMonth),
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.paper,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: () => onMonthChanged(
                DateTime(visibleMonth.year, visibleMonth.month + 1),
              ),
              icon: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.paper),
            ),
          ],
        ),

        // Weekday labels
        const SizedBox(height: 4),
        const Row(
          children: [
            _WeekLabel('S'),
            _WeekLabel('M'),
            _WeekLabel('T'),
            _WeekLabel('W'),
            _WeekLabel('T'),
            _WeekLabel('F'),
            _WeekLabel('S'),
          ],
        ),
        const SizedBox(height: 6),

        // Day grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leading + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            if (index < leading) return const SizedBox.shrink();

            final day = DateTime(
              visibleMonth.year,
              visibleMonth.month,
              index - leading + 1,
            );

            final isSelected = _dateOnly(selectedDay) == day;
            final isToday = today == day;
            final isNearest = nearestNorm != null && nearestNorm == day;
            final isUpcoming = upcomingNorm.contains(day);
            final isPastMarked =
                markedNorm.contains(day) && day.isBefore(today);

            return Semantics(
              button: true,
              selected: isSelected,
              label: DateFormat('EEEE d MMMM').format(day),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onDaySelected(day),
                child: _DayCell(
                  day: day,
                  isSelected: isSelected,
                  isToday: isToday,
                  isNearest: isNearest,
                  isUpcoming: isUpcoming,
                  isPastMarked: isPastMarked,
                ),
              ),
            );
          },
        ),

        // Legend
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.aqua,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Upcoming event',
              style: TextStyle(
                color: AppColors.muted.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isNearest,
    required this.isUpcoming,
    required this.isPastMarked,
  });

  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool isNearest;
  final bool isUpcoming;
  final bool isPastMarked;

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.transparent;
    Border? border;
    List<BoxShadow>? shadows;

    if (isSelected) {
      bgColor = AppColors.aqua;
    } else if (isNearest) {
      bgColor = AppColors.aqua.withValues(alpha: 0.25);
      border = Border.all(color: AppColors.aqua, width: 1.5);
      shadows = [
        BoxShadow(
          color: AppColors.aqua.withValues(alpha: 0.25),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    } else if (isToday) {
      bgColor = AppColors.aqua.withValues(alpha: 0.14);
      border = Border.all(color: AppColors.aqua.withValues(alpha: 0.50));
    } else if (isUpcoming) {
      bgColor = AppColors.aqua.withValues(alpha: 0.10);
    }

    Color textColor;
    FontWeight textWeight;
    if (isSelected) {
      textColor = AppColors.ink;
      textWeight = FontWeight.w700;
    } else if (isNearest) {
      textColor = AppColors.aqua;
      textWeight = FontWeight.w700;
    } else if (isToday) {
      textColor = AppColors.paper;
      textWeight = FontWeight.w700;
    } else if (isUpcoming) {
      textColor = AppColors.paper;
      textWeight = FontWeight.w600;
    } else {
      textColor = AppColors.paper.withValues(alpha: 0.75);
      textWeight = FontWeight.w400;
    }

    Color dotColor = Colors.transparent;
    if (isSelected && (isUpcoming || isNearest || isToday)) {
      dotColor = AppColors.ink; // visible on aqua bg
    } else if (isNearest) {
      dotColor = AppColors.aqua;
    } else if (isUpcoming) {
      dotColor = AppColors.aqua;
    } else if (isPastMarked) {
      dotColor = AppColors.muted.withValues(alpha: 0.40);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: border,
        boxShadow: shadows,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: textWeight,
                  fontSize: 13,
                ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekLabel extends StatelessWidget {
  const _WeekLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
