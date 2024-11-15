import 'dart:convert' as convert;
import 'dart:convert';

import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/service/api/SslPinningHttpClient.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/types/aboutUsData.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ApiSetting {
  ApiSetting(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> fetchAboutUs() async {
    String url = "$BASE_INFO_URL/about_us.json";
    final client = SslPinningHttpClient.createClient(
        uri: url, nextType: CertificateKeys.auro_api);

    try {
      var response = await client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data =
            convert.jsonDecode(response.body) as Map<String, dynamic>;
        store.settings!.setAboutUs(AboutUsData.fromJson(data));
      } else {
        print('Request about us failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('SSL Pinning failed or other error: $e');
    } finally {
      client.close();
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

  Future<dynamic> getNewestCert(
      String certUrl, CertificateKeys nextType) async {
    var requestUrl = "$BASE_INFO_URL/cert";
    final client = SslPinningHttpClient.createClient(
        uri: requestUrl, nextType: CertificateKeys.auro_api);
    try {
      var response = await client.post(
        Uri.parse(requestUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"url": certUrl}),
      );
      if (response.statusCode == 200) {
        var data = convert.jsonDecode(response.body);
        if (data['cert'] != null) {
          await store.settings!.setCertificatesKeys(nextType, data['cert']);
        }
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      print('getNewestCert Exception: $e');
      return null;
    }
  }
}
