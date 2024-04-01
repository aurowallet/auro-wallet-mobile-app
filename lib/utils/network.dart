import 'package:auro_wallet/common/consts/apiConfig.dart';
import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/store/settings/types/customNodeV2.dart';
import 'package:auro_wallet/store/settings/types/networkType.dart';

class NetworkUtil {
  static NetworkTypes getNetworkType(
      String chainId, List<NetworkType> networks) {
    final targetNets =
        networks.where((NetworkType element) => element.chainId == chainId);
    if (targetNets.isNotEmpty) {
      final targetNet = targetNets.first;
      switch (targetNet.type) {
        case '0':
          return NetworkTypes.mainnet;
        case '1':
          return NetworkTypes.devnet;
        case '11':
          return NetworkTypes.berkeley;
        default:
          return NetworkTypes.unknown;
      }
    }
    return NetworkTypes.unknown;
  }

  static String getNetworkName(CustomNodeV2? endpoint) {
    if (endpoint == null) {
      return 'Unkonwn';
    } else {
      return endpoint.name;
    }
  }
}
