import 'package:flutter/material.dart';

class TabPageTitle extends StatelessWidget {
  TabPageTitle({
    required this.title
  });

  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          title,
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700
          ),
        )
    );
  }
}
