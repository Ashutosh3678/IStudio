import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Reference-fidelity CLIENTS HUB branding artwork.
///
/// The logo, wordmark, swoosh, rules, pill, and tagline are kept together in
/// dedicated light and dark assets so their typography and alignment cannot
/// drift apart when the auth layout scales.
class StudioLogo extends StatelessWidget {
  const StudioLogo({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Semantics(
      header: true,
      label: 'Clients Hub',
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Scale with the available auth column instead of using one fixed
          // pixel size, so phones, tablets, and desktop-sized windows keep the
          // same visual proportion as the reference composition.
          final maxReferenceWidth = compact ? 560.0 : 680.0;
          final width = constraints.maxWidth.isFinite
              ? (constraints.maxWidth * 0.84)
                  .clamp(0.0, maxReferenceWidth)
                  .toDouble()
              : maxReferenceWidth;

          return Center(
            child: Image.asset(
              isDark
                  ? 'assets/images/clients_branding_dark.png'
                  : 'assets/images/clients_branding_light.png',
              width: width,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              semanticLabel: 'CLIENTS HUB Studio branding',
            ),
          );
        },
      ),
    );
  }
}
