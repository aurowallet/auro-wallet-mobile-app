import 'dart:convert';
import 'dart:convert' as convert;

import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/service/api/SslPinningHttpClient.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ApiStaking {
  ApiStaking(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> refreshStaking({clearCache: true}) async {
    if (clearCache) {
      store.staking!.setValidatorsInfo([]);
    }
    fetchStakingOverview();
    fetchValidators();
  }

  Future<void> fetchValidators() async {
    if (!store.settings!.isMainnet) {
      store.staking!.setValidatorsInfo([]);
      return;
    }
    String txUrl = "$BASE_INFO_URL/validators";
    final client = SslPinningHttpClient.createClient(
        uri: txUrl, nextType: CertificateKeys.auro_api);

    try {
      var response = await client.get(
        Uri.parse(txUrl),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        List list = convert.jsonDecode(utf8.decode(response.bodyBytes));
        store.staking!.setValidatorsInfo(
          list.map((e) => e as Map<String, dynamic>).toList(),
        );
        print('validators cached: ${list.length}');
      } else {
        print('Request validators failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('SSL Pinning failed or other error: $e');
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> fetchBlockInfo(String stateHash) async {
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
    );
    final QueryResult result = await apiRoot.graphQLClient.query(_options);
    if (result.hasException) {
      print('fetch epoch error');
      print(result.exception.toString());
      return {"epoch": 0, "slot": 0};
    }
    Map consensusState =
        result.data!['block']['protocolState']['consensusState'];
    return {
      "epoch": int.parse(consensusState['epoch']),
      "slot": int.parse(consensusState['slot'])
    };
  }

  Future<void> fetchStakingOverview() async {
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
    );

    final QueryResult result = await apiRoot.graphQLClient.query(_options);
    if (result.hasException) {
      print(result.exception.toString());
      return;
    }
    Map<String, dynamic> daemonStatus = result.data!['daemonStatus'];
    String stateHash = daemonStatus['stateHash'];
    Map consensusState = await fetchBlockInfo(stateHash);
    Map<String, dynamic> overviewData = {
      ...daemonStatus['consensusConfiguration'],
      ...consensusState,
      'stateHash': stateHash,
      'blockchainLength': daemonStatus['daemonStatus'],
    };
    // await fetchDelegationInfo(consensusState['epoch']);
    store.staking!.setOverviewInfo(overviewData);
    print('overview cached');
  }
}
