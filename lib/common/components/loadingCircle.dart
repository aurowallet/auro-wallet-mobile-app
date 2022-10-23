import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter/material.dart';

class LoadingCircle extends StatefulWidget {
  @override
  _LoadingCircleState createState() => new _LoadingCircleState();

  LoadingCircle({
    this.padding = const EdgeInsets.only(top: 20, right: 30, left: 30)
  });

  final EdgeInsetsGeometry padding;

}

class _LoadingCircleState extends State<LoadingCircle>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  @override
  void initState() {
    animationController = new AnimationController(
      duration: new Duration(milliseconds: 600),
      vsync: this
    );
    animationController?.repeat();
    super.initState();
  }

  @override
  dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).main;
    return Padding(
        padding: widget.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(animationController!),
                child: Image.asset('assets/images/public/loading_circle.png', width: 20, height: 20,),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Text(i18n["loading"]! + '...', style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.3)
              ),),
            )
          ],
        )
    );
  }
}

