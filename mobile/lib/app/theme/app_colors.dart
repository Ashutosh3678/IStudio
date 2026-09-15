import 'package:flutter/material.dart';

import '../models/studio_event.dart';

/// Universal studio palette supporting Dark and Light themes
@immutable
class AppColors {
  const AppColors._();

  // Dark Theme Palette
  static const Color ink = Color(0xFF0B1320);
  static const Color navy = Color(0xFF1C2541);
  static const Color slate = Color(0xFF3A506B);
  static const Color aqua = Color(0xFF5BC0BE);
  static const Color paper = Color(0xFFF4F7F5);
  static const Color muted = Color(0xFF9BB0C4);
  static const Color mist = Color(0x99F4F7F5);

  // Light Theme Palette
  static const Color lightScaffold = Color(0xFFF6F8FB);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextMain = Color(0xFF0F172A);
  static const Color lightTextMuted = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightInputFill = Color(0xFFF1F5F9);
  static const Color lightPrimary = Color(0xFF0D9488);

  static const Color midnight = ink;
  static const Color plum = navy;
  static const Color merlot = slate;
  static const Color blossom = aqua;
  static const Color ivory = paper;
  static const Color blush = muted;

  // Helper resolvers for dynamic theme styling
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color scaffoldBackground(BuildContext context) =>
      isDark(context) ? ink : lightScaffold;

  static Color cardBackground(BuildContext context) =>
      isDark(context) ? navy.withValues(alpha: 0.78) : lightCard;

  static Color cardBorder(BuildContext context) =>
      isDark(context) ? slate.withValues(alpha: 0.45) : lightBorder;

  static Color textMain(BuildContext context) =>
      isDark(context) ? paper : lightTextMain;

  static Color textMuted(BuildContext context) =>
      isDark(context) ? muted : lightTextMuted;

  static Color inputBackground(BuildContext context) =>
      isDark(context) ? navy.withValues(alpha: 0.55) : lightInputFill;

  static Color innerContainerBackground(BuildContext context) =>
      isDark(context) ? ink.withValues(alpha: 0.55) : const Color(0xFFF1F5F9);

  static Color accent(BuildContext context) =>
      isDark(context) ? aqua : lightPrimary;

  static Color expense(BuildContext context) =>
      isDark(context) ? const Color(0xFFFF7A8A) : const Color(0xFFE11D48);

  static Color profit(BuildContext context) =>
      isDark(context) ? aqua : lightPrimary;

  static Color statusColor(BuildContext context, EventStatus status) {
    final dark = isDark(context);
    switch (status) {
      case EventStatus.completed:
        return dark ? aqua : const Color(0xFF0D9488);
      case EventStatus.inProgress:
        return dark ? const Color(0xFF64B5F6) : const Color(0xFF0284C7);
      case EventStatus.paymentDue:
        return dark ? const Color(0xFFE8B86D) : const Color(0xFFD97706);
      case EventStatus.upcoming:
        return dark ? const Color(0xFF81C784) : const Color(0xFF16A34A);
      case EventStatus.cancelled:
        return dark ? const Color(0xFFFF7A8A) : const Color(0xFFDC2626);
    }
  }
}

@immutable
class StudioColors extends ThemeExtension<StudioColors> {
  const StudioColors({
    required this.blossom,
    required this.merlot,
    required this.plum,
    required this.midnight,
    required this.ivory,
    required this.blush,
    required this.mist,
    required this.cardBg,
    required this.cardBorder,
    required this.textMain,
    required this.textMuted,
    required this.innerContainerBg,
  });

  final Color blossom;
  final Color merlot;
  final Color plum;
  final Color midnight;
  final Color ivory;
  final Color blush;
  final Color mist;
  final Color cardBg;
  final Color cardBorder;
  final Color textMain;
  final Color textMuted;
  final Color innerContainerBg;

  static const StudioColors brand = StudioColors(
    blossom: AppColors.aqua,
    merlot: AppColors.slate,
    plum: AppColors.navy,
    midnight: AppColors.ink,
    ivory: AppColors.paper,
    blush: AppColors.muted,
    mist: AppColors.mist,
    cardBg: Color(0xC71C2541),
    cardBorder: Color(0x733A506B),
    textMain: AppColors.paper,
    textMuted: AppColors.muted,
    innerContainerBg: Color(0x8C0B1320),
  );

  static const StudioColors lightBrand = StudioColors(
    blossom: AppColors.lightPrimary,
    merlot: AppColors.lightBorder,
    plum: AppColors.lightInputFill,
    midnight: AppColors.lightTextMain,
    ivory: AppColors.lightTextMain,
    blush: AppColors.lightTextMuted,
    mist: Color(0x6664748B),
    cardBg: AppColors.lightCard,
    cardBorder: AppColors.lightBorder,
    textMain: AppColors.lightTextMain,
    textMuted: AppColors.lightTextMuted,
    innerContainerBg: Color(0xFFF1F5F9),
  );

  @override
  StudioColors copyWith({
    Color? blossom,
    Color? merlot,
    Color? plum,
    Color? midnight,
    Color? ivory,
    Color? blush,
    Color? mist,
    Color? cardBg,
    Color? cardBorder,
    Color? textMain,
    Color? textMuted,
    Color? innerContainerBg,
  }) {
    return StudioColors(
      blossom: blossom ?? this.blossom,
      merlot: merlot ?? this.merlot,
      plum: plum ?? this.plum,
      midnight: midnight ?? this.midnight,
      ivory: ivory ?? this.ivory,
      blush: blush ?? this.blush,
      mist: mist ?? this.mist,
      cardBg: cardBg ?? this.cardBg,
      cardBorder: cardBorder ?? this.cardBorder,
      textMain: textMain ?? this.textMain,
      textMuted: textMuted ?? this.textMuted,
      innerContainerBg: innerContainerBg ?? this.innerContainerBg,
    );
  }

  @override
  StudioColors lerp(ThemeExtension<StudioColors>? other, double t) {
    if (other is! StudioColors) return this;
    return StudioColors(
      blossom: Color.lerp(blossom, other.blossom, t)!,
      merlot: Color.lerp(merlot, other.merlot, t)!,
      plum: Color.lerp(plum, other.plum, t)!,
      midnight: Color.lerp(midnight, other.midnight, t)!,
      ivory: Color.lerp(ivory, other.ivory, t)!,
      blush: Color.lerp(blush, other.blush, t)!,
      mist: Color.lerp(mist, other.mist, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      textMain: Color.lerp(textMain, other.textMain, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      innerContainerBg: Color.lerp(innerContainerBg, other.innerContainerBg, t)!,
    );
  }
}

extension StudioThemeX on BuildContext {
  bool get isDark => AppColors.isDark(this);
  StudioColors get studioColors =>
      Theme.of(this).extension<StudioColors>() ?? StudioColors.brand;
  Color get cardBg => AppColors.cardBackground(this);
  Color get cardBorder => AppColors.cardBorder(this);
  Color get textMain => AppColors.textMain(this);
  Color get textMuted => AppColors.textMuted(this);
  Color get accentColor => AppColors.accent(this);
  Color get innerBg => AppColors.innerContainerBackground(this);
  Color get scaffoldBg => AppColors.scaffoldBackground(this);
}
