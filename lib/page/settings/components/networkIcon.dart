import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NetworkIcon extends StatelessWidget {
  final CustomNode endpoint;
  final double size;

  const NetworkIcon({
    Key? key,
    this.size = 30,
    required this.endpoint,
  }) : super(key: key);

  String? getNetworkIcon() {
    String? iconUrl;
    if (endpoint.isDefaultNode == true) {
      if (endpoint.networkID == networkIDMap.mainnet) {
        iconUrl = "assets/images/stake/icon_mina_color.svg";
      } else {
        iconUrl = 'assets/images/stake/icon_mina_gray.svg';
      }
    }
    return iconUrl;
  }

  @override
  Widget build(BuildContext context) {
    String? iconUrl = getNetworkIcon();
    String iconName = endpoint.name;
    if (iconUrl != null && iconUrl.isNotEmpty) {
      return Container(
          child: ClipOval(
              child: SvgPicture.asset(
        iconUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
      )));
    } else {
      return Container(
          child: CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        child: Text(
          iconName.isNotEmpty ? iconName[0].toUpperCase() : '',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ));
    }
  }
}
