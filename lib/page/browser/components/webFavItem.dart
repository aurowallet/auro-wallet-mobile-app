import 'dart:ui';

import 'package:auro_wallet/page/browser/types/webConfig.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WebFavItem extends StatelessWidget {
  WebFavItem({required this.data, this.onClickItem});

  final WebConfig data;
  final Function(WebConfig)? onClickItem;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        child: Material(
          color: Color(0xFFF9FAFC),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () {
              onClickItem!(data);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.black.withOpacity(0.05), width: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ItemLogo(
                      name: data.title,
                      logo: data.icon,
                    ),
                    Container(
                      width: 10,
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.title,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w400)),
                      ],
                    )),
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
  bool loadError = false;

  onLoadError(exception, stackTrace) {
    setState(() {
      loadError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool showHolderText = false;
    if (widget.logo != null && widget.logo!.isNotEmpty) {
      showHolderText = loadError;
    } else {
      showHolderText = true;
    }
    bool showHolderIcon = widget.showHolderIcon == true;
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: showHolderIcon ? Colors.transparent : Color(0x4D000000),
      onBackgroundImageError: !showHolderText ? onLoadError : null,
      backgroundImage: !showHolderText
          ? NetworkImage(
              widget.logo!,
            )
          : null,
      child: showHolderText
          ? showHolderIcon
              ? SvgPicture.asset(
                  "assets/images/public/browser_tab.svg",
                  color: Colors.black,
                )
              : Text(
                  widget.name?.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                )
          : null,
    );
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
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF000000).withOpacity(0.8),
                            fontWeight: FontWeight.w400)),
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                    ),
                    Text(data.uri,
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
