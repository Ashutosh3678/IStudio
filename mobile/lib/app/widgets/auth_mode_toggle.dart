import 'package:flutter/material.dart';

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
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: context.innerBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.cardBorder),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = (constraints.maxWidth - 4) / 2;
            return Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  alignment: isLogin
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    width: tabWidth,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [AppColors.aqua, AppColors.slate]
                            : const [AppColors.lightPrimary, Color(0xFF0F766E)],
                      ),
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
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: selected
                    ? (context.isDark ? AppColors.paper : Colors.white)
                    : context.textMuted,
                fontWeight: FontWeight.w600,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
