import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingItem extends StatelessWidget {
  SettingItem({required this.title, required this.onTap, required this.icon, this.value});

  final String title;
  final String? value;
  final String icon;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 28,
        child: SvgPicture.asset(
            icon,
            width: 30,
            height: 30
        ),
      ),
      minLeadingWidth: 0,
      minVerticalPadding: 0,
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          value != null ? Text(value!, style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0x4D000000)
          ),): Container(),
          Container(
            width: 30,
            height: 30,
            child: Center(
              child: Icon(Icons.arrow_forward_ios, size: 18),
            ),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}