import 'dart:convert' as convert;

import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/types/aboutUsData.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

class ApiSetting {
  ApiSetting(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> fetchAboutUs() async {
    String url = "$BASE_INFO_URL/about_us.json";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> data =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      store.settings!.setAboutUs(AboutUsData.fromJson(data));
    } else {
      print('Request about us failed with status: ${response.statusCode}.');
    }
  }

  Future<String?> fetchNetworkId(String uri) async {
    const String query = r'''
   query MyQuery {
      networkID
    }
    ''';
    final QueryOptions _options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.noCache,
      variables: {},
    );
    Link link = HttpLink(uri);
    var graphQLClient = GraphQLClient(link: link, cache: GraphQLCache());
    final QueryResult result = await graphQLClient.query(_options);
    if (result.hasException) {
      print('fetch network id error');
      print(result.exception.toString());
      return null;
    }
    String? networkID = result.data!['networkID'];
    print('gql networkID:${networkID}');
    if (networkID != null && networkID.isNotEmpty) {
      return networkID;
    }
    return null;
  }
}
