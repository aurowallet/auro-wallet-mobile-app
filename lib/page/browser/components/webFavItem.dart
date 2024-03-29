import 'dart:ui';

import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/store/browser/types/webConfig.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WebFavItem extends StatelessWidget {
  WebFavItem({required this.data, this.onClickItem, this.onClickDelete});

  final WebConfig data;
  final Function(WebConfig)? onClickItem;
  final Function(WebConfig)? onClickDelete;

  Widget buildWidget(BuildContext context) {
    String showTitle = data.title;
    var itemWidth = (MediaQuery.of(context).size.width - 40) / 2 - 50;
    String logoUrl = "";
    if (data.icon != null && data.icon!.isNotEmpty) {
      if (data.icon!.length >= 5) {
        logoUrl = data.icon!.substring(1, data.icon!.length - 1);
      }
    }
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: Colors.black.withOpacity(0.05), width: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 5,
            ),
            ItemLogo(
              name: data.title,
              logo: logoUrl,
              width: 20,
            ),
            SizedBox(
              width: 5,
            ),
            Container(
              width: itemWidth,
              child: Text(showTitle,
                  softWrap: true,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 36,
        child: Material(
            color: Color(0xFFF9FAFC),
            borderRadius: BorderRadius.circular(8),
            child: LongPressMenu(
              data: data,
              onClickItem: onClickItem,
              onClickDelete: onClickDelete,
              childWidget: buildWidget(context),
            )));
  }
}

class LongPressMenu extends StatelessWidget {
  LongPressMenu(
      {required this.data,
      required this.childWidget,
      this.onClickItem,
      this.onClickDelete});

  final WebConfig data;
  final Function(WebConfig)? onClickItem;
  final Function(WebConfig)? onClickDelete;
  final Widget childWidget;
  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return GestureDetector(
        onTap: () {
          onClickItem!(data);
        },
        onLongPressStart: (details) {
          Feedback.forLongPress(context);
          showMenu(
            context: context,
            color: Colors.black,
            constraints: BoxConstraints(
              maxWidth: 100,
            ),
            position: RelativeRect.fromLTRB(
              details.globalPosition.dx,
              details.globalPosition.dy,
              details.globalPosition.dx,
              details.globalPosition.dy,
            ),
            items: <PopupMenuEntry>[
              PopupMenuItem(
                onTap: () {
                  onClickDelete!(data);
                },
                height: 20,
                textStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 12),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dic.delete,
                      ),
                      SizedBox(width: 4),
                      SvgPicture.asset(
                        'assets/images/webview/icon_clear.svg',
                        width: 14,
                        height: 14,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        child: childWidget);
  }
}

class ItemLogo extends StatefulWidget {
  ItemLogo(
      {this.name,
      this.logo,
      this.radius = 15,
      required this.width,
      this.showHolderIcon});

  final String? name;
  final String? logo;
  final double? radius;
  final double width;
  bool? showHolderIcon;

  @override
  ItemLogoState createState() => ItemLogoState();
}

class ItemLogoState extends State<ItemLogo> {
  @override
  Widget build(BuildContext context) {
    bool showHolderIcon = widget.showHolderIcon == true;
    return ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius ?? 0),
        child: CachedNetworkImage(
            width: widget.width,
            height: widget.width,
            imageUrl: widget.logo!.trim(),
            placeholder: (context, url) {
              return Text(
                widget.name?.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(fontSize: 14, color: Colors.white),
              );
            },
            errorListener: (value) {
              print('browser icon load faile ,${value}');
            },
            errorWidget: (context, url, error) {
              if (showHolderIcon) {
                return SvgPicture.asset(
                  "assets/images/public/browser_tab.svg",
                  color: Colors.black,
                );
              }
              return Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  width: 20,
                  height: 20,
                  child: Center(
                    child: Text(
                      widget.name?.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ));
            }));
  }
}

class WebHistoryItem extends StatelessWidget {
  WebHistoryItem({required this.data, this.onClickItem, this.onClickDelete});

  final WebConfig data;
  final Function(WebConfig)? onClickItem;
  final Function(WebConfig)? onClickDelete;
  Widget buildWidget(BuildContext context) {
    String logoUrl = "";
    if (data.icon != null && data.icon!.isNotEmpty) {
      if (data.icon!.length >= 5) {
        logoUrl = data.icon!.substring(1, data.icon!.length - 1);
      }
    }
    return Container(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ItemLogo(
              name: data.title,
              logo: logoUrl,
              showHolderIcon: true,
              radius: 30,
              width: 24,
            ),
            Container(
              width: 10,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title,
                    softWrap: true,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF000000).withOpacity(0.8),
                        fontWeight: FontWeight.w500)),
                Padding(
                  padding: EdgeInsets.only(top: 2),
                ),
                Text(data.url,
                    softWrap: true,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: ColorsUtil.hexColor(0x808080).withOpacity(0.5),
                        fontWeight: FontWeight.w400,
                        fontSize: 10)),
              ],
            )),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: LongPressMenu(
      data: data,
      onClickItem: onClickItem,
      onClickDelete: onClickDelete,
      childWidget: buildWidget(context),
    ));
  }
}
