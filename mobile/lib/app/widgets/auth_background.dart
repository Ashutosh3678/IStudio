import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  AppColors.ink,
                  AppColors.navy,
                  AppColors.slate,
                  AppColors.ink,
                ]
              : const [
                  Color(0xFFF8FAFC),
                  Color(0xFFEFF6FF),
                  Color(0xFFF1F5F9),
                  Color(0xFFF8FAFC),
                ],
          stops: const [0.0, 0.38, 0.72, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _GlowOrb(
              size: 240,
              color: isDark ? AppColors.blossom : AppColors.lightPrimary,
            ),
          ),
          Positioned(
            bottom: 40,
            left: -70,
            child: _GlowOrb(
              size: 220,
              color: isDark ? AppColors.merlot : const Color(0xFFCBD5E1),
            ),
          ),
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: _AperturePainter(isDark: isDark)),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.22),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _AperturePainter extends CustomPainter {
  const _AperturePainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.82, size.height * 0.16);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = (isDark ? AppColors.blossom : AppColors.lightPrimary)
          .withValues(alpha: 0.12);

    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(center, 28.0 + (i * 18), paint);
    }

    final lower = Offset(size.width * 0.12, size.height * 0.78);
    paint.color = (isDark ? AppColors.merlot : AppColors.lightBorder)
        .withValues(alpha: 0.16);
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(lower, 18.0 + (i * 16), paint);
    }

    final spoke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = (isDark ? AppColors.ivory : AppColors.lightTextMain)
          .withValues(alpha: 0.05);

    for (var i = 0; i < 8; i++) {
      final angle = (math.pi / 4) * i;
      canvas.drawLine(
        center,
        Offset(
          center.dx + math.cos(angle) * 98,
          center.dy + math.sin(angle) * 98,
        ),
        spoke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AperturePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
