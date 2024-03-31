import 'package:auro_wallet/store/settings/types/customNodeV2.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NetworkItem extends StatelessWidget {
  NetworkItem({
    this.checked = false,
    required this.text,
    required this.value,
    required this.onChecked,
    required this.tag,
    required this.isEditing,
    this.chainId,
    this.editable = false,
    this.onEdit,
    this.endpoint,
    this.margin = const EdgeInsets.only(top: 0),
    this.iconUrl,
  });

  final bool checked;
  final bool isEditing;
  final bool editable;
  final String text;
  final String? chainId;
  final String value;
  final String? tag;
  final CustomNodeV2? endpoint;
  final void Function(bool, String) onChecked;
  final void Function(CustomNodeV2)? onEdit;
  final EdgeInsetsGeometry margin;
  final String? iconUrl;

  onPressed() {
    if (isEditing && onEdit != null && endpoint != null) {
      onEdit!(endpoint!);
    } else {
      onChecked(!checked, value);
    }
  }

  Color getChainNameColor(bool isSelected, bool isEditing, bool editable) {
    if (isEditing) {
      return editable ? Colors.black : Colors.black.withOpacity(0.05);
    } else if (isSelected) {
      return Colors.white;
    }
    return Colors.black;
  }

  Color getChainIdColor(bool isSelected, bool isEditing) {
    if (isSelected && !isEditing) {
      return Colors.white.withOpacity(0.5);
    }
    return Colors.black.withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    Color chainNameColor = getChainNameColor(checked, isEditing, editable);
    Color chainIdColor = getChainIdColor(checked, isEditing);

    return Padding(
      padding: margin,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Material(
          color: Color(0xFFF9FAFC),
          child: InkWell(
              onTap: onPressed,
              child: Container(
                  padding: EdgeInsets.all(16).copyWith(bottom: 12),
                  decoration: BoxDecoration(
                      color: checked && !isEditing
                          ? Color(0xFF594AF1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.black.withOpacity(0.05), width: 1)),
                  child: Row(
                    children: [
                      NetworkIcon(
                        iconUrl: iconUrl,
                        iconName: text,
                      ),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                      child: Text(Fmt.breakWord(text)!,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: chainNameColor,
                                              fontWeight: FontWeight.w500))),
                                  tag != null
                                      ? Container(
                                          margin: EdgeInsets.only(left: 5),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: ColorsUtil.hexColor(0x000000)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          child: Text(tag!,
                                              style: theme.headline6!.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500)),
                                        )
                                      : Container()
                                ],
                              )),
                            ],
                          ),
                          chainId != null
                              ? Container(
                                  margin: EdgeInsets.only(top: 4),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      Fmt.address(chainId,
                                          pad: 6, padSame: true),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: chainIdColor,
                                          fontWeight: FontWeight.w400)),
                                )
                              : Container()
                        ],
                      )),
                      isEditing
                          ? Container(
                              alignment: Alignment.centerRight,
                              child: Container(
                                child: editable
                                    ? SvgPicture.asset(
                                        'assets/images/stake/icon_edit.svg',
                                        width: 40,
                                        height: 40)
                                    : Container(),
                              ))
                          : SizedBox(
                              width: 40,
                            )
                    ],
                  ))),
        ),
      ),
    );
  }
}

class NetworkIcon extends StatelessWidget {
  final String? iconUrl;
  final String iconName;

  const NetworkIcon({
    Key? key,
    this.iconUrl,
    required this.iconName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (iconUrl != null && iconUrl!.isNotEmpty) {
      bool isSvg = iconUrl!.endsWith('.svg');

      return Container(
          margin: EdgeInsets.only(right: 10),
          child: ClipOval(
            child: isSvg
                ? SvgPicture.asset(
                    iconUrl!,
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    iconUrl!,
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ),
          ));
    } else {
      return Container(
          margin: EdgeInsets.only(right: 10),
          child: CircleAvatar(
            radius: 15,
            backgroundColor: Colors.black.withOpacity(0.3),
            child: Text(
              iconName.isNotEmpty ? iconName[0].toUpperCase() : '',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
            ),
          ));
    }
  }
}
