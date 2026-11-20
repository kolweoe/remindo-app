import 'package:flutter/material.dart';

/// Responsive utility designed for Remindo.
/// Base design viewport from Penpot is 390px (width) x 844px (height).
/// This ensures all screens scale proportionally across any phone brand and screen size.
class Responsive {
  static const double baseWidth = 390.0;
  static const double baseHeight = 844.0;

  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;

  static double scale(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // Cap scale between 0.85 and 1.35 so UI doesn't get ridiculously large or tiny
    final ratio = w / baseWidth;
    return ratio.clamp(0.85, 1.35);
  }

  static double px(BuildContext context, double value) {
    return value * scale(context);
  }

  static bool isSmallScreen(BuildContext context) => MediaQuery.of(context).size.width < 360;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600;
}

/// A wrapper widget that ensures content stays within the max mobile container width
/// and centers nicely on tablets or foldables, while maintaining 100% responsiveness on phones.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 480.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
