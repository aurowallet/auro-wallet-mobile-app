import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EasyLoading {
  static OverlayEntry? _overlayEntry;

  // Show the loading dialog
  static void show(BuildContext context) {
    // Remove any existing overlay if it exists
    dismiss();

    // Create the overlay entry with the loading dialog
    _overlayEntry = OverlayEntry(
      builder: (context) => LoadingWidget(),
    );

    // Insert the overlay into the widget tree
    Overlay.of(context).insert(_overlayEntry!);
  }

  // Dismiss the loading dialog
  static void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class LoadingWidget extends StatefulWidget {
  LoadingWidget({Key? key}) : super(key: key);

  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  @override
  void initState() {
    animationController = new AnimationController(
        duration: new Duration(milliseconds: 600), vsync: this);
    animationController?.repeat();
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Container(
          color: Colors.black.withValues(alpha: 0.8),
        ),
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 27, horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RotationTransition(
                  turns:
                      Tween(begin: 0.0, end: 1.0).animate(animationController!),
                  child: SvgPicture.asset(
                    'assets/images/public/loading_circle.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  dic.loading,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
