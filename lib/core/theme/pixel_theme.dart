import 'package:flutter/material.dart';

/// Remindo Pixel RPG Design System tokens based on Warm Wood & Parchment design specifications.
class PixelColors {
  // App Canvas / Scaffold Background
  static const Color bgLavender = Color(0xFFF5E9D3);

  // Shell & Borders
  static const Color deepPurple = Color(0xFF4E2F1B);
  static const Color badgePurple = Color(0xFF7A4B2A);
  static const Color activeBorder = Color(0xFFC9A679);
  static const Color activePink = Color(0xFF2E7D32);

  // Cards & Surfaces
  static const Color cardParchment = Color(0xFFFFF8EB);
  static const Color cardParchmentGold = Color(0xFFFEF3C7);
  static const Color cardParchmentDarker = Color(0xFFEFE0C6);

  // Highlights & Accents
  static const Color coinGold = Color(0xFFF59E0B);
  static const Color greenSuccess = Color(0xFF2E7D32);
  static const Color redExpense = Color(0xFFBA1A1A);
  static const Color blueFocus = Color(0xFF7A4B2A);

  // Typography
  static const Color textDark = Color(0xFF2C160B);
  static const Color textMuted = Color(0xFF6E5544);
  static const Color textWhite = Colors.white;
}

class PixelBorder {
  static final Border all = Border.all(color: PixelColors.deepPurple, width: 2);
  static const Border bottom = Border(bottom: BorderSide(color: PixelColors.deepPurple, width: 2));
  static const Border top = Border(top: BorderSide(color: PixelColors.deepPurple, width: 2));
}

class PixelDecorations {
  /// Standard Retro Parchment Card with 2px dark wood border and hard pixel drop shadow
  static BoxDecoration card({
    Color color = PixelColors.cardParchment,
    double radius = 4,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: PixelColors.deepPurple, width: 2),
      boxShadow: hasShadow
          ? [
              const BoxShadow(
                color: Color(0x334E2F1B),
                offset: Offset(2, 3),
                blurRadius: 0,
              ),
            ]
          : null,
    );
  }

  /// Interactive Button Decoration
  static BoxDecoration button({
    Color color = PixelColors.cardParchment,
    double radius = 24,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: PixelColors.deepPurple, width: 2),
      boxShadow: isPressed
          ? null
          : const [
              BoxShadow(
                color: Color(0x444E2F1B),
                offset: Offset(0, 2),
                blurRadius: 0,
              ),
            ],
    );
  }
}
