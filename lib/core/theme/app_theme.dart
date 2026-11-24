import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Remindo Pixel RPG Design System tokens
/// Sourced exactly from `design_reference/DESIGN.md` & `tailwind.config.js`
class AppColors {
  // Primary (Royal Purple)
  static const Color primary = Color(0xFF6D3FA8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF8B5CF6);
  static const Color onPrimaryContainer = Color(0xFF0F0F0F);

  // Secondary (Rose Pink)
  static const Color secondary = Color(0xFFD9468F);
  static const Color onSecondary = Color(0xFF161616);
  static const Color secondaryContainer = Color(0xFFFCE7F3);
  static const Color onSecondaryContainer = Color(0xFF831843);

  // Accent (Golden Amber)
  static const Color accent = Color(0xFFF59E0B);
  static const Color onAccent = Color(0xFF2D1B4E);
  static const Color accentContainer = Color(0xFFFEF3C7);
  static const Color onAccentContainer = Color(0xFF78350F);

  // Surfaces & Background
  static const Color surface = Color(0xFFF3E8FF);
  static const Color onSurface = Color(0xFF2D1B4E);
  static const Color surfaceContainerLow = Color(0xFFFFF8EB); // Parchment cream
  static const Color onSurfaceContainerLow = Color(0xFF2D1B4E);
  static const Color surfaceContainer = Color(0xFFF7ECFF);
  static const Color onSurfaceContainer = Color(0xFF2D1B4E);
  static const Color surfaceContainerHigh = Color(0xFFE9D5FF);
  static const Color onSurfaceContainerHigh = Color(0xFF2D1B4E);
  static const Color surfaceNav = Color(0xFF4A2E70); // Deep plum navigation & HUD
  static const Color onSurfaceNav = Color(0xFFFFFFFF);

  // Outline / Borders
  static const Color outline = Color(0xFF4A2E70);
  static const Color outlineVariant = Color(0xFFD8B4FE);

  // Semantic Status
  static const Color success = Color(0xFF2E8B57);
  static const Color onSuccess = Color(0xFF0F0F0F);
  static const Color warning = Color(0xFFD97706);
  static const Color onWarning = Color(0xFF2A2A2A);
  static const Color error = Color(0xFFDC2626);
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
  static const double sm = 6.0;
  static const double standard = 12.0;
  static const double md = 14.0;
  static const double lg = 18.0;
  static const double xl = 24.0;
  static const double full = 9999.0;

  static BorderRadius get radiusSm => BorderRadius.circular(sm);
  static BorderRadius get radiusStandard => BorderRadius.circular(standard);
  static BorderRadius get radiusMd => BorderRadius.circular(md);
  static BorderRadius get radiusLg => BorderRadius.circular(lg);
  static BorderRadius get radiusXl => BorderRadius.circular(xl);
  static BorderRadius get radiusFull => BorderRadius.circular(full);
}

class AppShadows {
  // Tactile Bottom-Offset Pixel RPG Shadows
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

  static const BoxShadow card = BoxShadow(
    color: Color(0x1F2D1B4E),
    offset: Offset(0, 4),
    blurRadius: 12,
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
