import 'package:auro_wallet/common/consts/apiConfig.dart';
import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/store/settings/types/customNodeV2.dart';

Map<NetworkTypes, CustomNodeV2> netConfigMap = {
  NetworkTypes.mainnet: CustomNodeV2(
    netType: NetworkTypes.mainnet,
    explorerUrl: MAINNET_TRANSACTIONS_EXPLORER_URL,
    txUrl: MAIN_TX_RECORDS_GQL_URL,
    url: GRAPH_QL_MAINNET_NODE_URL,
    name: "Mainnet",
    id: "0",
    isDefaultNode: true
  ),
  NetworkTypes.devnet: CustomNodeV2(
    netType: NetworkTypes.devnet,
    explorerUrl: TESTNET_TRANSACTIONS_EXPLORER_URL,
    txUrl: TEST_TX_RECORDS_GQL_URL,
    url: GRAPH_QL_TESTNET_NODE_URL,
    name: "Devnet",
    id: "1",
    isDefaultNode: true
  ),
  NetworkTypes.berkeley: CustomNodeV2(
    netType: NetworkTypes.berkeley,
    explorerUrl: BERKELEY_TRANSACTIONS_EXPLORER_URL,
    txUrl: BERKELEY_TX_RECORDS_GQL_URL,
    url: GRAPH_QL_BERKELEY_NODE_URL,
    name: "Berkeley",
    id: "11",
    isDefaultNode: true
  ),
  NetworkTypes.unknown:
      CustomNodeV2(netType: NetworkTypes.unknown, name: "Unknown", url: ""),
};
