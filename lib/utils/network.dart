import 'package:auro_wallet/common/consts/apiConfig.dart';
import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/store/settings/types/networkType.dart';

class NetworkUtil {
  static NetworkTypes getNetworkType(String chainId, List<NetworkType> networks) {
    final targetNets = networks.where((NetworkType element) => element.chainId == chainId);
    if (targetNets.isNotEmpty) {
       final targetNet = targetNets.first;
       switch(targetNet.type) {
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

  static String getNetworkName(String endpoint, List<CustomNode> endpoints) {
    if (GRAPH_QL_MAINNET_NODE_URL == endpoint) {
      return 'Mainnet';
    }
    if (GRAPH_QL_TESTNET_NODE_URL == endpoint) {
      return 'Devnet';
    }
    CustomNode? node = endpoints.map((e) => e as CustomNode?).firstWhere((endpointItem)=> endpointItem?.url == endpoint, orElse: () => null);
    if (node != null) {
      return node.name;
    }
    return 'unkonwn';
  }
}