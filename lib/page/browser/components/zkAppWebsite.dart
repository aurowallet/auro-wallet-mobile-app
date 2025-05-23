import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';

class ZkAppWebsite extends StatelessWidget {
  ZkAppWebsite({this.icon, required this.url});

  final String? icon;
  final String url;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Color(0xFFF9FAFC),
          border: Border.all(
              color: Colors.black.withValues(alpha: 0.05), width: 0.5)),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ItemLogo(icon),
          Flexible(
              child: Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(
              url,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500),
            ),
          ))
        ],
      ),
    );
  }
}

class ItemLogo extends StatefulWidget {
  ItemLogo(this.icon);

  final String? icon;

  @override
  ItemLogoState createState() => ItemLogoState();
}

class ItemLogoState extends State<ItemLogo> {
  bool loadError = false;

  onLoadError(exception, stackTrace) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        loadError = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.icon != null && widget.icon!.isNotEmpty && !loadError) {
      return CircleAvatar(
          radius: 15,
          backgroundColor: Colors.transparent,
          onBackgroundImageError: onLoadError,
          backgroundImage: NetworkImage(
            widget.icon ?? "",
          ),
          child: SizedBox());
    }

    return CircleAvatar(
      radius: 15,
      backgroundColor: Colors.transparent,
      child: SvgPicture.asset(
        'assets/images/webview/icon_web_holder.svg',
        width: 30,
        height: 30,
      ),
    );
  }
}
