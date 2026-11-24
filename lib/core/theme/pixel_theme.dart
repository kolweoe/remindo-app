import 'package:flutter/material.dart';

/// Remindo Pixel RPG Design System tokens based on Penpot design specifications.
class PixelColors {
  // App Canvas / Scaffold Background
  static const Color bgLavender = Color(0xFFF3E8FF);

  // Shell & Borders
  static const Color deepPurple = Color(0xFF4A2E70);
  static const Color badgePurple = Color(0xFF6D3FA8);
  static const Color activeBorder = Color(0xFFD8B4FE);
  static const Color activePink = Color(0xFFD9468F);

  // Cards & Surfaces
  static const Color cardParchment = Color(0xFFFFF8EB);
  static const Color cardParchmentGold = Color(0xFFFEF3C7);
  static const Color cardParchmentDarker = Color(0xFFF7ECD5);

  // Highlights & Accents
  static const Color coinGold = Color(0xFFF59E0B);
  static const Color greenSuccess = Color(0xFF10B981);
  static const Color redExpense = Color(0xFFEF4444);
  static const Color blueFocus = Color(0xFF3B82F6);

  // Typography
  static const Color textDark = Color(0xFF2D1B4E);
  static const Color textMuted = Color(0xFF6B5B82);
  static const Color textWhite = Colors.white;
}

class PixelBorder {
  static final Border all = Border.all(color: PixelColors.deepPurple, width: 2);
  static const Border bottom = Border(bottom: BorderSide(color: PixelColors.deepPurple, width: 2));
  static const Border top = Border(top: BorderSide(color: PixelColors.deepPurple, width: 2));
}

class PixelDecorations {
  /// Standard Retro Parchment Card with 2px deep purple border and hard pixel drop shadow
  static BoxDecoration card({
    Color color = PixelColors.cardParchment,
    double radius = 14,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: PixelColors.deepPurple, width: 2),
      boxShadow: hasShadow
          ? [
              const BoxShadow(
                color: Color(0x334A2E70),
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
                color: Color(0x444A2E70),
                offset: Offset(0, 2),
                blurRadius: 0,
              ),
            ],
    );
  }
}
