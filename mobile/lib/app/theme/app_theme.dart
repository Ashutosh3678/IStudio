import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.blossom,
      onPrimary: AppColors.ivory,
      secondary: AppColors.merlot,
      onSecondary: AppColors.ivory,
      tertiary: AppColors.plum,
      onTertiary: AppColors.ivory,
      error: Color(0xFFFF6B81),
      onError: AppColors.ivory,
      surface: AppColors.midnight,
      onSurface: AppColors.ivory,
      surfaceContainerHighest: AppColors.plum,
      onSurfaceVariant: AppColors.blush,
      outline: AppColors.merlot,
      outlineVariant: Color(0x6688304E),
      shadow: Color(0xCC000000),
      scrim: Color(0x99000000),
      inverseSurface: AppColors.ivory,
      onInverseSurface: AppColors.midnight,
      inversePrimary: AppColors.merlot,
    );

    final display = GoogleFonts.playfairDisplayTextTheme();
    final body = GoogleFonts.dmSansTextTheme();

    final textTheme = body
        .copyWith(
          displayLarge: display.displayLarge,
          displayMedium: display.displayMedium,
          displaySmall: display.displaySmall,
          headlineLarge: display.headlineLarge,
          headlineMedium: display.headlineMedium,
          headlineSmall: display.headlineSmall,
          titleLarge: display.titleLarge,
        )
        .apply(
          bodyColor: AppColors.ivory,
          displayColor: AppColors.ivory,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.midnight,
      canvasColor: AppColors.midnight,
      textTheme: textTheme,
      extensions: const [StudioColors.brand],
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ivory,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: display.titleLarge?.copyWith(
          color: AppColors.ivory,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blossom,
          foregroundColor: AppColors.ivory,
          disabledBackgroundColor: AppColors.merlot.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.mist,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: body.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blossom,
          textStyle: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.plum.withValues(alpha: 0.55),
        hintStyle: body.bodyMedium?.copyWith(color: AppColors.blush),
        labelStyle: body.bodyMedium?.copyWith(color: AppColors.blush),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.merlot.withValues(alpha: 0.45),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.merlot.withValues(alpha: 0.45),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.blossom, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF6B81), width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF6B81), width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.plum,
        contentTextStyle: body.bodyMedium?.copyWith(color: AppColors.ivory),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
