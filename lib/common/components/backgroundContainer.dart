import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  BackgroundContainer(this.image, this.child, {this.fit = BoxFit.contain, this.maxHeight = double.infinity});

  final ImageProvider image;
  final Widget child;
  final BoxFit fit;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).canvasColor,
        ),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: maxHeight
          ),
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
