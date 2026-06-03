import 'package:auro_wallet/page/settings/components/networkIcon.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NetworkItem extends StatelessWidget {
  NetworkItem({
    required this.endpoint,
    required this.onChecked,
    this.isEditing,
    this.onEdit,
    this.isDisabled = false,
    this.margin = const EdgeInsets.only(top: 0),
  });

  final store = globalAppStore;

  final bool? isEditing;
  final bool isDisabled;
  final CustomNode endpoint;
  final void Function(bool, String) onChecked;
  final void Function(CustomNode)? onEdit;
  final EdgeInsetsGeometry margin;

  onPressed() {
    if (isEditing == true && onEdit != null) {
      onEdit!(endpoint);
    } else if (isDisabled) {
      return;
    } else {
      onChecked(!getNetworkCheckStatus(), endpoint.url);
    }
  }

  Color getChainNameColor(bool isSelected, bool isEditing, bool editable) {
    if (isEditing) {
      return editable ? Colors.black : Colors.black.withValues(alpha: 0.05);
    } else if (isSelected) {
      return Colors.white;
    }
    return Colors.black;
  }

  Color getChainIdColor(bool isSelected, bool isEditing) {
    if (isSelected && !isEditing) {
      return Colors.white.withValues(alpha: 0.5);
    }
    return Colors.black.withValues(alpha: 0.1);
  }

  bool getNetworkCheckStatus() {
    return store.settings!.currentNode?.url == endpoint.url;
  }

  @override
  Widget build(BuildContext context) {
    bool editable = endpoint.isDefaultNode != true;
    var theme = Theme.of(context).textTheme;
    bool checked = getNetworkCheckStatus();
    bool editing = isEditing == true;
    Color chainNameColor = isDisabled
        ? Colors.black.withValues(alpha: 0.3)
        : getChainNameColor(checked, editing, editable);
    String? tagStr;
    if (editable) {
      tagStr = endpoint.networkID;
    }

    Widget item = Padding(
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
                  constraints: const BoxConstraints(minHeight: 68),
                  padding: EdgeInsets.all(16).copyWith(bottom: 12),
                  decoration: BoxDecoration(
                      color: checked && !editing
                          ? Color(0xFF594AF1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.black.withValues(alpha: 0.05), width: 1)),
                  child: Row(
                    children: [
                      NetworkIcon(
                        endpoint: endpoint,
                      ),
                      SizedBox(
                        width: 10,
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
                                      child: Text(Fmt.breakWord(endpoint.name)!,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: chainNameColor,
                                              fontWeight: FontWeight.w500))),
                                  tagStr != null
                                      ? Container(
                                          margin: EdgeInsets.only(left: 5),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: ColorsUtil.hexColor(0x000000)
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          child: Text(tagStr,
                                              style: theme.headlineSmall!.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500)),
                                        )
                                      : Container(),
                                  if (isDisabled)
                                    Container(
                                      margin: EdgeInsets.only(left: 5),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFD65A5A)
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      child: Text("HTTP",
                                          style: TextStyle(
                                              color: Color(0xFFD65A5A),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      )),
                      editing
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

    if (isDisabled && !editing) {
      return Opacity(opacity: 0.5, child: item);
    }
    return item;
  }
}
