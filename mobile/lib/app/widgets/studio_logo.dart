import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class StudioLogo extends StatelessWidget {
  const StudioLogo({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 52.0 : 78.0;
    final isDark = context.isDark;
    final accent = context.accentColor;
    final textMain = context.textMain;
    final textMuted = context.textMuted;

    return Semantics(
      header: true,
      label: 'Lumen Studio',
      child: Column(
        children: [
          Hero(
            tag: 'lumen-mark',
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [AppColors.blossom, AppColors.merlot]
                      : const [AppColors.lightPrimary, Color(0xFF0F766E)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 22,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: isDark ? AppColors.ivory : Colors.white,
                size: compact ? 24 : 34,
              ),
            ),
          ),
          SizedBox(height: compact ? 12 : 18),
          Text(
            'LUMEN',
            style: GoogleFonts.playfairDisplay(
              color: textMain,
              fontSize: compact ? 28 : 38,
              fontWeight: FontWeight.w600,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Every frame, a story.',
            style: GoogleFonts.dmSans(
              color: textMuted,
              fontSize: compact ? 13 : 15,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
