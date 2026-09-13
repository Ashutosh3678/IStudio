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
  });

  final DateTime visibleMonth;
  final DateTime selectedDay;
  final Set<DateTime> markedDays;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  @override
  Widget build(BuildContext context) {
    final first = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final leading = first.weekday % 7;
    final today = _dateOnly(DateTime.now());
    final marked = markedDays.map(_dateOnly).toSet();

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Previous month',
              onPressed: () => onMonthChanged(
                DateTime(visibleMonth.year, visibleMonth.month - 1),
              ),
              icon: const Icon(Icons.chevron_left_rounded, color: AppColors.paper),
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
              icon: const Icon(Icons.chevron_right_rounded, color: AppColors.paper),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            _WeekLabel('S'),
            _WeekLabel('M'),
            _WeekLabel('T'),
            _WeekLabel('W'),
            _WeekLabel('T'),
            _WeekLabel('F'),
            _WeekLabel('S'),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leading + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            if (index < leading) return const SizedBox.shrink();
            final day = DateTime(
              visibleMonth.year,
              visibleMonth.month,
              index - leading + 1,
            );
            final selected = _dateOnly(selectedDay) == day;
            final isToday = today == day;
            final hasEvent = marked.contains(day);

            return Semantics(
              button: true,
              selected: selected,
              label: DateFormat('EEEE d MMMM').format(day),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onDaySelected(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.aqua
                        : isToday
                        ? AppColors.aqua.withValues(alpha: 0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isToday && !selected
                        ? Border.all(color: AppColors.aqua.withValues(alpha: 0.5))
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: selected ? AppColors.ink : AppColors.paper,
                          fontWeight: selected || isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasEvent
                              ? (selected ? AppColors.ink : AppColors.aqua)
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
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
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.muted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
