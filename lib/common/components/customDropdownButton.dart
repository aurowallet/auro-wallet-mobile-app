import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class DropdownItem {
  DropdownItem({required this.text,required this.value});
  final String text;
  final String value;
}
class CustomDropdownButton extends StatefulWidget {
  CustomDropdownButton({
    required this.items,
    this.placeholder,
    required this.onChoose,
    required this.value
  });

  final List<DropdownItem> items;
  final String? placeholder;
  final String value;
  final Function(String? text) onChoose;
  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return FittedBox(
        child: Container(
          padding: const EdgeInsets.only(left: 14.0, right: 8),
          height: 30,
          constraints: BoxConstraints(
              minWidth: 100
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Color(0x1A000000), width: 1),
            // color: Colors.white,
          ),
          child: Center(
              child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    dropdownWidth: 120,
                    offset: const Offset(-20, -18),
                    itemHeight: 44,
                    dropdownPadding: EdgeInsets.symmetric(vertical: 11),
                    selectedItemBuilder: (context) {
                      return widget.items.map((item) => Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Text(
                              item.text,
                              style: theme.headline6!.copyWith(
                                  color: Colors.black
                              ),
                            ),
                          )
                        ],
                      )).toList();
                    },
                    items: widget.items
                        .map((item) =>
                        DropdownMenuItem<String>(
                            value: item.value,
                            child: Center(
                              child: Text(
                                item.text,
                                style: theme.headline5!.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: item.value == widget.value ? Theme.of(context).primaryColor : Colors.black
                                ),),
                            )
                        ),
                    ).toList(),
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
