import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrowserActionButton extends StatelessWidget {
  BrowserActionButton({required this.url, this.isFav, this.onClickFav});
  final String url;
  final bool? isFav;
  final Function()? onClickFav;

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
                  color: Color(0xFF000000).withValues(alpha: 0.1),
                ),
              )),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Center(
                        child: SvgPicture.asset(icon,
                            width: 14,
                            colorFilter: ColorFilter.mode(
                                Colors.black, BlendMode.srcIn))),
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
    AppLocalizations dic = AppLocalizations.of(context)!;
    String favUrl = isFav == true
        ? "assets/images/webview/icon_fav.svg"
        : "assets/images/webview/icon_unfav.svg";
    String favTxt = isFav == true ? dic.removeFavorites : dic.addFavorites;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12),
          )),
      padding: EdgeInsets.only(top: 8, bottom: 16),
      child: SafeArea(
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
                  buildItem("assets/images/webview/icon_copy.svg", dic.copyLink,
                      () {
                    UI.copyAndNotify(context, url);
                    Navigator.pop(context);
                  }, context),
                  buildItem(favUrl, favTxt, () {
                    if (onClickFav != null) {
                      onClickFav!();
                    }
                    Navigator.pop(context);
                  }, context),
                  buildItem(
                      "assets/images/webview/icon_link.svg", dic.openInBrowser,
                      () {
                    Navigator.pop(context);
                    UI.launchURL(url);
                  }, context),
                ],
              ),
            ))
          ],
        ),
      )),
    );
  }
}
