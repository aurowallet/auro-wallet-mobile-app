import 'dart:math';

import 'package:auro_wallet/store/browser/types/zkApp.dart';
import 'package:flutter/material.dart';

class TypeRowInfo extends StatelessWidget {
  final List<DataItem> data;
  final bool isZkData;

  const TypeRowInfo({Key? key, required this.data, this.isZkData = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: data
            .map(
                (item) => ChildView(data: item, count: 0, showInLine: isZkData))
            .toList(),
      ),
    );
  }
}

class ChildView extends StatelessWidget {
  final DataItem data;
  final int count;
  final bool showInLine;

  const ChildView(
      {Key? key, required this.data, this.count = 0, this.showInLine = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String showValue = (data?.value) ?? "";
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContentRow(
              title: data.label,
              content: "$showValue",
              count: count + 1,
              showInLine: showInLine,
              withColon: showInLine),
          if (data.children != null)
            ...data.children!
                .map((item) => Container(
                      child: ChildView(
                          data: item, count: count + 1, showInLine: showInLine),
                    ))
                .toList(),
        ],
      ),
    );
  }
}

class ContentRow extends StatelessWidget {
  final String title;
  final String content;
  final int count;
  final bool showInLine;
  final bool withColon;

  const ContentRow(
      {Key? key,
      required this.title,
      required this.content,
      this.count = 0,
      this.showInLine = false,
      this.withColon = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final marginLeftValue = max(0, 20.0 * (count - 1));
    return Container(
      margin: EdgeInsets.only(left: marginLeftValue.toDouble(), top: 6),
      child: Row(
        children: [
          Text(
            withColon ? "$title: " : title,
            style: TextStyle(
                color: Color(0xFF000000).withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          Expanded(
              child: Text(
            content,
            style: TextStyle(
                color: Color(0xFF000000).withOpacity(0.8),
                fontWeight: FontWeight.w400),
          )),
        ],
      ),
    );
  }
}
