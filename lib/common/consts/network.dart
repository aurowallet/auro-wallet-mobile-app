import 'package:auro_wallet/common/consts/apiConfig.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';

Map<String, String> networkIDMap = {
  "mainnet": "mina:mainnet",
  "testnet": "mina:devnet",
  "zekotestnet": "zeko:testnet",
  "zeko": "zeko:mainnet",
};

extension NetworkIDMapExtension on Map<String, String> {
  String get mainnet => this["mainnet"]!;
  String get testnet => this["testnet"]!;
  String get zeko => this["zeko"]!;
  String get zekotestnet => this["zekotestnet"]!;
}

bool isMainnetLikeNetworkID(String? networkID) {
  if (networkID == null || networkID.isEmpty) {
    return false;
  }
  return networkID == networkIDMap.mainnet ||
      networkID == networkIDMap.zeko ||
      networkID.endsWith(':mainnet');
}

bool isZekoNetworkID(String? networkID) {
  return networkID?.startsWith('zeko:') == true;
}

String resolveEffectiveNetworkID(String? networkID, String? currentNetworkID) {
  return networkID?.isNotEmpty == true ? networkID! : currentNetworkID ?? '';
}

String resolveSignerNetwork(String? networkID) {
  if (networkID == networkIDMap.zeko) {
    return "zeko-mainnet";
  }
  return isMainnetLikeNetworkID(networkID) ? "mainnet" : "testnet";
}

final List<CustomNode> defaultNetworkList = [
  CustomNode(
    explorerUrl: MAINNET_TRANSACTIONS_EXPLORER_URL,
    txUrl: MAIN_TX_RECORDS_GQL_URL,
    url: GRAPH_QL_MAINNET_NODE_URL,
    name: "Mainnet",
    isDefaultNode: true,
    networkID: networkIDMap.mainnet,
  ),
  CustomNode(
    explorerUrl: TESTNET_TRANSACTIONS_EXPLORER_URL,
    txUrl: TEST_TX_RECORDS_GQL_URL,
    url: GRAPH_QL_TESTNET_NODE_URL,
    name: "Devnet",
    isDefaultNode: true,
    networkID: networkIDMap.testnet,
  ),
];
