import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:url_launcher/url_launcher.dart';

class BrowserLink extends StatefulWidget {
  BrowserLink(this.url,
      {this.text,
      this.mainAxisAlignment,
      this.textStyle,
      this.showIcon = true,
      this.launchMode});

  final String? text;
  final TextStyle? textStyle;
  final String url;
  final MainAxisAlignment? mainAxisAlignment;
  final bool showIcon;
  final LaunchMode? launchMode;

  @override
  _BrowserLinkState createState() => _BrowserLinkState();
}

class _BrowserLinkState extends State<BrowserLink> {
  Future<void> _launchUrl() async {
    await UI.launchURL(widget.url, mode: widget.launchMode);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment:
                  widget.mainAxisAlignment ?? MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: widget.showIcon ? 4 : 0),
                  child: Text(
                    widget.text ?? widget.url,
                    style: widget.textStyle ??
                        TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500),
                  ),
                ),
                widget.showIcon
                    ? Icon(Icons.open_in_new,
                        size: 16, color: Theme.of(context).primaryColor)
                    : Container()
              ],
            )),
        onTap: () {
          _launchUrl();
        });
  }
}
