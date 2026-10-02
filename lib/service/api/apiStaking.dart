import 'dart:convert';
import 'dart:convert' as convert;

import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

class ApiStaking {
  ApiStaking(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> refreshStaking({clearCache = true}) async {
    if (clearCache) {
      store.staking!.setValidatorsInfo([], []);
    }
    fetchStakingOverview();
    fetchValidators();
    fetchStakingAPR();
  }

  Future<double?> fetchStakingAPR() async {
    if (!store.settings!.isMainnet) {
      // Clear APR when not on mainnet to avoid showing stale mainnet data
      store.staking!.clearStakingAPR();
      return null;
    }
    String url = "$BASE_INFO_URL/staking/apr";
    try {
      var response = await http.get(Uri.parse(url),
          headers: {'Content-Type': 'application/json; charset=utf-8'});
      if (response.statusCode == 200) {
        Map<String, dynamic> data = convert.jsonDecode(utf8.decode(response.bodyBytes));
        double? apr = (data['apr'] as num?)?.toDouble();
        if (apr != null) {
          store.staking!.setStakingAPR(apr);
        }
        return apr;
      }
    } catch (e) {
      print('Request staking APR failed: $e');
    }
    return null;
  }

  Future<void> fetchValidators() async {
    if (!store.settings!.isMainnet) {
      store.staking!.setValidatorsInfo([], []);
      return;
    }
    String txUrl = "$BASE_INFO_URL/validators/v2";
    try {
      var response = await http.get(Uri.parse(txUrl),
          headers: {'Content-Type': 'application/json; charset=utf-8'});
      if (response.statusCode == 200) {
        Map<String, dynamic> data = convert.jsonDecode(utf8.decode(response.bodyBytes));
        List activeList = data['active'] ?? [];
        List inactiveList = data['inactive'] ?? [];
        store.staking!.setValidatorsInfo(
            activeList.map((e) => e as Map<String, dynamic>).toList(),
            inactiveList.map((e) => e as Map<String, dynamic>).toList());
        print('validators cached: active=${activeList.length}, inactive=${inactiveList.length}');
      } else {
        print('Request validators failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Request validators failed: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchBlockInfo(String stateHash,
      {GraphQLClient? client}) async {
    String query = r'''
  query blockInfo($stateHash: String!) {
    block(stateHash: $stateHash) {
      protocolState {
        consensusState {
          epoch
          slot
        }
      }
    }
  }
    ''';
    final QueryOptions _options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.noCache,
      variables: {'stateHash': stateHash},
      queryRequestTimeout: const Duration(seconds: 60)
    );
    final QueryResult result = await (client ?? apiRoot.graphQLClient).query(_options);
    if (result.hasException) {
      print('fetch epoch error');
      print(result.exception.toString());
      return null;
    }
    final consensusState = result.data?['block']?['protocolState']?['consensusState'];
    if (consensusState is! Map) return null;
    return {
      "epoch": int.tryParse(consensusState['epoch'].toString()) ?? -1,
      "slot": int.tryParse(consensusState['slot'].toString()) ?? -1
    };
  }

  Future<void> fetchStakingOverview() async {
    final client = apiRoot.graphQLClient;
    if (store.settings!.isZekoNet) {
      store.staking!.clearOverviewData();
      return;
    }
    const String query = r'''
   query daemonStatus {
    daemonStatus {
      stateHash
      blockchainLength
      consensusConfiguration {
        epochDuration
        slotDuration
        slotsPerEpoch
      }
    }
  }
    ''';
    final QueryOptions _options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.noCache,
      variables: {},
      queryRequestTimeout: const Duration(seconds: 60)
    );

    try {
      final result = await client.query(_options);
      final daemonStatus = result.data?['daemonStatus'];
      if (result.hasException || daemonStatus is! Map ||
          daemonStatus['consensusConfiguration'] is! Map ||
          daemonStatus['stateHash'] is! String) {
        store.staking!.clearOverviewData();
        return;
      }
      final stateHash = daemonStatus['stateHash'] as String;
      final consensusState = await fetchBlockInfo(stateHash, client: client);
      if (consensusState == null || consensusState['epoch'] < 0 || consensusState['slot'] < 0) {
        store.staking!.clearOverviewData();
        return;
      }
      store.staking!.setOverviewInfo({
        ...Map<String, dynamic>.from(daemonStatus['consensusConfiguration']),
        ...consensusState,
        'stateHash': stateHash,
        'blockchainLength': daemonStatus['blockchainLength'],
      });
    } catch (error) {
      store.staking!.clearOverviewData();
      print('Request staking overview failed: $error');
    }
  }
}
