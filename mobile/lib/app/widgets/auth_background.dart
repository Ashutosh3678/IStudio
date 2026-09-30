import 'package:flutter/material.dart';

/// Cinematic camera studio background with dark atmosphere and blue/purple ambient glows
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Canvas
        const Positioned.fill(
          child: ColoredBox(color: Color(0xFF060913)),
        ),

        // Background Image (Camera Lens & Studio Setting)
        Positioned.fill(
          child: Opacity(
            opacity: 0.45,
            child: Image.asset(
              'assets/images/auth_bg.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topRight,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ),

        // Ambient Cyan Glow (Bottom-Left)
        Positioned(
          bottom: -80,
          left: -60,
          width: 360,
          height: 360,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withValues(alpha: 0.22),
                    const Color(0xFF06B6D4).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Ambient Purple/Indigo Glow (Top-Right)
        Positioned(
          top: -40,
          right: -40,
          width: 340,
          height: 340,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.25),
                    const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Subtle Vignette Overlay
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF060913).withValues(alpha: 0.55),
                    Colors.transparent,
                    const Color(0xFF060913).withValues(alpha: 0.75),
                  ],
                  stops: const [0.0, 0.45, 1.0],
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
