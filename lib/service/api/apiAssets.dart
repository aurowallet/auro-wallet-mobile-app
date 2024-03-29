import 'package:auro_wallet/store/assets/types/scamInfo.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class ApiAssets {
  ApiAssets(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;
  Future<void> fetchTransactions(pubKey) async {
    final client = GraphQLClient(
      link: HttpLink(apiRoot.getTxRecordsApiUrl()),
      cache: GraphQLCache(),
    );
    const String query = r'''
      query fetchTxListQuery($pubKey: String) {
  transactions(limit: 15, sortBy: DATETIME_DESC, query: {canonical: true, 
  OR: [
  {to: $pubKey}, 
  {from: $pubKey}
   ]}) {
    nonce
    memo
    kind
    hash
    from
    fee
    amount
    to
    dateTime
    failureReason
  }
}
    ''';
    final QueryOptions _options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.noCache,
      variables: {
        'pubKey': pubKey,
      },
    );
    final QueryResult result = await client.query(_options);
    if (result.hasException) {
      print('请求tx list 交易出错了');
      print(result.exception.toString());
      return;
    }
    List<dynamic> list = result.data!['transactions'];
    print('transactions');
    print(list.length);
    store.assets!.clearTxs();
    await store.assets!.addTxs(list, pubKey, shouldCache: true);

    // List<dynamic> feeTransferList = result.data!['feetransfers'];
    // print('feetransfers');
    // print(feeTransferList.length);
    // store.assets!.clearFeeTxs();
    // await store.assets!.addFeeTxs(feeTransferList, pubKey, shouldCache: true);
    // cache first page of txs
  }

  Future<void> fetchPendingTransactions(pubKey) async {
    const String query = r'''
      query fetchPendingListQuery($pubKey: PublicKey!) {
        pooledUserCommands(publicKey: $pubKey) {
          id
          nonce
          memo
          isDelegation
          kind
          hash
          from
          feeToken
          fee
          amount
          to
        }
      }
    ''';
    final QueryOptions _options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.noCache,
      variables: {
        'pubKey': pubKey,
      },
    );

    final QueryResult result = await apiRoot.graphQLClient.query(_options);
    if (result.hasException) {
      print('请求pending交易出错了');
      print(result.exception.toString());
      return;
    }
    List<dynamic> list = result.data!['pooledUserCommands'];
    print('pendg list length:${list.length}');
    store.assets!.clearPendingTxs();
    await store.assets!.addPendingTxs(list, pubKey);
  }

  Future<void> queryTxFees() async {
    var feeUrl = "$BASE_INFO_URL/minter_fee.json";
    var response = await http.get(Uri.parse(feeUrl));
    print('fee response' + response.statusCode.toString());
    if (response.statusCode == 200) {
      var feeList = convert.jsonDecode(response.body);
      if (feeList.length >= 5) {
        store.assets!.setFeesMap({
          'slow': double.parse(feeList[0]['value']),
          'medium': double.parse(feeList[1]['value']),
          'fast': double.parse(feeList[2]['value']),
          'cap': double.parse(feeList[3]['value']),
          'speedup': double.parse(feeList[4]['value']),
        });
      }
    } else {
      store.assets!.setFeesMap(
          {'slow': 0.001, 'medium': 0.01, 'fast': 0.1, 'cap': 10.0, 'speedup':0.5});
    }
  }

  Future<void> fetchBatchAccountsInfo(List<String> pubkeys) async {
    var variablesStr = List<String>.generate(
        pubkeys.length, (int index) => '\$account$index:PublicKey!').join(',');

    String fetchBalanceQuery = '''query fetchBalanceQuery($variablesStr) {
${List<String>.generate(pubkeys.length, (int index) {
      return '''account$index: account (publicKey: \$account$index) {
    delegate
    balance {
       total
    }
   inferredNonce
   publicKey
}
''';}).join(',')}
}
      ''';
    Map<String, dynamic> variables = {};
    pubkeys.asMap().forEach((index, pubKey) {
      variables['account$index'] = pubKey;
    });

    final QueryOptions _options = QueryOptions(
      document: gql(fetchBalanceQuery),
      variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
    final QueryResult result = await apiRoot.graphQLClient.query(_options);
    if (result.hasException) {
      print('获取余额出错了');
      print(result.exception.toString());
      return;
    }
    pubkeys.asMap().forEach((index, pubKey) {
      var accountData = result.data?['account$index'];
      if (accountData != null) {
        final String delegate = accountData['delegate'] as String;
        final String balance = accountData['balance']['total'] as String;
        final String inferredNonce = accountData['inferredNonce'] as String;
        final String publicKey = accountData['publicKey'] as String;
        final Map<String, dynamic> accountInfo = {
          "total": balance,
          "delegate": delegate,
          "inferredNonce": inferredNonce,
          "publicKey": publicKey,
        };
        print('balance:' + balance);
        store.assets!.setAccountInfo(pubKey, accountInfo);
      }
    });
  }

  /// get balance and delegate info
  Future<void> fetchAccountInfo({bool showIndicator = false}) async {
    String pubKey = store.wallet!.currentWallet.pubKey;
    if (showIndicator) {
      store.assets!.setBalanceLoading(true);
    }
    _fetchMarketPrice();
    if (pubKey.isNotEmpty) {
      await fetchBatchAccountsInfo([pubKey]);
    }
    store.assets!.setBalanceLoading(false);
  }

  Future<void> _fetchMarketPrice() async {
    if (!store.settings!.isMainnet) {
      return;
    }
    String txUrl = "$MAINNET_TRANSACTION_URL/prices?currency=" +
        store.settings!.currencyCode;
    var response = await http.get(Uri.parse(txUrl));
    if (response.statusCode == 200) {
      Map priceRes =
          convert.jsonDecode(convert.utf8.decode(response.bodyBytes));
      if (priceRes["data"] != null) {
        double price = 0;
        if (priceRes["data"] is int) {
          price = (priceRes["data"] as int).toDouble();
        } else {
          price = priceRes["data"];
        }
        store.assets!.setMarketPrices(COIN.coinSymbol.toLowerCase(), price);
      }
    } else {
      print('Request price failed with status: ${response.statusCode}.');
    }
  }

  Future<void> fetchScamInfo() async {
    if (!store.settings!.isMainnet) {
      return;
    }
    String txUrl = "$BASE_INFO_URL/scam_list";
    var response = await http.get(Uri.parse(txUrl));
    if (response.statusCode == 200) {
      List<dynamic> scamList = convert.jsonDecode(response.body);

      List<ScamItem> scamItemList = scamList.map((item) {
        return ScamItem.fromJson(item);
      }).toList();

      if (scamItemList.length > 0) {
        store.assets!.clearScamList();
        store.assets!.setLocalScamList(scamItemList);
      }
    } else {
      print('Request scam failed with status: ${response.statusCode}.');
    }
  }
}
