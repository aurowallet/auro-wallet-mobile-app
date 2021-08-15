import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/UI.dart';
class DropdownItem {
  DropdownItem({required this.text,required this.key});
  final String text;
  final String key;
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
    return Container(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        height: 30,
        width: 100,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Colors.white,
        ),
        child: Center(
          child: DropdownButton<String>(
            focusColor: Colors.white,
            value: widget.value,
            isDense: true,
            isExpanded: true,
            style: TextStyle(color: Colors.white),
            underline: Container(height: 0),
            iconEnabledColor: Colors.black,
            items: widget.items.map<DropdownMenuItem<String>>((DropdownItem item) {
              return DropdownMenuItem<String>(
                value: item.key,
                child: Text(item.text,style:TextStyle(color:Colors.black),),
              );
            }).toList(),
            hint: widget.placeholder != null ? Text(
              widget.placeholder!,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ): null,
            onChanged: (String? value) {
              widget.onChoose(value);
            },
          ),
        )
    );
  }
}
