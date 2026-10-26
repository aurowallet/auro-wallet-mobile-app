import 'package:flutter/material.dart';

/// Keeps the existing phone typography without magnifying only the text on
/// tablet layouts, whose controls still use logical-pixel dimensions.
class AppTextScale extends StatelessWidget {
  const AppTextScale({super.key, required this.child});

  final Widget child;

  static bool _isTabletSize(Size size, Size? displaySize) =>
      size.shortestSide >= 600 || (displaySize?.shortestSide ?? 0) >= 600;

  static Size _displaySize(BuildContext context) {
    final display = View.of(context).display;
    return display.size / display.devicePixelRatio;
  }

  // Keep tablet typography in narrow iPad split-view windows as well. Use
  // logical display dimensions so a high-DPI phone is not treated as a tablet.
  static bool isTablet(BuildContext context) =>
      _isTabletSize(MediaQuery.sizeOf(context), _displaySize(context));

  static TextScaler forSize(Size size, {Size? displaySize}) {
    final factor = _isTabletSize(size, displaySize)
        ? 1.0
        : (size.width / 375).clamp(1.0, 2.0);
    return TextScaler.linear(factor);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: forSize(media.size, displaySize: _displaySize(context)),
      ),
      child: child,
    );
  }
}
