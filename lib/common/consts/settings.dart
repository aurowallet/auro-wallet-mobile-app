export 'package:auro_wallet/common/consts/apiConfig.dart';
import 'package:auro_wallet/common/consts/apiConfig.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';

class COIN {
  static const String coinSymbol = 'MINA';
  static const int decimals = 9;
}

/// graphql for mina
const GraphQLConfig = {
  'httpUri': GRAPH_QL_MAINNET_NODE_URL,
  'wsUri': null,
};

const int mina_token_decimals = 9;

const int SECONDS_OF_DAY = 24 * 60 * 60; // seconds of one day
const int SECONDS_OF_YEAR = 365 * 24 * 60 * 60; // seconds of one year

/// app versions
const String app_version = 'v1.1.8(1119)';

final mainNetNode = CustomNode(
    name: 'Mainnet', url: GRAPH_QL_MAINNET_NODE_URL, networksType: '0');
final devNetNode = CustomNode(
    name: 'Devnet', url: GRAPH_QL_TESTNET_NODE_URL, networksType: '1');

final Map<String, String> languageConfig = {
  "en": 'English',
  "zh": '中文（简体）', 
  "tr": "Türkçe"
};

// ** language contrubute url
final String contributeMoreLanguage = "https://hosted.weblate.org/projects/aurowallet/";