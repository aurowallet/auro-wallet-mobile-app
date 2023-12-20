import 'package:auro_wallet/common/components/Separator.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class DropdownItem {
  DropdownItem({required this.text, required this.value});
  final String text;
  final String value;
}

class CustomDropdownButton extends StatefulWidget {
  CustomDropdownButton(
      {required this.items,
      this.placeholder,
      required this.onChoose,
      required this.value});

  final List<DropdownItem> items;
  final String? placeholder;
  final String value;
  final Function(String? text) onChoose;
  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  DropdownMenuItem<String> _renderCustomItem(
    BuildContext context,
    DropdownItem item,
  ) {
    var i18n = I18n.of(context).main;
    if (item.value == 'networkDivider') {
      return DropdownMenuItem<String>(
        enabled: false,
        value: item.value,
        child: Container(
          child: Row(
            children: [
              Expanded(
                child: Separator(color: ColorsUtil.hexColor(0x808080)),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: Text(i18n['testnet']!,
                    style: TextStyle(
                        fontSize: 12,
                        color: ColorsUtil.hexColor(0x808080),
                        fontWeight: FontWeight.w400)),
              ),
              Expanded(
                child: Separator(color: ColorsUtil.hexColor(0x808080)),
              ),
            ],
          ),
        ),
      );
    }
    return DropdownMenuItem<String>(
        value: item.value,
        child: Center(
          child: Text(
            item.text,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: item.value == widget.value
                    ? Theme.of(context).primaryColor
                    : Colors.black),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return FittedBox(
        child: Container(
      height: 30,
      constraints: BoxConstraints(
          // minWidth: 100,
          ),
      child: Center(
          child: DropdownButtonHideUnderline(
              child: DropdownButton2(
        // dropdownWidth: 180,
        // isExpanded: false,
        buttonDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Color(0x1A000000), width: 1),
          // color: Colors.white,
        ),
        buttonPadding: const EdgeInsets.only(left: 14.0, right: 8),
        offset: const Offset(0, -18),
        itemHeight: 40,
        itemPadding: EdgeInsets.symmetric(horizontal: 8),
        dropdownPadding: EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        selectedItemBuilder: (context) {
          return widget.items.map((item) {
            return Container(
              padding: EdgeInsets.only(right: 4),
              constraints: BoxConstraints(
                  minWidth: 82 * MediaQuery.of(context).textScaleFactor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.value == widget.value ? item.text : '',
                    style: TextStyle(
                        fontSize: 14,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  )
                ],
              ),
            );
          }).toList();
        },
        items: widget.items
            .map((item) => _renderCustomItem(context, item))
            .toList(),
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // color: Colors.red,
        ),
        dropdownElevation: 8,
        icon: const Icon(
          Icons.expand_more,
        ),
        iconSize: 16,
        iconOnClick: const Icon(
          Icons.expand_less,
        ),
        value: widget.value,
        onChanged: (String? value) {
          print(value);
          widget.onChoose(value);
        },
      ))),
    ));
  }
}
