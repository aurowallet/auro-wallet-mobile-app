import 'dart:convert';
import 'dart:convert' as convert;

import 'package:auro_wallet/common/consts/index.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/common/consts/token.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/scamInfo.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/store/assets/types/tokenInfoData.dart';
import 'package:auro_wallet/utils/index.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

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
      print('request tx list error');
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
      print('request pending tx request');
      print(result.exception.toString());
      return;
    }
    List<dynamic> list = result.data!['pooledUserCommands'];
    print('pending list length:${list.length}');
    store.assets!.clearPendingTxs();
    await store.assets!.addPendingTxs(list, pubKey);
  }

  Future<void> fetchPendingZkTransactions(publicKey) async {
    const String query = r'''
      query pendingZkTx($publicKey: PublicKey) {
  pooledZkappCommands(publicKey: $publicKey) {
    hash
    failureReason {
      index
      failures
    }
    zkappCommand {
      feePayer {
        body {
          publicKey
          fee
          validUntil
          nonce
        }
        authorization
      }
      accountUpdates {
        body {
          publicKey
          tokenId
          update {
            appState
            delegate
            verificationKey {
              data
              hash
            }
            permissions {
              editState
              access
              send
              receive
              setDelegate
              setPermissions
              setVerificationKey {
                auth
                txnVersion
              }
              setZkappUri
              editActionState
              setTokenSymbol
              incrementNonce
              setVotingFor
              setTiming
            }
            zkappUri
            tokenSymbol
            timing {
              initialMinimumBalance
              cliffTime
              cliffAmount
              vestingPeriod
              vestingIncrement
            }
            votingFor
          }
          balanceChange {
            magnitude
            sgn
          }
          incrementNonce
          events
          actions
          callData
          callDepth
          preconditions {
            network {
              snarkedLedgerHash
              blockchainLength {
                lower
                upper
              }
              minWindowDensity {
                lower
                upper
              }
              totalCurrency {
                lower
                upper
              }
              globalSlotSinceGenesis {
                lower
                upper
              }
              stakingEpochData {
                ledger {
                  hash
                  totalCurrency {
                    lower
                    upper
                  }
                }
                seed
                startCheckpoint
                lockCheckpoint
                epochLength {
                  lower
                  upper
                }
              }
              nextEpochData {
                ledger {
                  hash
                  totalCurrency {
                    lower
                    upper
                  }
                }
                seed
                startCheckpoint
                lockCheckpoint
                epochLength {
                  lower
                  upper
                }
              }
            }
            account {
              balance {
                lower
                upper
              }
              nonce {
                lower
                upper
              }
              receiptChainHash
              delegate
              state
              actionState
              provedState
              isNew
            }
            validWhile {
              lower
              upper
            }
          }
          useFullCommitment
          implicitAccountCreationFee
          mayUseToken {
            parentsOwnToken
            inheritFromParent
          }
          authorizationKind {
            isSigned
            isProved
            verificationKeyHash
          }
        }
        authorization {
          proof
          signature
        }
      }
      memo
    }
  }
}

    ''';
    final QueryOptions _options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.noCache,
      variables: {
        'publicKey': publicKey,
      },
    );
    final QueryResult result = await apiRoot.graphQLClient.query(_options);
    if (result.hasException) {
      print('zk pending throw error');
      print(result.exception.toString());
      return;
    }
    List<dynamic> list = result.data!['pooledZkappCommands'];
    print('zk pending list length:${list.length}');
    print('zk pending list length=2:${jsonEncode(list)}');
    store.assets!.clearPendingZkTxs();
    await store.assets!.addPendingZkTxs(list, publicKey);
  }

  Future<void> fetchZkTransactions(publicKey,
      {tokenId = ZK_DEFAULT_TOKEN_ID}) async {
    final client = GraphQLClient(
      link: HttpLink(apiRoot.getTxRecordsApiUrl()),
      cache: GraphQLCache(),
    );
    const String query = r'''
      query zkApps($publicKey: String,$tokenId: String) {
    zkapps(limit: 15, query: {
      publicKey: $publicKey,tokenId:$tokenId}, sortBy: DATETIME_DESC) {
        hash
    dateTime
    failureReason {
      failures
    }
    zkappCommand {
      feePayer {
        authorization
        body {
          nonce
          publicKey
          fee
        }
      }
      memo
      accountUpdates {
        body {
          publicKey
          
         	tokenId 
          balanceChange{
            magnitude
            sgn
          }
          update{
            appState
            tokenSymbol
            zkappUri
          }
        }
      }
    }
    }
  }
    ''';
    String nextTokenId = tokenId == ZK_DEFAULT_TOKEN_ID ? "" : tokenId;
    final QueryOptions _options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.noCache,
      variables: {'publicKey': publicKey, 'tokenId': nextTokenId},
    );
    final QueryResult result = await client.query(_options);
    if (result.hasException) {
      print('tx zk list throw error');
      print(result.exception.toString());
      return;
    }
    List<dynamic> list = result.data!['zkapps'];
    print('zk transactions');
    store.assets!.clearZkTxs();
    await store.assets!.addZkTxs(list, publicKey, tokenId, shouldCache: true);
  }

  Future<void> queryTxFees() async {
    var feeUrl = "$BASE_INFO_URL/minter_fee.json";
    var response = await http.get(Uri.parse(feeUrl));
    print('fee response' + response.statusCode.toString());
    if (response.statusCode == 200) {
      var feeList = convert.jsonDecode(response.body);
      if (feeList.length >= 6) {
        store.assets!.setFeesMap({
          'slow': double.parse(feeList[0]['value']),
          'medium': double.parse(feeList[1]['value']),
          'fast': double.parse(feeList[2]['value']),
          'cap': double.parse(feeList[3]['value']),
          'speedup': double.parse(feeList[4]['value']),
          'accountupdate': double.parse(feeList[5]['value']),
        });
      }
    } else {
      store.assets!.setFeesMap(defaultTxFeesMap);
    }
  }

  Future<void> fetchBatchAccountsInfo(List<String> pubkeys) async {
    var variablesStr = List<String>.generate(
        pubkeys.length, (int index) => '\$account$index:PublicKey!').join(',');

    String fetchBalanceQuery = '''query fetchBalanceQuery($variablesStr) {
${List<String>.generate(pubkeys.length, (int index) {
      return '''account$index: account (publicKey: \$account$index) {
    delegateAccount {
        publicKey
      }
    balance {
       total
    }
   inferredNonce
   publicKey
}
''';
    }).join(',')}
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
      print('fetch balance error');
      print(result.exception.toString());
      return;
    }
    pubkeys.asMap().forEach((index, pubKey) {
      var accountData = result.data?['account$index'];
      if (accountData != null) {
        String? delegate;
        if (accountData['delegateAccount'] != null) {
          delegate = accountData['delegateAccount']['publicKey'] as String;
        }
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
      } else {
        store.assets!.setAccountInfo(pubKey, null);
      }
    });
  }

  Future<void> _fetchMarketPrice() async {
    if (!store.settings!.isMainnet) {
      return;
    }
    String txUrl =
        "$BASE_INFO_URL/prices?currency=" + store.settings!.currencyCode;
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
        store.assets!.setMarketPrices(ZK_DEFAULT_TOKEN_ID, price);
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

  Future<int> fetchAccountNonce(String publicKey) async {
    const String fetchNonceQuery =
        r'''query accountNonce($publicKey: PublicKey!) {
    account(publicKey: $publicKey) {
      inferredNonce
    }
  }
        ''';
    Map<String, dynamic> variables = {
      'publicKey': publicKey,
    };

    final QueryOptions _options = QueryOptions(
      document: gql(fetchNonceQuery),
      variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
    final QueryResult result = await apiRoot.graphQLClient.query(_options);
    if (result.hasException) {
      print('fetch nonce error');
      print(result.exception.toString());
      return -1;
    }

    /// -1 is null account
    String nonce = result.data?['account']?['inferredNonce'] ?? "-1";
    print("nonce $nonce");
    return int.parse(nonce);
  }

  Future<List<TokenAssetInfo>> fetchTokenAssets(
    String pubKey,
  ) async {
    const String query = r'''
  query tokenQueryBody($publicKey: PublicKey!) {
    accounts(publicKey: $publicKey) {
      balance {
        total
        liquid
      }
      inferredNonce
      delegateAccount {
        publicKey
      }
      tokenId
      publicKey
      zkappUri
    }
  }
    ''';
    final QueryOptions _options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.noCache,
      variables: {
        'publicKey': pubKey,
      },
    );

    final QueryResult result = await apiRoot.graphQLClient.query(_options);
    if (result.hasException) {
      print('request all token assets failed');
      print(result.exception.toString());
      return [];
    }
    List<dynamic> list = result.data!['accounts'];
    List<TokenAssetInfo> tokenAssets = list.map((item) {
      return TokenAssetInfo.fromJson(item);
    }).toList();
    return tokenAssets;
  }

  String generateTokenInfoQuery(List<String> tokenIds) {
    String queryFields = tokenIds.map((tokenId) {
      return '''
      $tokenId: tokenOwner(tokenId: "$tokenId") {
        publicKey
        tokenSymbol
        zkappState
      }
    ''';
    }).join('\n');

    return '''
    query {
      $queryFields
    }
  ''';
  }

  Future<dynamic> fetchAllTokenInfo(
    List<String> tokenIds,
  ) async {
    String queryFields = generateTokenInfoQuery(tokenIds);

    final QueryOptions _options = QueryOptions(
      document: gql(queryFields),
      fetchPolicy: FetchPolicy.noCache,
      variables: {},
    );

    final QueryResult result = await apiRoot.graphQLClient.query(_options);
    if (result.hasException) {
      print('request all token info failed');
      print(result.exception.toString());
      return [];
    }
    return result.data;
  }

  /// get balance and delegate info
  Future<void> fetchAllTokenAssets({bool showIndicator = false}) async {
    String pubKey = store.wallet!.currentWallet.pubKey;
    if (showIndicator) {
      store.assets!.setBalanceLoading(true);
    }
    _fetchMarketPrice();
    if (pubKey.isNotEmpty) {
      List<TokenAssetInfo> tokenAssets = await fetchTokenAssets(pubKey);
      List<String> tokenIds =
          tokenAssets.map((token) => token.tokenId).toList();
      if (tokenIds.length > 0) {
        dynamic tokenNetInfos = await fetchAllTokenInfo(tokenIds);

        List<Token> tokens = tokenAssets.map((assetInfo) {
          TokenNetInfo? netInfo = tokenNetInfos[assetInfo.tokenId] != null
              ? TokenNetInfo.fromJson(tokenNetInfos[assetInfo.tokenId])
              : null;

          return Token(
            tokenAssestInfo: assetInfo,
            tokenNetInfo: netInfo,
          );
        }).toList();
        store.assets!.updateTokenAssets(tokens, pubKey, shouldCache: true);
      } else {
        store.assets!.updateTokenAssets([], pubKey, shouldCache: true);
      }
    }
    store.assets!.setBalanceLoading(false);
    store.assets!.setAssetsLoading(false);
  }

  Future<dynamic> getTokenState(String pubKey, String tokenId) async {
    const String query = r'''
  query tokenState($publicKey: PublicKey!,$tokenId: TokenId!) {
    account(publicKey: $publicKey, token: $tokenId) {
      balance {
        total
      }
    }
  }
    ''';
    final QueryOptions _options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.noCache,
      variables: {'publicKey': pubKey, 'tokenId': tokenId},
    );

    final QueryResult result = await apiRoot.graphQLClient.query(_options);
    if (result.hasException) {
      print('get token state failed');
      print(result.exception.toString());
      return null;
    }
    Map tokenAccount = result.data!['account'];
    return tokenAccount;
  }

  Future<void> fetchTokenInfo() async {
    String networkId = store.settings?.currentNode?.networkID ?? "";
    String tokenUrl =
        "$BASE_INFO_URL/tokenInfo?networkId=" + getReadableNetworkId(networkId);
    var response = await http.get(Uri.parse(tokenUrl));

    if (response.statusCode == 200) {
      List<dynamic> sourceList = convert.jsonDecode(response.body);
      print('fetchTokenInfo===1,${sourceList.toString()}');
      List<TokenInfoData> tokenInfoList = sourceList.map((item) {
        return TokenInfoData.fromJson(item);
      }).toList();
      store.assets?.setTokenInfoData(tokenInfoList, shouldCache: true);
    } else {
      print('Request token Info failed with status: ${response.statusCode}.');
    }
  }
}
