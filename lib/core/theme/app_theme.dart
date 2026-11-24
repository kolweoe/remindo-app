import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Remindo Pixel RPG Design System tokens (Warm Wood & Parchment Theme)
/// Sourced exactly from `design_reference/DESIGN.md` & `tailwind.config.js`
class AppColors {
  // Primary (Warm Wood Brown)
  static const Color primary = Color(0xFF7A4B2A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFF9B98F);
  static const Color onPrimaryContainer = Color(0xFF311300);

  // Secondary (Forest Green / RPG Quest Success)
  static const Color secondary = Color(0xFF2E7D32);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFC8FFBF);
  static const Color onSecondaryContainer = Color(0xFF002204);

  // Accent (Warm Amber Gold)
  static const Color accent = Color(0xFFF59E0B);
  static const Color onAccent = Color(0xFF311300);
  static const Color accentContainer = Color(0xFFFEF3C7);
  static const Color onAccentContainer = Color(0xFF4D2600);

  // Surfaces & Background (Warm Parchment & Wood HUD)
  static const Color surface = Color(0xFFF5E9D3); // Warm Parchment
  static const Color onSurface = Color(0xFF2C160B); // Deep Wood Text
  static const Color surfaceContainerLow = Color(0xFFFFF8EB); // Light Cream Parchment
  static const Color onSurfaceContainerLow = Color(0xFF2C160B);
  static const Color surfaceContainer = Color(0xFFEFE0C6); // Medium Parchment
  static const Color onSurfaceContainer = Color(0xFF2C160B);
  static const Color surfaceContainerHigh = Color(0xFFE2C89E); // High Parchment
  static const Color onSurfaceContainerHigh = Color(0xFF2C160B);
  static const Color surfaceNav = Color(0xFF4E2F1B); // Dark Wood HUD & Nav
  static const Color onSurfaceNav = Color(0xFFFFFFFF);

  // Outline / Borders (Dark Wood)
  static const Color outline = Color(0xFF4E2F1B);
  static const Color outlineVariant = Color(0xFFC9A679);

  // Semantic Status
  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFD97706);
  static const Color onWarning = Color(0xFF2A2A2A);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
}

class AppTypography {
  // Headings & Ribbons (Boogaloo)
  static TextStyle displayLg = GoogleFonts.boogaloo(
    fontSize: 44,
    fontWeight: FontWeight.w400,
    height: 48 / 44,
    color: AppColors.onSurface,
  );

  static TextStyle displayLgMobile = GoogleFonts.boogaloo(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 36 / 32,
    color: AppColors.onSurface,
  );

  static TextStyle headlineLg = GoogleFonts.boogaloo(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 34 / 28,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMd = GoogleFonts.boogaloo(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 28 / 22,
    color: AppColors.onSurface,
  );

  // Body & Labels (Capriola)
  static TextStyle titleMd = GoogleFonts.capriola(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 22 / 16,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMd = GoogleFonts.capriola(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.onSurface,
  );

  static TextStyle labelLg = GoogleFonts.capriola(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    letterSpacing: 0.1,
    color: AppColors.onSurface,
  );

  static TextStyle labelSm = GoogleFonts.capriola(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 14 / 11,
    letterSpacing: 0.2,
    color: AppColors.onSurface,
  );

  // Tabular Numbers, XP, Coins & Currency (Spline Sans Mono)
  static TextStyle monoLg = GoogleFonts.splineSansMono(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 24 / 20,
    letterSpacing: -0.2,
    color: AppColors.onSurface,
  );

  static TextStyle monoSm = GoogleFonts.splineSansMono(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    color: AppColors.onSurface,
  );
}

class AppSpacing {
  static const double unitXs = 4.0;
  static const double unitSm = 8.0;
  static const double unitMd = 12.0;
  static const double unitLg = 16.0;
  static const double unitXl = 24.0;
  static const double pageMargin = 16.0;
  static const double navHeight = 72.0;
}

class AppRadius {
  // Pixelated Sharp / 0–4px Rounded Corners
  static const double sm = 0.0;
  static const double standard = 2.0;
  static const double md = 2.0;
  static const double lg = 4.0;
  static const double xl = 4.0;
  static const double full = 9999.0;

  static BorderRadius get radiusSm => BorderRadius.circular(sm);
  static BorderRadius get radiusStandard => BorderRadius.circular(standard);
  static BorderRadius get radiusMd => BorderRadius.circular(md);
  static BorderRadius get radiusLg => BorderRadius.circular(lg);
  static BorderRadius get radiusXl => BorderRadius.circular(xl);
  static BorderRadius get radiusFull => BorderRadius.circular(full);
}

class AppShadows {
  // Stepped Pixel RPG Shadows with Dark Wood Outline
  static const BoxShadow pixel = BoxShadow(
    color: AppColors.outline,
    offset: Offset(0, 3),
    blurRadius: 0,
  );

  static const BoxShadow pixelSm = BoxShadow(
    color: AppColors.outline,
    offset: Offset(0, 2),
    blurRadius: 0,
  );

  static const BoxShadow pixelLg = BoxShadow(
    color: AppColors.outline,
    offset: Offset(0, 4),
    blurRadius: 0,
  );

  static const BoxShadow pixelCard = BoxShadow(
    color: Color(0x474E2F1B),
    offset: Offset(0, 4),
    blurRadius: 0,
  );

  static const BoxShadow card = BoxShadow(
    color: Color(0x2E4E2F1B),
    offset: Offset(0, 3),
    blurRadius: 0,
  );
}

class AppBorders {
  static const double width = 2.0;
  static Border get pixel => Border.all(color: AppColors.outline, width: width);
  static Border get top => const Border(top: BorderSide(color: AppColors.outline, width: width));
  static Border get bottom => const Border(bottom: BorderSide(color: AppColors.outline, width: width));
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.surface,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        surface: AppColors.surfaceContainerLow,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
        onError: AppColors.onError,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceNav,
        foregroundColor: AppColors.onSurfaceNav,
        elevation: 0,
      ),
      useMaterial3: true,
    );
  }
}
