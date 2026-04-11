import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({
    Key? key,
    required this.text,
    required this.onTap,
    this.value,
  }) : super(key: key);

  final String text;
  final VoidCallback onTap;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value != null)
                  Padding(
                    padding: EdgeInsets.only(right: 14),
                    child: Text(
                      value!,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0x4D000000),
                      ),
                    ),
                  ),
                SvgPicture.asset(
                  'assets/images/assets/right_arrow.svg',
                  width: 6,
                  height: 12,
                  colorFilter: value != null
                      ? ColorFilter.mode(Color(0x4D000000), BlendMode.srcIn)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
