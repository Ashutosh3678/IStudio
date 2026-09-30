import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class StudioLogo extends StatelessWidget {
  const StudioLogo({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 64.0 : 80.0;

    return Semantics(
      header: true,
      label: 'Clients Hub',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glowing Aperture Icon
          Hero(
            tag: 'studio-mark',
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF080C16),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                    blurRadius: 28,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                    blurRadius: 36,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  width: size * 0.58,
                  height: size * 0.58,
                  child: CustomPaint(
                    painter: _AperturePainter(
                      color: const Color(0xFFE0F2FE),
                      glowColor: const Color(0xFF38BDF8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: compact ? 12 : 18),

          // CLIENTS with Metallic Sheen and Sparkle
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Colors.white,
                    Color(0xFFF1F5F9),
                    Color(0xFFE2E8F0),
                    Color(0xFFDDD6FE),
                    Color(0xFFC4B5FD),
                  ],
                  stops: [0.0, 0.35, 0.65, 0.85, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'CLIENTS',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: compact ? 34 : 44,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.5,
                  ),
                ),
              ),
              // Sparkle on the 'S'
              Positioned(
                top: compact ? -2 : -4,
                right: compact ? -10 : -14,
                child: Text(
                  '✦',
                  style: TextStyle(
                    color: const Color(0xFFDDD6FE),
                    fontSize: compact ? 14 : 18,
                    shadows: const [
                      Shadow(
                        color: Color(0xFF818CF8),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // —  H U B  —
          SizedBox(height: compact ? 4 : 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.35),
                          Colors.white.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'H U B',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: compact ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 6,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.7),
                          Colors.white.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // STUDIO OS Pill
          SizedBox(height: compact ? 8 : 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3.5),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFF818CF8).withValues(alpha: 0.55),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              'STUDIO OS',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF818CF8),
                fontSize: compact ? 9.5 : 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.2,
              ),
            ),
          ),

          // PEOPLE • EVENTS • STORIES
          SizedBox(height: compact ? 8 : 12),
          Text(
            'PEOPLE   •   EVENTS   •   STORIES',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF94A3B8),
              fontSize: compact ? 8.5 : 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the camera aperture shutter blades
class _AperturePainter extends CustomPainter {
  _AperturePainter({required this.color, required this.glowColor});

  final Color color;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const bladeCount = 6;
    final innerRadius = radius * 0.32;

    final bladePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    for (int i = 0; i < bladeCount; i++) {
      final angle = (i * 2 * math.pi) / bladeCount;
      final nextAngle = ((i + 1) * 2 * math.pi) / bladeCount;

      final p1 = Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      final p2 = Offset(math.cos(nextAngle) * radius, math.sin(nextAngle) * radius);
      final p3 = Offset(math.cos(angle + 0.5) * innerRadius, math.sin(angle + 0.5) * innerRadius);

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..close();

      canvas.drawPath(path, bladePaint);
      canvas.drawPath(path, linePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AperturePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.glowColor != glowColor;
}
