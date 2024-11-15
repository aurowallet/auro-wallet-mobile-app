import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/service/api/SslPinningHttpClient.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

String? uuidFromObject(Object object) {
  if (object is Map<String, Object>) {
    final String typeName = object['__typename'] as String;
    final String id = object['id'].toString();
    if (typeName != null && id != null) {
      return <String>[typeName, id].join('/');
    }
  }
  return null;
}

ValueNotifier<GraphQLClient> clientFor({
  required String uri,
  String? subscriptionUri,
}) {
  Link link;
  Uri nextUri = Uri.parse(uri);
  Client client;
  if (nextUri.host.contains("aurowallet.com") && nextUri.path == "/graphql") {
    client = SslPinningHttpClient.createClient(
        uri: uri, nextType: CertificateKeys.auro_graphql);
  } else if (nextUri.host.contains("zeko.io") && nextUri.path == "/graphql") {
    client = SslPinningHttpClient.createClient(
        uri: uri, nextType: CertificateKeys.zeko_graphql);
  } else {
    client = Client();
  }
  final HttpLink httpLink = HttpLink(
    uri,
    httpClient: client,
  );

  link = httpLink;

  if (subscriptionUri != null) {
    final WebSocketLink websocketLink = WebSocketLink(
      subscriptionUri,
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
      ),
    );

    link = Link.split(
      (request) => request.isSubscription,
      websocketLink,
      httpLink,
    );
  }

  final GraphQLCache cache = GraphQLCache(
    dataIdFromObject: uuidFromObject,
    store: HiveStore(),
  );

  return ValueNotifier<GraphQLClient>(
    GraphQLClient(
      link: link,
      cache: cache,
    ),
  );
}

/// Wraps the root application with the `graphql_flutter` client.
/// We use the cache for all state management.
class ClientProvider extends StatelessWidget {
  ClientProvider({
    required this.child,
    required String uri,
    String? subscriptionUri,
  }) : client = clientFor(
          uri: uri,
          subscriptionUri: subscriptionUri,
        );

  final Widget child;
  final ValueNotifier<GraphQLClient> client;

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: child,
    );
  }
}
