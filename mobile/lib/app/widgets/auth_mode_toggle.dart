import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class AuthModeToggle extends StatelessWidget {
  const AuthModeToggle({
    super.key,
    required this.isLogin,
    required this.onChanged,
  });

  final bool isLogin;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Semantics(
      label: isLogin ? 'Sign in selected' : 'Sign up selected',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBg2.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.lightBorderColor,
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = (constraints.maxWidth - 4) / 2;
                return Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      alignment: isLogin
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        width: tabWidth,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: context.toggleGradient,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: isDark ? 0.35 : 0.25),
                            width: 1,
                          ),
                          boxShadow: isDark
                              ? [
                                  BoxShadow(
                                    color: AppColors.darkAccentIndigo.withValues(alpha: 0.45),
                                    blurRadius: 18,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: AppColors.lightAccentBlue.withValues(alpha: 0.28),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _Tab(
                          label: 'Sign in',
                          selected: isLogin,
                          onTap: () => onChanged(true),
                        ),
                        _Tab(
                          label: 'Sign up',
                          selected: !isLogin,
                          onTap: () => onChanged(false),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: SizedBox(
          height: 44,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.plusJakartaSans(
                color: selected
                    ? Colors.white
                    : (context.isDark ? const Color(0xFF94A3B8) : const Color(0xFF334155)),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
