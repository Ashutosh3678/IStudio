import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_motion.dart';

class StudioButton extends StatefulWidget {
  const StudioButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.showArrow = true,
    this.height = 54.0,
    this.isSecondary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool showArrow;
  final double height;
  final bool isSecondary;

  @override
  State<StudioButton> createState() => _StudioButtonState();
}

class _StudioButtonState extends State<StudioButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final animationsDisabled = AppMotion.areAnimationsDisabled(context);
    final radius = BorderRadius.circular(999);

    final decoration = widget.isSecondary
        ? BoxDecoration(
            borderRadius: radius,
            color: const Color(0xFF0F172A).withValues(alpha: 0.8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          )
        : BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF00E5FF),
                Color(0xFF38BDF8),
                Color(0xFF818CF8),
                Color(0xFFA855F7),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.45),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(-4, 6),
              ),
              BoxShadow(
                color: const Color(0xFFA855F7).withValues(alpha: 0.4),
                blurRadius: 22,
                offset: const Offset(4, 6),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: RepaintBoundary(
        child: GestureDetector(
          onTapDown: enabled
              ? (_) {
                  HapticFeedback.lightImpact();
                  setState(() => _pressed = true);
                }
              : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: () => setState(() => _pressed = false),
          onTap: enabled ? widget.onPressed : null,
          child: AnimatedScale(
            scale: (animationsDisabled || !_pressed) ? 1.0 : 0.96,
            duration: AppMotion.fast,
            curve: AppMotion.spring,
            child: AnimatedOpacity(
              duration: AppMotion.fast,
              opacity: enabled ? 1.0 : 0.55,
              child: Container(
                width: double.infinity,
                height: widget.height,
                decoration: decoration,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Top Glint Highlight
                    if (!widget.isSecondary)
                      Positioned(
                        top: 0,
                        left: 24,
                        right: 24,
                        height: 1.2,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.7),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Centered Text / Loading Indicator
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: widget.isLoading
                          ? const SizedBox(
                              key: ValueKey('btn_loading'),
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              key: const ValueKey('btn_content'),
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(widget.icon,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  widget.label,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                    ),

                    // Right-aligned Circular Arrow Icon
                    if (!widget.isSecondary &&
                        widget.showArrow &&
                        !widget.isLoading)
                      Positioned(
                        right: 0,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
