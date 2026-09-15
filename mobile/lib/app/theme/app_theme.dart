import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.aqua,
      onPrimary: AppColors.ink,
      secondary: AppColors.slate,
      onSecondary: AppColors.paper,
      tertiary: AppColors.navy,
      onTertiary: AppColors.paper,
      error: Color(0xFFFF7A8A),
      onError: AppColors.ink,
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
      cardTheme: CardThemeData(
        color: AppColors.navy.withValues(alpha: 0.78),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.slate.withValues(alpha: 0.45),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.navy,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: display.titleMedium?.copyWith(
          color: AppColors.paper,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: body.bodyMedium?.copyWith(color: AppColors.muted),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.navy,
        modalBackgroundColor: AppColors.navy,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.slate.withValues(alpha: 0.3),
        selectedColor: AppColors.aqua.withValues(alpha: 0.22),
        disabledColor: AppColors.slate.withValues(alpha: 0.15),
        labelStyle: body.bodySmall?.copyWith(color: AppColors.paper),
        secondaryLabelStyle: body.bodySmall?.copyWith(color: AppColors.aqua),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.slate.withValues(alpha: 0.4)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.slate.withValues(alpha: 0.3),
        thickness: 1,
        space: 24,
      ),
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
          backgroundColor: AppColors.aqua,
          foregroundColor: AppColors.ink,
          disabledBackgroundColor: AppColors.slate.withValues(alpha: 0.4),
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
          foregroundColor: AppColors.aqua,
          textStyle: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.plum.withValues(alpha: 0.55),
        hintStyle: body.bodyMedium?.copyWith(color: AppColors.blush),
        labelStyle: body.bodyMedium?.copyWith(color: AppColors.blush),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
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
          borderSide: const BorderSide(color: AppColors.aqua, width: 1.6),
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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.navy,
        indicatorColor: AppColors.aqua.withValues(alpha: 0.22),
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return body.labelMedium?.copyWith(
            color: selected ? AppColors.aqua : AppColors.muted,
            fontWeight: FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.aqua : AppColors.muted,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.plum,
        contentTextStyle: body.bodyMedium?.copyWith(color: AppColors.ivory),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: Colors.white,
      secondary: AppColors.slate,
      onSecondary: Colors.white,
      tertiary: Color(0xFF0F172A),
      onTertiary: Colors.white,
      error: Color(0xFFE11D48),
      onError: Colors.white,
      surface: AppColors.lightCard,
      onSurface: AppColors.lightTextMain,
      surfaceContainerHighest: AppColors.lightInputFill,
      onSurfaceVariant: AppColors.lightTextMuted,
      outline: AppColors.lightBorder,
      outlineVariant: Color(0xFFCBD5E1),
      shadow: Color(0x0F000000),
      scrim: Color(0x33000000),
      inverseSurface: AppColors.lightTextMain,
      onInverseSurface: Colors.white,
      inversePrimary: AppColors.lightPrimary,
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
          bodyColor: AppColors.lightTextMain,
          displayColor: AppColors.lightTextMain,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightScaffold,
      canvasColor: AppColors.lightScaffold,
      textTheme: textTheme,
      extensions: const [StudioColors.lightBrand],
      splashFactory: InkRipple.splashFactory,
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightCard,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: display.titleMedium?.copyWith(
          color: AppColors.lightTextMain,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: body.bodyMedium?.copyWith(color: AppColors.lightTextMuted),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightCard,
        modalBackgroundColor: AppColors.lightCard,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightInputFill,
        selectedColor: AppColors.lightPrimary.withValues(alpha: 0.16),
        disabledColor: AppColors.lightBorder,
        labelStyle: body.bodySmall?.copyWith(color: AppColors.lightTextMain),
        secondaryLabelStyle: body.bodySmall?.copyWith(color: AppColors.lightPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 24,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightTextMain,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: display.titleLarge?.copyWith(
          color: AppColors.lightTextMain,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.lightBorder,
          disabledForegroundColor: AppColors.lightTextMuted,
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
          foregroundColor: AppColors.lightPrimary,
          textStyle: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightInputFill,
        hintStyle: body.bodyMedium?.copyWith(color: AppColors.lightTextMuted),
        labelStyle: body.bodyMedium?.copyWith(color: AppColors.lightTextMuted),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightCard,
        indicatorColor: AppColors.lightPrimary.withValues(alpha: 0.16),
        elevation: 1,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return body.labelMedium?.copyWith(
            color: selected ? AppColors.lightPrimary : AppColors.lightTextMuted,
            fontWeight: FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.lightPrimary : AppColors.lightTextMuted,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightTextMain,
        contentTextStyle: body.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
