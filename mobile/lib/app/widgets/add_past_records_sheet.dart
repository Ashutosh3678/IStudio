import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/events/add_past_event_sheet.dart';
import '../screens/records/add_monthly_summary_sheet.dart';
import '../theme/app_colors.dart';

/// Lets the user choose between adding a past event or a monthly summary.
class AddPastRecordsSheet extends StatelessWidget {
  const AddPastRecordsSheet({super.key, this.month});

  final DateTime? month;

  static Future<void> show(BuildContext context, {DateTime? month}) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => AddPastRecordsSheet(month: month),
    );
  }

  Future<void> _choose(
    BuildContext context,
    Future<void> Function(BuildContext) open,
  ) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    Navigator.of(context).pop();
    await open(rootContext);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121622) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: context.cardBorder),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: context.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Past Records',
                    style: GoogleFonts.plusJakartaSans(
                      color: context.textMain,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: context.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Text(
              'Choose what you want to add',
              style: TextStyle(color: context.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _OptionTile(
              icon: Icons.event_note_rounded,
              title: 'Add Past Event',
              subtitle:
                  'Add a previous shoot with full details (client, date, payments, expenses)',
              onTap: () => _choose(
                context,
                (c) => AddPastEventSheet.show(c, initialMonth: month),
              ),
            ),
            const SizedBox(height: 12),
            _OptionTile(
              icon: Icons.bar_chart_rounded,
              title: 'Add Monthly Summary',
              subtitle:
                  'Enter total shoots, expenses and profit for a past month',
              onTap: () => _choose(
                context,
                (c) => AddMonthlySummarySheet.show(c, initialMonth: month),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.textMain,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: context.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.textMuted),
          ],
        ),
      ),
    );
  }
}
