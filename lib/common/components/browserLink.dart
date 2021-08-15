import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/UI.dart';

class BrowserLink extends StatefulWidget {
  BrowserLink(this.url, {this.text, this.mainAxisAlignment, this.showIcon = true});

  final String? text;
  final String url;
  final MainAxisAlignment? mainAxisAlignment;
  final bool showIcon;

  @override
  _BrowserLinkState createState() => _BrowserLinkState();
}

class _BrowserLinkState extends State<BrowserLink> {
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
    var theme = Theme.of(context).textTheme;
    return GestureDetector(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: widget.mainAxisAlignment ?? MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 4),
            child: Text(
              widget.text ?? widget.url,
              style: theme.headline5!.copyWith(color: Theme.of(context).primaryColor),
            ),
          ),
          widget.showIcon ? Icon(Icons.open_in_new, size: 16, color: Theme.of(context).primaryColor) : Container()
        ],
      ),
      onTap: () {
        _launchUrl();
      },
    );
  }
}
