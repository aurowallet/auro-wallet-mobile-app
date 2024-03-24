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

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    String showTitle = data.title;
    var itemWidth = (MediaQuery.of(context).size.width - 40) / 2 - 50;
    return Container(
        margin: const EdgeInsets.only(top: 10),
        child: Material(
          color: Color(0xFFF9FAFC),
          borderRadius: BorderRadius.circular(8),
          child: GestureDetector(
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
                      child: Text(
                        dic.delete,
                      ),
                    ),
                  ),
                ],
              );
            },
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.black.withOpacity(0.05), width: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ItemLogo(
                      name: data.title,
                      logo: data.icon,
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
                              fontWeight: FontWeight.w400)),
                    ),
                  ],
                )),
          ),
        ));
  }
}

class ItemLogo extends StatefulWidget {
  ItemLogo({this.name, this.logo, this.radius = 15, this.showHolderIcon});

  final String? name;
  final String? logo;
  final double? radius;
  bool? showHolderIcon;

  @override
  ItemLogoState createState() => ItemLogoState();
}

class ItemLogoState extends State<ItemLogo> {


  @override
  Widget build(BuildContext context) {
    bool showHolderIcon = widget.showHolderIcon == true;
    double imgWidth = widget.radius! * 2;
    return CircleAvatar(
        radius: widget.radius,
        backgroundColor: showHolderIcon ? Colors.transparent : Color(0x4D000000),
        child: CachedNetworkImage(
            width: imgWidth,
            imageUrl: widget
                .logo!,
            placeholder: (context, url) {
              return Text(
                widget.name?.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(fontSize: 14, color: Colors.white),
              );
            },
            errorWidget: (context, url, error) {
              if (showHolderIcon) {
                return SvgPicture.asset(
                  "assets/images/public/browser_tab.svg",
                  color: Colors.black,
                );
              }
              return Center(
                child: Text(
                  widget.name?.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              );
            }));
  }
}

class WebHistoryItem extends StatelessWidget {
  WebHistoryItem({required this.data, this.onClickItem});

  final WebConfig data;
  final Function(WebConfig)? onClickItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () {
          onClickItem!(data);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ItemLogo(
                    name: data.title, logo: data.icon, showHolderIcon: true),
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
                            fontSize: 12,
                            color: Color(0xFF000000).withOpacity(0.8),
                            fontWeight: FontWeight.w400)),
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                    ),
                    Text(data.url,
                        softWrap: true,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            color:
                                ColorsUtil.hexColor(0x808080).withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                            fontSize: 10)),
                  ],
                )),
              ],
            )),
      ),
    );
  }
}
