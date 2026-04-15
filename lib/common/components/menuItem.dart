import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({
    Key? key,
    required this.text,
    this.onTap,
    this.value,
    this.trailing,
    this.switchValue,
    this.onSwitchChanged,
  }) : super(key: key);

  final String text;
  final VoidCallback? onTap;
  final String? value;
  final Widget? trailing;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  Widget _buildTrailing(BuildContext context) {
    if (trailing != null) return trailing!;
    if (onSwitchChanged != null) {
      return Switch(
        value: switchValue ?? false,
        onChanged: onSwitchChanged,
        activeThumbColor: Colors.white,
        inactiveThumbColor: Colors.white,
        activeTrackColor: Color(0xFF594AF1),
        inactiveTrackColor: Color(0xFFE9E9E9),
        trackOutlineColor: WidgetStatePropertyAll(Color(0xFFE9E9E9)),
      );
    }
    return Row(
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
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
        SvgPicture.asset(
          'assets/images/assets/right_arrow.svg',
          width: 6,
          height: 12,
          colorFilter: value != null
              ? ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.srcIn)
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        constraints: BoxConstraints(minHeight: 54),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildTrailing(context),
          ],
        ),
      ),
    );
  }
}
