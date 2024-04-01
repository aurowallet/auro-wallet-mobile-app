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
              dataIcon:data.icon,
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
              radius: 8,
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
      this.onClickDelete,
      this.radius = 0});

  final WebConfig data;
  final Function(WebConfig)? onClickItem;
  final Function(WebConfig)? onClickDelete;
  final Widget childWidget;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      onTap: () {
        onClickItem!(data);
      },
      child: childWidget,
    );
  }
}

class ItemLogo extends StatefulWidget {
  ItemLogo(
      {this.name,
      this.radius = 15,
      required this.width,
      this.showHolderIcon,
      this.dataIcon});

  final String? name;
  final double? radius;
  final double width;
  final bool? showHolderIcon;
  final String? dataIcon;

  @override
  ItemLogoState createState() => ItemLogoState();
}

class ItemLogoState extends State<ItemLogo> {
  @override
  Widget build(BuildContext context) {
    bool showHolderIcon = widget.showHolderIcon == true;

    String logoUrl = "";
    if (widget.dataIcon != null && widget.dataIcon!.isNotEmpty) {
      bool isFirstCharLetter = RegExp(r'^[a-zA-Z]').hasMatch(widget.dataIcon![0]);

      if (!isFirstCharLetter) {
        if (widget.dataIcon!.length >= 5) {
          logoUrl = widget.dataIcon!.substring(1, widget.dataIcon!.length - 1);
        }
      } else {
        logoUrl = widget.dataIcon!;
      }
    }
    return ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius ?? 0),
        child: CachedNetworkImage(
            width: widget.width,
            height: widget.width,
            imageUrl: logoUrl.trim(),
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
                  "assets/images/public/tab/tab_browser_active.svg",
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
    return Container(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ItemLogo(
              name: data.title,
              dataIcon: data.icon,
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
