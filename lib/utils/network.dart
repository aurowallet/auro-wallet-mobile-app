import 'package:auro_wallet/common/consts/apiConfig.dart';
import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
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
        default:
          return NetworkTypes.others;
      }
    }
    return NetworkTypes.others;
  }

  static String getNetworkName(CustomNode? endpoint) {
    if (endpoint == null) {
      return 'unkonwn';
    } else {
      return endpoint.name;
    }
  }
}
