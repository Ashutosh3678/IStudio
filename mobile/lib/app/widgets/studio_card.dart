import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StudioCard extends StatelessWidget {
  const StudioCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder(context)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.22)
                : const Color(0x0D0F172A),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: card,
      ),
    );
  }
}
