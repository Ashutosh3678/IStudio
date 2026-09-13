import 'package:flutter/material.dart';

import '../services/api_config.dart';
import '../theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.logoUrl,
    this.size = 44,
    this.heroTag = 'studio-logo',
  });

  final String? logoUrl;
  final double size;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final resolved = ApiConfig.resolveMedia(logoUrl);
    final image = resolved.isEmpty
        ? null
        : DecorationImage(image: NetworkImage(resolved), fit: BoxFit.cover);

    return Hero(
      tag: heroTag,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.aqua, AppColors.slate],
          ),
          image: image,
          boxShadow: [
            BoxShadow(
              color: AppColors.aqua.withValues(alpha: 0.28),
              blurRadius: 12,
            ),
          ],
        ),
        child: image == null
            ? Icon(
                Icons.camera_alt_rounded,
                color: AppColors.ink,
                size: size * 0.42,
              )
            : null,
      ),
    );
  }
}
