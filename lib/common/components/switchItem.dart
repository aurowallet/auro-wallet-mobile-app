import 'package:flutter/material.dart';

class SwitchItem extends StatelessWidget {
  SwitchItem({required this.text, required this.isOn, required this.onClick});

  final String text;
  final bool isOn;
  final void Function(bool) onClick;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 54,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600)),
            Theme(
              data: ThemeData(
                useMaterial3: true,
              ).copyWith(
                colorScheme: Theme.of(context)
                    .colorScheme
                    .copyWith(outline: Color(0xFFE9E9E9)),
              ),
              child: Switch(
                value: isOn,
                onChanged: onClick,
                activeThumbColor: Colors.white,
                inactiveThumbColor: Colors.white,
                activeTrackColor: Color(0xFF594AF1),
                inactiveTrackColor: Color(0xFFE9E9E9),
              ),
            )
          ],
        ));
  }
}
