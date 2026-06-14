import 'dart:async';
import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BridgeWebView {
  static const String _bridgePromptMessage = '__AuroBridgeMessage__';

  HeadlessInAppWebView? _web;
  Function? _onLaunched;

  String? _jsCode;
  Map<String, Function> _msgHandlers = {};
  Map<String, Completer> _msgCompleters = {};
  Map<String, Function> _reloadHandlers = {};
  int _evalJavascriptUID = 0;

  bool webViewLoaded = false;
  int jsCodeStarted = -1;
  Timer? _webViewReloadTimer;

  Future<void> launch(
    Function? onLaunched, {
    String? jsCode,
    Function? socketDisconnectedAction,
  }) async {
    /// reset state before webView launch or reload
    _msgHandlers = {};
    _msgCompleters = {};
    _reloadHandlers = {};
    _evalJavascriptUID = 0;
    _onLaunched = onLaunched;
    webViewLoaded = false;
    jsCodeStarted = -1;

    _jsCode = jsCode;

    if (_web == null) {
      _web = new HeadlessInAppWebView(
        windowId: 2,
        initialSettings: InAppWebViewSettings(
          clearCache: true,
          useOnRenderProcessGone: true,
        ),
        onRenderProcessGone: (webView, detail) async {
          if (_web?.webViewController == webView) {
            webViewLoaded = false;
            await InAppWebViewController.clearAllCache();
            await _web?.webViewController?.reload();
          }
        },
        initialUrlRequest: URLRequest(url: WebUri("about:blank")),
        onJsPrompt: (controller, jsPromptRequest) async {
          if (jsPromptRequest.message == _bridgePromptMessage) {
            _handleBridgeMessage(jsPromptRequest.defaultValue ?? '');
            return JsPromptResponse(
              handledByClient: true,
              action: JsPromptResponseAction.CONFIRM,
              value: '',
            );
          }
          return null;
        },
        onWebViewCreated: (controller) async {
          // https://github.com/pichillilorenzo/flutter_inappwebview/issues/586
          await controller.loadFile(
            assetFilePath: "assets/webview/bridge.html",
          );
        },
        onConsoleMessage: (controller, message) {
          if (jsCodeStarted < 0) {
            try {
              final msg = jsonDecode(message.message);
              if (msg['path'] == 'log') {
                if (message.message.contains('js loaded')) {
                  jsCodeStarted = 1;
                } else {
                  jsCodeStarted = 0;
                }
              }
            } catch (err) {
              // ignore
            }
          }
          if (message.message.contains("WebSocket is not connected") &&
              socketDisconnectedAction != null) {
            socketDisconnectedAction();
          }
          if (message.messageLevel != ConsoleMessageLevel.LOG) return;

          // Only try to parse messages that look like JSON (start with '{')
          final msgStr = message.message.trim();
          if (!msgStr.startsWith('{')) return;

          _handleBridgeMessage(msgStr);
        },
        onLoadStop: (controller, url) async {
          if (webViewLoaded) return;

          _handleReloaded();
          await _startJSCode();
        },
      );

      await _web?.dispose();
      await _web?.run();
    } else {
      _webViewReloadTimer = Timer.periodic(Duration(seconds: 3), (timer) {
        _tryReload();
      });
    }
  }

  void _tryReload() {
    if (!webViewLoaded) {
      _web?.webViewController?.reload();
    }
  }

  void _handleReloaded() {
    _webViewReloadTimer?.cancel();
    webViewLoaded = true;
  }

  void _handleBridgeMessage(dynamic rawMessage) {
    try {
      final msg = rawMessage is String ? jsonDecode(rawMessage) : rawMessage;
      if (msg is! Map) return;

      final String? path = msg['path'];
      if (path == null) return;
      if (_msgCompleters[path] != null) {
        Completer handler = _msgCompleters[path]!;
        final data = msg['data'];
        if (data is Map && data['__error'] == true) {
          handler.completeError(
            Exception(data['message'] ?? 'Unknown JS error'),
          );
        } else {
          handler.complete(data);
        }
        if (path.contains('uid=')) {
          _msgCompleters.remove(path);
        }
      }
      if (_msgHandlers[path] != null) {
        Function handler = _msgHandlers[path]!;
        handler(msg['data']);
      }
    } catch (err) {
      // Silently ignore messages that are not bridge payloads.
    }
  }

  Future<void> _startJSCode() async {
    // inject js file to webView
    if (_jsCode != null) {
      await _web!.webViewController?.evaluateJavascript(source: _jsCode!);
    }

    _onLaunched!();
    _reloadHandlers.forEach((_, value) {
      value();
    });
  }

  int getEvalJavascriptUID() {
    return _evalJavascriptUID++;
  }

  Future<dynamic> evalJavascript(
    String code, {
    bool wrapPromise = true,
    bool allowRepeat = true,
  }) async {
    // check if there's a same request loading
    if (!allowRepeat) {
      for (String i in _msgCompleters.keys) {
        String call = code.split('(')[0];
        if (i.contains(call)) {
          return _msgCompleters[i]!.future;
        }
      }
    }

    if (!wrapPromise) {
      final res = await _web!.webViewController?.evaluateJavascript(
        source: code,
      );
      return res;
    }

    final c = new Completer();

    final uid = getEvalJavascriptUID();
    final method = 'uid=$uid;${code.split('(')[0]}';
    _msgCompleters[method] = c;

    final promptMessage = jsonEncode(_bridgePromptMessage);
    final methodName = jsonEncode(method);
    final script =
        '''
Promise.resolve($code).then(function(res) {
  prompt($promptMessage, JSON.stringify({ path: $methodName, data: res }));
}).catch(function(err) {
  prompt($promptMessage, JSON.stringify({
    path: $methodName,
    data: {
      __error: true,
      message: err && err.message ? err.message : "Unknown JS error"
    }
  }));
});
''';
    _web!.webViewController?.evaluateJavascript(source: script).catchError((
      err,
    ) {
      _handleBridgeMessage({
        'path': method,
        'data': {'__error': true, 'message': err.toString()},
      });
    });

    return c.future;
  }

  Future<void> reload() async {
    webViewLoaded = false;
    await InAppWebViewController.clearAllCache();
    return _web?.webViewController?.reload();
  }

  Future<void>? dispose() async {
    return _web?.dispose();
  }
}
