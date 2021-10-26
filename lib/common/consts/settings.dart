export 'package:auro_wallet/common/consts/apiConfig.dart';
import 'package:auro_wallet/common/consts/apiConfig.dart';

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
const String app_version = 'v1.0.5(1045)';



