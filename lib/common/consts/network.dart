import 'package:auro_wallet/common/consts/apiConfig.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';

Map<String, String> networkIDMap = {
  "mainnet": "mina:mainnet",
  "testnet": "mina:testnet",
};

extension NetworkIDMapExtension on Map<String, String> {
  String get mainnet => this["mainnet"]!;
  String get testnet => this["testnet"]!;
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
  )
];
