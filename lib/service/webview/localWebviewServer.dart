import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LocalWebviewServer {
  final InAppLocalhostServer? localhostServer;
  Future<void> startLocalServer() async {
    if (localhostServer?.isRunning() == true) {
      HttpClient client = HttpClient();
      HttpClientRequest? request;
      try {
        request = await client.getUrl(Uri.parse('http://localhost:8080/'));
      } catch (error) {
        debugPrint(error.toString());
      }
      final response = await request?.close();
      client.close();
      if (response?.statusCode == 200) {
        return;
      }
    }
    await localhostServer?.close();
    await localhostServer?.start();
  }

  LocalWebviewServer._internal(this.localhostServer);
  factory LocalWebviewServer() => _instance;

  static late final LocalWebviewServer _instance =
      LocalWebviewServer._internal(InAppLocalhostServer());

  static LocalWebviewServer getInstance() => _instance;
}
