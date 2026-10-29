import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';

/// Describes a continuous date range for an event.
typedef EventRange = ({DateTime start, DateTime end});

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
    this.eventRanges = const [],
  });

  final DateTime visibleMonth;
  final DateTime selectedDay;

  /// All dates that have any event (used for backward-compat muted dot on past events).
  final Set<DateTime> markedDays;

  /// Dates of events with status upcoming/inProgress that are today or future.
  final Set<DateTime> upcomingDays;

  /// The single nearest upcoming event date (gets strongest highlight).
  final DateTime? nearestUpcomingDay;

  /// Full date ranges for events — used to draw continuous multi-day shoot cards & banners.
  final List<EventRange> eventRanges;

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

    final normRanges = eventRanges
        .map((r) => (start: _dateOnly(r.start), end: _dateOnly(r.end)))
        .where((r) => r.start != r.end) // Only multi-day events
        .toList();

    final textMain = context.textMain;
    final textMuted = context.textMuted;
    final accent = context.accentColor;

    // Group month days into 7-day weeks
    final List<List<DateTime?>> weeks = [];
    List<DateTime?> currentWeek = [];

    for (int i = 0; i < leading; i++) {
      currentWeek.add(null);
    }
    for (int day = 1; day <= daysInMonth; day++) {
      currentWeek.add(DateTime(visibleMonth.year, visibleMonth.month, day));
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }
    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(null);
      }
      weeks.add(currentWeek);
    }

    return Column(
      children: [
        // Month & Year nav
        Row(
          children: [
            IconButton(
              tooltip: 'Previous Year',
              onPressed: () {
                HapticFeedback.selectionClick();
                onMonthChanged(
                  DateTime(visibleMonth.year - 1, visibleMonth.month),
                );
              },
              icon: Icon(Icons.first_page_rounded, color: textMuted, size: 20),
            ),
            IconButton(
              tooltip: 'Previous Month',
              onPressed: () {
                HapticFeedback.selectionClick();
                onMonthChanged(
                  DateTime(visibleMonth.year, visibleMonth.month - 1),
                );
              },
              icon: Icon(Icons.chevron_left_rounded, color: textMain),
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  HapticFeedback.selectionClick();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDay,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDatePickerMode: DatePickerMode.year,
                    helpText: 'JUMP TO ANY YEAR, MONTH & DAY',
                  );
                  if (picked != null) {
                    onMonthChanged(DateTime(picked.year, picked.month));
                    onDaySelected(picked);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('MMMM yyyy').format(visibleMonth),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: textMain,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down_circle_outlined,
                          color: accent,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Next Month',
              onPressed: () {
                HapticFeedback.selectionClick();
                onMonthChanged(
                  DateTime(visibleMonth.year, visibleMonth.month + 1),
                );
              },
              icon: Icon(Icons.chevron_right_rounded, color: textMain),
            ),
            IconButton(
              tooltip: 'Next Year',
              onPressed: () {
                HapticFeedback.selectionClick();
                onMonthChanged(
                  DateTime(visibleMonth.year + 1, visibleMonth.month),
                );
              },
              icon: Icon(Icons.last_page_rounded, color: textMuted, size: 20),
            ),
          ],
        ),

        // Weekday labels (S M T W T F S)
        const SizedBox(height: 6),
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
        const SizedBox(height: 8),

        // Weeks List
        ...weeks.map((week) {
          // Identify multi-day ranges that intersect with this week
          final weekValidDays = week.whereType<DateTime>().toList();
          final segmentsInWeek = <({int startCol, int endCol, int totalDays})>[];

          if (weekValidDays.isNotEmpty) {
            for (final r in normRanges) {
              int startCol = -1;
              int endCol = -1;
              for (int col = 0; col < 7; col++) {
                final d = week[col];
                if (d != null && !d.isBefore(r.start) && !d.isAfter(r.end)) {
                  if (startCol == -1) startCol = col;
                  endCol = col;
                }
              }
              if (startCol != -1 && endCol != -1) {
                final totalDays = r.end.difference(r.start).inDays + 1;
                segmentsInWeek.add((
                  startCol: startCol,
                  endCol: endCol,
                  totalDays: totalDays,
                ));
              }
            }
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row of 7 day cells
              Row(
                children: List.generate(7, (col) {
                  final day = week[col];
                  if (day == null) {
                    return const Expanded(child: SizedBox(height: 50));
                  }

                  final isSelected = _dateOnly(selectedDay) == day;
                  final isToday = today == day;
                  final isNearest = nearestNorm != null && nearestNorm == day;
                  final isUpcoming = upcomingNorm.contains(day);
                  final isPastMarked =
                      markedNorm.contains(day) && day.isBefore(today);

                  // Check if day is part of a multi-day range
                  EventRange? matchedRange;
                  for (final r in normRanges) {
                    if (!day.isBefore(r.start) && !day.isAfter(r.end)) {
                      matchedRange = r;
                      break;
                    }
                  }

                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: isSelected,
                      label: DateFormat('EEEE d MMMM').format(day),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onDaySelected(day);
                        },
                        child: _DayCell(
                          day: day,
                          isSelected: isSelected,
                          isToday: isToday,
                          isNearest: isNearest,
                          isUpcoming: isUpcoming,
                          isPastMarked: isPastMarked,
                          range: matchedRange,
                          isFirstCol: col == 0,
                          isLastCol: col == 6,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              // Multi-day shoot subtitle indicator below the week: ─── 📅 5-day shoot ───
              ...segmentsInWeek.map((seg) {
                return Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 6),
                  child: Row(
                    children: [
                      if (seg.startCol > 0) Spacer(flex: seg.startCol),
                      Expanded(
                        flex: seg.endCol - seg.startCol + 1,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Divider(
                                  color: accent.withValues(alpha: 0.35),
                                  thickness: 1,
                                  endIndent: 6,
                                ),
                              ),
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 11,
                                color: accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${seg.totalDays}-day shoot',
                                style: GoogleFonts.plusJakartaSans(
                                  color: accent,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: accent.withValues(alpha: 0.35),
                                  thickness: 1,
                                  indent: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (seg.endCol < 6) Spacer(flex: 6 - seg.endCol),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 2),
            ],
          );
        }),

        // Legend
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 18,
              height: 7,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Event range',
              style: TextStyle(
                color: textMuted,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Upcoming event',
              style: TextStyle(
                color: textMuted,
                fontSize: 10.5,
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
    required this.range,
    required this.isFirstCol,
    required this.isLastCol,
  });

  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool isNearest;
  final bool isUpcoming;
  final bool isPastMarked;
  final EventRange? range;
  final bool isFirstCol;
  final bool isLastCol;

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    final textMain = context.textMain;
    final textMuted = context.textMuted;
    final isDark = context.isDark;

    // ─────────────────────────────────────────────────────────────────────────
    // CASE A: Day is part of a Multi-Day Event Range (renders like user mockup)
    // ─────────────────────────────────────────────────────────────────────────
    if (range != null) {
      final rangeStart = _dateOnly(range!.start);
      final rangeEnd = _dateOnly(range!.end);
      final isStart = day == rangeStart;
      final isEnd = day == rangeEnd;

      // Card styling for multi-day range
      Color cardBg;
      Color numColor;
      Color subColor;
      List<BoxShadow>? shadows;

      if (isStart || isEnd || isSelected) {
        // Solid accent for boundary dates or when actively selected
        cardBg = accent;
        numColor = Colors.white;
        subColor = Colors.white.withValues(alpha: 0.88);
        shadows = [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
      } else {
        // Soft accent background for middle days
        cardBg = accent.withValues(alpha: isDark ? 0.20 : 0.10);
        numColor = textMain;
        subColor = accent;
      }

      final weekdayName = DateFormat('E').format(day); // 'Sun', 'Mon', etc.

      // Connecting track behind cards
      final leftRadius = (isStart || isFirstCol) ? const Radius.circular(12) : Radius.zero;
      final rightRadius = (isEnd || isLastCol) ? const Radius.circular(12) : Radius.zero;

      return Container(
        height: 52,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Track uniting the range segment
            Positioned(
              left: (isStart || isFirstCol) ? 2 : 0,
              right: (isEnd || isLastCol) ? 2 : 0,
              top: 2,
              bottom: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.10 : 0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: leftRadius,
                    bottomLeft: leftRadius,
                    topRight: rightRadius,
                    bottomRight: rightRadius,
                  ),
                ),
              ),
            ),

            // Day card with Date number on top & Weekday name below
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(10),
                boxShadow: shadows,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${day.day}',
                      style: GoogleFonts.plusJakartaSans(
                        color: numColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      weekdayName,
                      style: GoogleFonts.plusJakartaSans(
                        color: subColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 9.5,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CASE B: Standard Day Cell — STRICTLY USES A PERFECT CIRCLE (never oval)
    // ─────────────────────────────────────────────────────────────────────────
    Color circleBg = Colors.transparent;
    Border circleBorder = Border.all(color: Colors.transparent, width: 1.5);
    List<BoxShadow>? circleShadows;

    if (isSelected) {
      circleBg = accent;
      circleShadows = [
        BoxShadow(
          color: accent.withValues(alpha: 0.35),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (isNearest) {
      circleBg = accent.withValues(alpha: 0.20);
      circleBorder = Border.all(color: accent, width: 1.5);
      circleShadows = [
        BoxShadow(
          color: accent.withValues(alpha: 0.20),
          blurRadius: 6,
          spreadRadius: 0.5,
        ),
      ];
    } else if (isToday) {
      circleBg = accent.withValues(alpha: 0.12);
      circleBorder = Border.all(
        color: accent.withValues(alpha: 0.65),
        width: 1.5,
      );
    } else if (isUpcoming) {
      circleBg = accent.withValues(alpha: 0.10);
    }

    Color textColor;
    FontWeight textWeight;
    if (isSelected) {
      textColor = Colors.white;
      textWeight = FontWeight.w700;
    } else if (isNearest) {
      textColor = accent;
      textWeight = FontWeight.w700;
    } else if (isToday) {
      textColor = textMain;
      textWeight = FontWeight.w700;
    } else if (isUpcoming) {
      textColor = textMain;
      textWeight = FontWeight.w600;
    } else {
      textColor = textMain.withValues(alpha: 0.75);
      textWeight = FontWeight.w400;
    }

    Color dotColor = Colors.transparent;
    if (isSelected && (isUpcoming || isNearest || isToday)) {
      dotColor = Colors.white;
    } else if (isNearest || isUpcoming) {
      dotColor = accent;
    } else if (isPastMarked) {
      dotColor = textMuted.withValues(alpha: 0.50);
    }

    return Container(
      height: 52,
      alignment: Alignment.center,
      child: Center(
        // Explicit 36x36 with BoxShape.circle guarantees a mathematical CIRCLE
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
            border: circleBorder,
            boxShadow: circleShadows,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: GoogleFonts.plusJakartaSans(
                  color: textColor,
                  fontWeight: textWeight,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 1),
              Container(
                width: 3.5,
                height: 3.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
            ],
          ),
        ),
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
              color: context.textMuted,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
