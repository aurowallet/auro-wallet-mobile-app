import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LocalWebviewServer {
  InAppLocalhostServer? localhostServer;
  int _currentPort = 8080;
  final int _portRangeStart = 8000;
  final int _portRangeEnd = 8200;

  LocalWebviewServer._internal(this.localhostServer);

  static late final LocalWebviewServer _instance = LocalWebviewServer._internal(null);

  factory LocalWebviewServer() => _instance;

  static LocalWebviewServer getInstance() => _instance;

  Future<String> startLocalServer() async {
    if (await _isPortAvailable(_currentPort)) {
      await _startServerOnPort(_currentPort);
    } else {
      for (int port = _portRangeStart; port <= _portRangeEnd; port++) {
        if (await _isPortAvailable(port)) {
          _currentPort = port;
          await _startServerOnPort(port);
          break;
        }
      }
    }
    return serverUrl;
  }

  Future<bool> _isPortAvailable(int port) async {
    try {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
      await server.close();
      return true;
    } catch (e) {
      print('_isPortAvailable $port is invalid, ${e.toString()}');
      return false;
    }
  }

  Future<void> _startServerOnPort(int port) async {
    if (localhostServer != null && localhostServer!.isRunning()) {
      await localhostServer!.close();
    }
    localhostServer = InAppLocalhostServer(port: port);
    await localhostServer?.start();
    debugPrint('Localhost server started on port $port');
  }

  String get serverUrl => 'http://localhost:$_currentPort/';
}