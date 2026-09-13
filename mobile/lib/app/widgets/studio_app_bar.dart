import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class StudioAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StudioAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 64 : 78);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.paper,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                ],
              ),
            ),
            ...?actions,
          ],
        ),
      ),
    );
  }
}
