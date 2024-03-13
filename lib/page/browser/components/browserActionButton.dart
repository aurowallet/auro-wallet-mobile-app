import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserActionButton extends StatelessWidget {
  const BrowserActionButton(this._controller, {Key? key})
      : super(key: key);
  final WebViewController _controller;

  Widget buildItem(
      String icon, String name, Function onTap, BuildContext context) {
    return GestureDetector(
      child: SizedBox(
          height: 40,
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(
                  width: 0.5,
                  color: Color(0xFF000000).withOpacity(0.1),
                ),
              )),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Center(
                        child: SvgPicture.asset(icon,
                            width: 14, color: Colors.black)),
                  ),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none),
                  )
                ],
              ))),
      onTap: () {
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            child: Container(
              height: 128,
              child: Column(
                children: [
                  Expanded(
                      child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: [
                        buildItem("assets/images/webview/icon_refresh.svg",
                            "Refresh", () {
                          Navigator.pop(context);
                          _controller.reload();
                        }, context),
                        buildItem("assets/images/webview/icon_copy.svg",
                            "Copy Link", () {
                          Navigator.pop(context);
                        }, context),
                        buildItem(
                            "assets/images/webview/icon_fav.svg",
                            "Remove from favorites", () {
                          // assets/images/webview/icon_unfav.svg
                          // Add to favorites
                          Navigator.pop(context);
                        }, context),
                      ],
                    ),
                  ))
                ],
              ),
            )));
  }
}
