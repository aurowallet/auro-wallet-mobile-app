import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  BackgroundContainer(this.image, this.child, {this.fit = BoxFit.contain});

  final ImageProvider image;
  final Widget child;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).canvasColor,
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              alignment: Alignment.topLeft,
              image: image,
              fit: fit,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
