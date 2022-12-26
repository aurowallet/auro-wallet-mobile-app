import 'dart:async';
import 'dart:convert';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/store/settings/types/networkType.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/service/api/apiAccount.dart';
import 'package:auro_wallet/service/api/apiAssets.dart';
import 'package:auro_wallet/service/api/apiStaking.dart';
import 'package:auro_wallet/service/api/apiSetting.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/service/graphql.dart';

// global api instance
late Api webApi;

class Api {
  Api(this.context, this.store);

  final BuildContext context;
  final AppStore store;
  late GraphQLClient graphQLClient;

  final configStorage = GetStorage('configuration');

  late ApiAccount account;
  late ApiAssets assets;
  late ApiStaking staking;
  late ApiSetting setting;

  void init() {
    account = ApiAccount(this);
    assets = ApiAssets(this);
    staking = ApiStaking(this);
    setting = ApiSetting(this);
    graphQLClient = clientFor(uri: store.settings!.endpoint, subscriptionUri: null).value;
    fetchInitialInfo();
  }

  void dispose() {

  }

  void updateGqlClient(String endpoint) {
    graphQLClient = clientFor(uri: endpoint, subscriptionUri: null).value;
  }

  Future<void> fetchInitialInfo() async {
    setting.fetchAboutUs();
    setting.fetchNetworkTypes();
    if (store.wallet!.walletListAll.length > 0) {
      await Future.wait([
        assets.fetchAccountInfo(showIndicator: true),
      ]);
    }
    staking.fetchStakingOverview();
  }

  bool  getIsMainApi () {
    String currentUrl = store.settings!.endpoint;
    // List<NetworkType> networks = store.settings!.networks;
    List<CustomNode> customNodes = store.settings!.customNodeListV2;
    if (store.settings!.endpoint == GRAPH_QL_TESTNET_NODE_URL) {
      return false;
    } else if(store.settings!.endpoint == GRAPH_QL_MAINNET_NODE_URL){
      return true;
    } else { // custom node
      final targetNets = customNodes.where((customNode) => customNode.url == currentUrl);
      if (targetNets.isNotEmpty) {
        CustomNode targetNet = targetNets.first;
        if (targetNet.networksType == '0') { // mainnet
          return true;
        } else if (targetNet.networksType == '1') { // testnet
          return false;
        } else {
          return true;
        }
      } else {
        return true;
      }
    }
  }
  String getTransactionsApiUrl () {
    bool isMain = this.getIsMainApi();
    if (isMain) {
      return MAINNET_TRANSACTION_URL;
    }
    return TESTNET_TRANSACTION_URL;
  }



  String getTxRecordsApiUrl () {
    bool isMain = this.getIsMainApi();
    if (isMain) {
      return MAIN_TX_RECORDS_GQL_URL;
    }
    return TEST_TX_RECORDS_GQL_URL;
  }

  Future<void> refreshNetwork () async {
    assets.fetchAccountInfo();
    staking.refreshStaking();
    assets.fetchPendingTransactions(store.wallet!.currentAddress);
    assets.fetchTransactions(store.wallet!.currentAddress);
  }

  Future<GqlResult> gqlRequest(dynamic options, {required BuildContext context, int timeout = 20}) async {
    QueryResult? result;
    Future<QueryResult> req;
    if (options is MutationOptions) {
      req = graphQLClient.mutate(options);
    } else {
      req = graphQLClient.query(options);
    }
    final Map<String, String> i18n = I18n.of(context).main;
    try {
      result = await req.timeout(
          Duration(seconds: timeout)
      );
    } on TimeoutException catch (_) {
      return GqlResult(result: null, error: true, errorMessage: i18n['timeout']!);
    }
    if (result.hasException) {
      print('gql出错了：'+result.exception.toString());
      String message = '';
      if (result.exception!.graphqlErrors.length > 0) {
        message = result.exception!.graphqlErrors[0].message;
      } else {
        message = i18n['neterror']!;
      }
      return GqlResult(result: null, error: true, errorMessage: message);
    }
    return GqlResult(result: result);
  }

}

class GqlResult {
  GqlResult({this.result, this.error = false, this.errorMessage = ''});
  QueryResult? result;
  final bool error;
  final String errorMessage;
}