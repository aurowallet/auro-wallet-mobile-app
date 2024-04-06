import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/store/settings/types/networkType.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:graphql_flutter/graphql_flutter.dart';

class ApiSetting {
  ApiSetting(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> fetchAboutUs() async {
    String url =  "$BASE_INFO_URL/about_us.json";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = convert.jsonDecode(response.body) as Map<String, dynamic>;
      store.settings!.setAboutUs(AboutUsData.fromJson(data));
    } else {
      print('Request about us failed with status: ${response.statusCode}.');
    }
  }

  Future<List<NetworkType>> fetchNetworkTypes() async {
    String url =  "$BASE_INFO_URL/network_list.json";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List networks = convert.jsonDecode(response.body);
      List<NetworkType> networkTypes =  networks.map((e)  {
          return NetworkType.fromJson( e as Map<String, dynamic>);
      }).toList();
      await store.settings!.setNetworkTypes(networkTypes, shouldCache: true);
      return networkTypes;
      // store.settings!.setAboutUs(AboutUsData.fromJson(data));
    } else {
      return [];
    }
  }


  Future<String?> fetchChainId(String uri) async {
    const String query = r'''
    query MyQuery { 
      daemonStatus {
        chainId
      }
    }
    ''';
    final QueryOptions _options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.noCache,
      variables: { },
    );
    Link link = HttpLink(uri);
    var graphQLClient = GraphQLClient(
      link: link,
      cache: GraphQLCache()
    );
    final QueryResult result =  await graphQLClient.query(_options);
    if (result.hasException) {
      print('fetch chain id error');
      print(result.exception.toString());
      return null;
    }
    Map<String, dynamic> daemonStatus = result.data!['daemonStatus'];
    String? chainId = daemonStatus['chainId'];
    print('gql chainId:${chainId}');
    if (chainId != null && chainId.isNotEmpty) {
      return chainId;
    }
    return null;
  }
}
