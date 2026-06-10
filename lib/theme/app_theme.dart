import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta do BairroMatch — modo claro (coral + Plus Jakarta Sans).
class AppColors {
  static const coral = Color(0xFFE87A6F);
  static const coralLight = Color(0xFFFADDD9);
  static const coralDark = Color(0xFFD4503F);

  static const background = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF151A22);
  static const muted = Color(0xFFF2F3F5);
  static const mutedForeground = Color(0xFF7B8494);
  static const border = Color(0xFFE6E8EC);
  static const secondary = Color(0xFFF2F3F5);
  static const surfaceElevated = Color(0xFFFFFFFF);

  static const success = Color(0xFF33CC85);
  static const warning = Color(0xFFF5B341);
  static const destructive = Color(0xFFEF4444);
}

/// Paleta do BairroMatch — modo escuro.
class AppColorsDark {
  static const coral = Color(0xFFE87A6F);
  static const coralLight = Color(0xFF3D1E1A);
  static const coralDark = Color(0xFFD4503F);

  static const background = Color(0xFF0F1218);
  static const foreground = Color(0xFFF0F1F3);
  static const muted = Color(0xFF1C2333);
  static const mutedForeground = Color(0xFF8896AA);
  static const border = Color(0xFF2C3545);
  static const secondary = Color(0xFF1C2333);
  static const surfaceElevated = Color(0xFF222C3A);

  static const success = Color(0xFF33CC85);
  static const warning = Color(0xFFF5B341);
  static const destructive = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.foreground, displayColor: AppColors.foreground);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.coral,
        onPrimary: Colors.white,
        secondary: AppColors.coral,
        onSecondary: Colors.white,
        surface: AppColors.background,
        onSurface: AppColors.foreground,
        error: AppColors.destructive,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.coral, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: AppColors.mutedForeground.withValues(alpha: 0.7)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.coral,
        inactiveTrackColor: AppColors.secondary,
        thumbColor: AppColors.coral,
        overlayColor: Color(0x33E87A6F),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
      bodyColor: AppColorsDark.foreground,
      displayColor: AppColorsDark.foreground,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColorsDark.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColorsDark.coral,
        onPrimary: Colors.white,
        secondary: AppColorsDark.coral,
        onSecondary: Colors.white,
        surface: AppColorsDark.surfaceElevated,
        onSurface: AppColorsDark.foreground,
        error: AppColorsDark.destructive,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsDark.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColorsDark.coral, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: AppColorsDark.mutedForeground.withValues(alpha: 0.7)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsDark.coral,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsDark.foreground,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColorsDark.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColorsDark.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColorsDark.border),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColorsDark.coral,
        inactiveTrackColor: AppColorsDark.secondary,
        thumbColor: AppColorsDark.coral,
        overlayColor: Color(0x33E87A6F),
      ),
    );
  }
}
