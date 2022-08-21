import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
ThemeData theme = ThemeData();
TextButtonThemeData textButtonData = const TextButtonThemeData();
final appTheme = ThemeData(
  primaryColor: Color(0xFF594AF1),
  // highlightColor: Colors.transparent,
  // splashColor: Colors.transparent,
  // splashFactory: NoSplashFactory(),
  // textButtonTheme: TextButtonThemeData(
  //   style: ButtonStyle(
  //     foregroundColor: MaterialStateProperty.all(Colors.transparent),
  //   )
  // ),
  appBarTheme: AppBarTheme(
      color: Colors.white,
      iconTheme: IconThemeData(
          color: Colors.black
      ),
      textTheme: theme.textTheme.copyWith(
        headline6: theme.textTheme.headline6!.copyWith(
            fontSize: 20,
            color: Colors.black
        ),
      ),
      shadowColor: Colors.transparent
  ),
  textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 24,
      ),
      headline2: TextStyle(
        fontSize: 22
      ),
      headline3: TextStyle(
          fontSize: 20
      ),
      headline4: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      headline5: TextStyle(
          fontSize: 16,
          // color: ColorsUtil.hexColor(0x333333)
      ),
      headline6: TextStyle(
          fontSize: 14,
          // color: ColorsUtil.hexColor(0x333333)
      ),
      button: TextStyle(
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
    VoidCallback? onRemoved,
  }) : super(controller: controller, referenceBox: referenceBox, color: color);


  void paintFeature(Canvas canvas, Matrix4 transform) {}
}
