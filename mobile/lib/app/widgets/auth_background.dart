import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.ink,
            AppColors.navy,
            AppColors.slate,
            AppColors.ink,
          ],
          stops: [0.0, 0.38, 0.72, 1.0],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -80,
            right: -60,
            child: _GlowOrb(size: 240, color: AppColors.blossom),
          ),
          const Positioned(
            bottom: 40,
            left: -70,
            child: _GlowOrb(size: 220, color: AppColors.merlot),
          ),
          const Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: _AperturePainter()),
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
  const _AperturePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.82, size.height * 0.16);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.blossom.withValues(alpha: 0.12);

    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(center, 28.0 + (i * 18), paint);
    }

    final lower = Offset(size.width * 0.12, size.height * 0.78);
    paint.color = AppColors.merlot.withValues(alpha: 0.16);
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(lower, 18.0 + (i * 16), paint);
    }

    final spoke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = AppColors.ivory.withValues(alpha: 0.05);

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
