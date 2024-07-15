import 'package:auro_wallet/common/consts/settings.dart';

const String ZK_DEFAULT_TOKEN_ID =
    "wSHV2S4qX9jFsLjQo8r1BsMLH2ZRKsZx6EJd1sbozGPieEC4Jf";

Map<String, dynamic> defaultMINAAssets = {
  "tokenAssetInfo": {
    "balance": {
      "total": "0",
      "liquid": "0",
    },
    "inferredNonce": 0,
    "delegateAccount": null,
    "tokenId": ZK_DEFAULT_TOKEN_ID,
    "publicKey": "",
  },
  "tokenNetInfo": null,
  "tokenBaseInfo": {
    "isScam": false,
    "decimals": COIN.decimals.toString(),
    "isMainToken": true,
    "showBalance": 0,
    "showAmount": 0,
  },
  "localConfig": {
    "hideToken": false,
  },
};
