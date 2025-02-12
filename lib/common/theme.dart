import 'package:flutter/material.dart';
ThemeData theme = ThemeData();
// TextButtonThemeData textButtonData = const TextButtonThemeData();
final appTheme = ThemeData(
  useMaterial3: false, // close Material 3
  primaryColor: Color(0xFF594AF1),
  // highlightColor: Colors.transparent,
  splashColor: Color(0xFF594AF1).withValues(alpha: 0.1),
  brightness: Brightness.light,
  // splashFactory: NoSplashFactory(),
  appBarTheme: AppBarTheme(
      color: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      iconTheme: IconThemeData(
          color: Colors.black
      ),
      titleTextStyle: TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.w600
      ),
      shadowColor: Colors.transparent
  ),
  textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
      ),
      displayMedium: TextStyle(
        fontSize: 22
      ),
      displaySmall: TextStyle(
          fontSize: 20
      ),
      headlineLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(
          fontSize: 16,
          // color: ColorsUtil.hexColor(0x333333)
      ),
      headlineSmall: TextStyle(
          fontSize: 14,
          // color: ColorsUtil.hexColor(0x333333)
      ),
      labelLarge: TextStyle(
        color: Colors.white,
        fontSize: 18,
      )),
);

class NoSplashFactory extends InteractiveInkFeatureFactory {

  InteractiveInkFeature create(
      {
        required MaterialInkController controller,
        required RenderBox referenceBox,
        required Offset position,
        required Color color,
        required TextDirection textDirection,
        bool containedInkWell = false,
        RectCallback? rectCallback,
        BorderRadius? borderRadius,
        ShapeBorder? customBorder,
        double? radius,
        VoidCallback? onRemoved,
      }
        ) {
    return _NoInteractiveInkFeature(controller: controller, referenceBox: referenceBox, color: color);
  }
}

class _NoInteractiveInkFeature extends InteractiveInkFeature {
  _NoInteractiveInkFeature({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Color color,
  }) : super(controller: controller, referenceBox: referenceBox, color: color);


  void paintFeature(Canvas canvas, Matrix4 transform) {}
}
