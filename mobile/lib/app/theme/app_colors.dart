import 'package:flutter/material.dart';

/// Universal Color Hunt palette for Lumen Studio.
/// https://colorhunt.co/palette/e23e5788304e522546311d3f
@immutable
class AppColors {
  const AppColors._();

  static const Color blossom = Color(0xFFE23E57);
  static const Color merlot = Color(0xFF88304E);
  static const Color plum = Color(0xFF522546);
  static const Color midnight = Color(0xFF311D3F);

  static const Color ivory = Color(0xFFF7E8EC);
  static const Color blush = Color(0xFFC9A0AE);
  static const Color mist = Color(0x99F7E8EC);
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
  });

  final Color blossom;
  final Color merlot;
  final Color plum;
  final Color midnight;
  final Color ivory;
  final Color blush;
  final Color mist;

  static const StudioColors brand = StudioColors(
    blossom: AppColors.blossom,
    merlot: AppColors.merlot,
    plum: AppColors.plum,
    midnight: AppColors.midnight,
    ivory: AppColors.ivory,
    blush: AppColors.blush,
    mist: AppColors.mist,
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
  }) {
    return StudioColors(
      blossom: blossom ?? this.blossom,
      merlot: merlot ?? this.merlot,
      plum: plum ?? this.plum,
      midnight: midnight ?? this.midnight,
      ivory: ivory ?? this.ivory,
      blush: blush ?? this.blush,
      mist: mist ?? this.mist,
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
    );
  }
}
