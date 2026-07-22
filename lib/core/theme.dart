import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralised palette, gradients, typography and spacing tokens
/// for the CareerCraft Pro premium UI.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF3F51B5);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentOrange = Color(0xFFFFA726);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFFF5252);

  static const Color splashTop = Color(0xFF0A0E1A);
  static const Color splashMid = Color(0xFF1A1A3E);
  static const Color splashBottom = Color(0xFF2D1B69);

  static const Color cardDarkTop = Color(0xFF1A237E);
  static const Color cardDarkBottom = Color(0xFF0D1442);

  static const Color surface = Color(0xFFF5F7FA);
  static const Color surfaceAlt = Color(0xFFFAFAFC);
  static const Color background = Color(0xFFF6F7FB);
  static const Color border = Color(0xFFE5E8EF);
  static const Color textPrimary = Color(0xFF1F2330);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
}

class AppGradients {
  AppGradients._();

  static const Gradient splash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.splashTop,
      AppColors.splashMid,
      AppColors.splashBottom,
    ],
  );

  static const Gradient header = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  static const Gradient statsCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.cardDarkTop, AppColors.cardDarkBottom],
  );

  static const Gradient dailyChallenge = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accent, AppColors.accentOrange],
  );

  static const Gradient recommendation = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  static const Gradient successResult = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.success, Color(0xFF2E7D32)],
  );

  static const Gradient failureResult = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.error, Color(0xFFC62828)],
  );
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppRadius {
  AppRadius._();

  static const double sm = 10;
  static const double md = 15;
  static const double lg = 20;
  static const double xl = 30;
}

class AppDuration {
  AppDuration._();

  static const Duration micro = Duration(milliseconds: 200);
  static const Duration fast = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 450);
  static const Duration normal = Duration(milliseconds: 500);
  static const Duration slow = Duration(seconds: 2);
}

class AppText {
  AppText._();

  static TextStyle headline(double size, {FontWeight weight = FontWeight.bold, Color color = AppColors.textPrimary}) =>
      GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color);

  static TextStyle body(double size, {FontWeight weight = FontWeight.normal, Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);

  static TextStyle button(double size, {FontWeight weight = FontWeight.w600}) =>
      GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: Colors.white);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.background,
    brightness: Brightness.light,
  );

  return base.copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppText.headline(18, weight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: AppText.button(15),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        textStyle: AppText.button(15),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintStyle: AppText.body(14, color: AppColors.textMuted),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      labelStyle: AppText.body(13),
      secondaryLabelStyle: AppText.body(13, weight: FontWeight.w600, color: AppColors.primary),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: const BorderSide(color: AppColors.border)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
  );
}
