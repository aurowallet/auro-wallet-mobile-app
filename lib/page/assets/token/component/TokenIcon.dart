import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TokenIcon extends StatelessWidget {
  final double size;
  final String iconUrl;
  final String tokenSymbol;
  final bool isMainToken;

  const TokenIcon(
      {Key? key,
      this.size = 30,
      required this.iconUrl,
      required this.tokenSymbol,
      this.isMainToken = false})
      : super(key: key);

  final String holderIconName = "";

  String getHolderIconName() {
    String showIdentityName = tokenSymbol.substring(0, 3);
    showIdentityName = showIdentityName.toUpperCase();
    return showIdentityName;
  }

  @override
  Widget build(BuildContext context) {
    String iconName = getHolderIconName();
    if (isMainToken) {
      return Container(
          child: ClipOval(
              child: SvgPicture.asset(
        iconUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
      )));
    } else {
      Widget defaultIcon = Container(
          child: CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        child: Text(
          iconName.isNotEmpty ? iconName.toUpperCase() : '',
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
        ),
      ));
      return ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: CachedNetworkImage(
              width: size,
              height: size,
              imageUrl: iconUrl.trim(),
              placeholder: (context, url) {
                return defaultIcon;
              },
              errorListener: (value) {
                print('token icon load faile ,$value');
              },
              errorWidget: (context, url, error) {
                return defaultIcon;
              }));
    }
  }
}
