import 'package:auro_wallet/common/components/Separator.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

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
    AppLocalizations i18n = AppLocalizations.of(context)!;
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
                child: Text(i18n.testnet,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
        buttonStyleData: ButtonStyleData(
          height: 40,
          width: 110,
          padding: const EdgeInsets.only(left: 14, right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Color(0x1A000000), width: 1),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
        ),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
        isExpanded: true,
        items: widget.items
            .map((item) => _renderCustomItem(context, item))
            .toList(),
        dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            offset: const Offset(0, -18),
            elevation: 8),
        iconStyleData: const IconStyleData(
          openMenuIcon: const Icon(
            Icons.expand_less,
          ),
          icon: const Icon(
            Icons.expand_more,
          ),
          iconSize: 16,
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
