import 'package:flutter/material.dart';

/// Universal studio palette:
/// #0B1320, #1C2541, #3A506B, #5BC0BE, #F4F7F5
@immutable
class AppColors {
  const AppColors._();

  static const Color ink = Color(0xFF0B1320);
  static const Color navy = Color(0xFF1C2541);
  static const Color slate = Color(0xFF3A506B);
  static const Color aqua = Color(0xFF5BC0BE);
  static const Color paper = Color(0xFFF4F7F5);
  static const Color muted = Color(0xFF9BB0C4);
  static const Color mist = Color(0x99F4F7F5);

  static const Color midnight = ink;
  static const Color plum = navy;
  static const Color merlot = slate;
  static const Color blossom = aqua;
  static const Color ivory = paper;
  static const Color blush = muted;
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
    blossom: AppColors.aqua,
    merlot: AppColors.slate,
    plum: AppColors.navy,
    midnight: AppColors.ink,
    ivory: AppColors.paper,
    blush: AppColors.muted,
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
