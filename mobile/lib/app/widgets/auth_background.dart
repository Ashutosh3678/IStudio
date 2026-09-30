import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Adaptive studio background with dark cinematic mode and bright airy light mode
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Stack(
      children: [
        // Base Canvas
        Positioned.fill(
          child: ColoredBox(
            color: isDark ? AppColors.darkBg1 : Colors.white,
          ),
        ),

        // Background Image (Camera Lens & Studio Setting)
        Positioned.fill(
          child: Opacity(
            opacity: isDark ? 0.90 : 0.92,
            child: Image.asset(
              isDark
                  ? 'assets/images/auth_bg_dark.jpg'
                  : 'assets/images/auth_bg_light.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topRight,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ),

        // Ambient Cyan/Blue Glow (Bottom-Left)
        Positioned(
          bottom: -60,
          left: -40,
          width: 320,
          height: 320,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF00E5FF).withValues(alpha: 0.18),
                          const Color(0xFF38BDF8).withValues(alpha: 0.10),
                          Colors.transparent,
                        ]
                      : [
                          const Color(0xFF38BDF8).withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                ),
              ),
            ),
          ),
        ),

        // Ambient Purple/Violet Glow (Top-Right behind lens)
        Positioned(
          top: -30,
          right: -30,
          width: 320,
          height: 320,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF8B5CF6).withValues(alpha: 0.22),
                          const Color(0xFF6366F1).withValues(alpha: 0.10),
                          Colors.transparent,
                        ]
                      : [
                          const Color(0xFFA855F7).withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                ),
              ),
            ),
          ),
        ),

        // Soft Vignette for dark mode text contrast
        if (isDark)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.darkBg1.withValues(alpha: 0.35),
                      Colors.transparent,
                      AppColors.darkBg1.withValues(alpha: 0.55),
                    ],
                    stops: const [0.0, 0.40, 1.0],
                  ),
                ),
              ),
            ),
          ),

        // Main content
        Positioned.fill(child: child),
      ],
    );
  }
}
