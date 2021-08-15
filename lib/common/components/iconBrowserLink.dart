import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/UI.dart';

class IconBrowserLink extends StatefulWidget {
  IconBrowserLink(this.url, {required this.icon, this.mainAxisAlignment});
  final Widget icon;
  final String url;
  final MainAxisAlignment? mainAxisAlignment;

  @override
  _IconBrowserLinkState createState() => _IconBrowserLinkState();
}

class _IconBrowserLinkState extends State<IconBrowserLink> {
  bool _loading = false;

  Future<void> _launchUrl() async {
    if (_loading) return;
    setState(() {
      _loading = true;
    });
    await UI.launchURL(widget.url);
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: widget.mainAxisAlignment ?? MainAxisAlignment.center,
        children: <Widget>[
          widget.icon
        ],
      ),
      onTap: () {
        _launchUrl();
      },
    );
  }
}
