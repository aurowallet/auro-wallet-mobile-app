import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/consts/apiConfig.dart';
import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/common/consts/testKeys.dart';
import 'package:auro_wallet/page/browser/injectedBrowser.dart';
import 'package:auro_wallet/page/homePage.dart';
import 'package:auro_wallet/page/test/testTransactionData.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/screenAwake.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebviewBridgeTestPage extends StatefulWidget {
  WebviewBridgeTestPage();

  static final String route = '/webview/webviewBridgeTest';

  @override
  _WebviewBridgeTestPageState createState() => _WebviewBridgeTestPageState();
}

class _WebviewBridgeTestPageState extends State<WebviewBridgeTestPage> {
  _WebviewBridgeTestPageState();
  AppStore store = globalAppStore;
  static const int _defaultAwakeTestSeconds = 180;

  Map testAccount = {
    "mnemonic":
        "treat unique goddess bone spike inspire accident forum muffin boost drill draw",
    "account0": {
      "priKey": "EKEfKdYoaCeGy4aZoCSam6DdGejrL121HSwFGrckzkLcLqPTMUxW",
      "pubKey": "B62qkVs6zgN84e1KjFxurigqTQ57FqV3KnWubV3t77E9R6uBm4DmkPi",
      "hdIndex": 0,
    }
  };

  bool createWalletStatus = false;
  bool signTransactionStatus = false;
  bool pageCreateWalletStatus = false;
  bool bridgeStressRunning = false;
  bool screenAwakeEnabled = false;
  int awakeCountdown = _defaultAwakeTestSeconds;
  Timer? awakeTimer;
  int bridgeStressRounds = 10;
  String bridgeStressMessage = 'Idle';
  late final String _providerHarnessUrl;
  InAppWebViewController? _providerController;
  Timer? _providerSnapshotTimer;
  Timer? _providerResultTimer;
  String providerStatusMessage = 'Provider harness idle';
  Map<String, dynamic> providerSnapshot = {};
  bool providerResultVisible = false;
  String providerResultTitle = 'Provider Result';
  String providerResultContent = '';
  bool providerResultIsError = false;
  bool providerActionRunning = false;

  String accountA = "B62qpjxUpgdjzwQfd8q2gzxi99wN7SCgmofpvw27MBkfNHfHoY2VH32";
  String accountB = "B62qr2zNMypNKXmzMYSVotChTBRfXzHRtshvbuEjAQZLq6aEa8RxLyD";

  Widget _buildProviderResultOverlay() {
    if (!providerResultVisible || providerResultContent.isEmpty) {
      return SizedBox.shrink();
    }
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxHeight: 220),
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: providerResultIsError ? Color(0xFF2D1F1F) : Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      providerResultTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: _hideProviderResultPanel,
                    icon: Icon(Icons.close, color: Colors.white70, size: 18),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: SelectableText(
                    providerResultContent,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTokenTransferGuideSection() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0x1A000000)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Token Transfer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Use the button below for guidance only.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0x99000000),
              height: 1.4,
            ),
          ),
          SizedBox(height: 14),
          NormalButton(
            text: 'Token Transfer Guide',
            onPressed: _showTokenTransferGuide,
          ),
        ],
      ),
    );
  }

  void _showTokenTransferGuide() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Token Transfer'),
          content: Text('Please perform token transfer on the home page.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  HomePage.route,
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _providerHarnessUrl = Uri.dataFromString(
      _buildProviderHarnessHtml(),
      mimeType: 'text/html',
      encoding: utf8,
    ).toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    awakeTimer?.cancel();
    _providerSnapshotTimer?.cancel();
    _providerResultTimer?.cancel();
    if (screenAwakeEnabled) {
      ScreenAwake.release(ScreenAwakeKeys.webviewBridgeTestPage)
          .catchError((e) => debugPrint('ScreenAwake.release failed: $e'));
    }
    super.dispose();
  }

  void showConfirmDialog(
    String content, {
    String title = 'Reminder',
  }) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 420),
            child: SingleChildScrollView(
              child: SelectableText(content),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Confirm"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  String get _awakeCountdownLabel {
    final minutes = awakeCountdown ~/ 60;
    final seconds = awakeCountdown % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDialogValue(dynamic value) {
    if (value == null) {
      return 'null';
    }
    if (value is Map || value is List) {
      return JsonEncoder.withIndent('  ').convert(value);
    }
    return value.toString();
  }

  String _buildProviderStatusMessage(Map<String, dynamic> snapshot) {
    final ready = snapshot['ready'] == true;
    final lastAction = snapshot['lastAction']?.toString() ?? '';
    final lastError = snapshot['lastError'];
    final lastSettledAt = snapshot['lastSettledAt'];
    if (!ready) {
      return 'Provider harness loading';
    }
    if (lastAction.isEmpty) {
      return 'Provider ready';
    }
    if (lastError != null) {
      return 'Last action: $lastAction failed';
    }
    if (lastSettledAt is num && lastSettledAt > 0) {
      return 'Last action: $lastAction completed';
    }
    return 'Running: $lastAction';
  }

  void _showProviderResultPanel(
    String content, {
    String title = 'Provider Result',
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }
    setState(() {
      providerResultVisible = true;
      providerResultTitle = title;
      providerResultContent = content;
      providerResultIsError = isError;
    });
    _providerResultTimer?.cancel();
    _providerResultTimer = Timer(
      Duration(seconds: isError ? 12 : 7),
      () {
        if (!mounted) {
          return;
        }
        setState(() {
          providerResultVisible = false;
        });
      },
    );
  }

  void _hideProviderResultPanel() {
    _providerResultTimer?.cancel();
    if (!mounted) {
      return;
    }
    setState(() {
      providerResultVisible = false;
    });
  }

  String _buildProviderHarnessHtml() {
    return '''<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
      body {
        margin: 0;
        padding: 12px;
        font-family: -apple-system, BlinkMacSystemFont, sans-serif;
        color: #111827;
        background: #ffffff;
        display: flex;
        align-items: center;
        justify-content: center;
      }

      #status {
        font-size: 12px;
        color: #6b7280;
      }
    </style>
  </head>
  <body>
    <div id="status">Provider harness booting...</div>
    <div id="snapshot-json" style="display:none"></div>
    <div id="log" style="display:none"></div>
    <script>
      (function () {
        const statusEl = document.getElementById('status');
        const snapshotEl = document.getElementById('snapshot-json');
        const logEl = document.getElementById('log');
        const state = {
          ready: false,
          runCount: 0,
          lastSettledAt: 0,
          lastAction: '',
          lastResult: null,
          lastError: null,
          lastEvent: null,
          logs: [],
          results: {},
          eventCounts: {
            accountsChanged: 0,
            chainChanged: 0,
            networkChanged: 0,
          },
          methods: {},
        };

        function safeJson(value) {
          try {
            return JSON.stringify(value);
          } catch (error) {
            return String(value);
          }
        }

        function pushLog(message) {
          state.logs.unshift(message);
          state.logs = state.logs.slice(0, 40);
          logEl.textContent = state.logs.join('\\n');
        }

        function hasMethod(name) {
          return !!(window.mina && typeof window.mina[name] === 'function');
        }

        function refresh() {
          state.ready = !!window.mina;
          state.methods = {
            requestAccounts: hasMethod('requestAccounts'),
            getAccounts: hasMethod('getAccounts'),
            requestNetwork: hasMethod('requestNetwork'),
            getWalletInfo: hasMethod('getWalletInfo'),
            signMessage: hasMethod('signMessage'),
            verifyMessage: hasMethod('verifyMessage'),
            sendPayment: hasMethod('sendPayment'),
            sendStakeDelegation: hasMethod('sendStakeDelegation'),
            sendTransaction: hasMethod('sendTransaction'),
            signFields: hasMethod('signFields'),
            verifyFields: hasMethod('verifyFields'),
            signJsonMessage: hasMethod('signJsonMessage'),
            verifyJsonMessage: hasMethod('verifyJsonMessage'),
            switchChain: hasMethod('switchChain'),
            addChain: hasMethod('addChain'),
            createNullifier: hasMethod('createNullifier'),
            storePrivateCredential: hasMethod('storePrivateCredential'),
            requestPresentation: hasMethod('requestPresentation'),
            revokePermissions: hasMethod('revokePermissions'),
          };
          statusEl.textContent = state.ready ? 'Provider harness ready' : 'Provider harness loading';
          snapshotEl.textContent = JSON.stringify(state);
          return state;
        }

        let eventsAttached = false;

        function attachEvents() {
          if (eventsAttached || !window.mina || typeof window.mina.on !== 'function') {
            return refresh();
          }
          window.mina.on('accountsChanged', function (accounts) {
            state.eventCounts.accountsChanged += 1;
            state.lastEvent = { action: 'accountsChanged', result: accounts };
            pushLog('event accountsChanged: ' + safeJson(accounts));
            refresh();
          });
          window.mina.on('chainChanged', function (chainInfo) {
            state.eventCounts.chainChanged += 1;
            state.lastEvent = { action: 'chainChanged', result: chainInfo };
            pushLog('event chainChanged: ' + safeJson(chainInfo));
            refresh();
          });
          window.mina.on('networkChanged', function (network) {
            state.eventCounts.networkChanged += 1;
            state.lastEvent = { action: 'networkChanged', result: network };
            pushLog('event networkChanged: ' + safeJson(network));
            refresh();
          });
          eventsAttached = true;
          pushLog('provider event listeners attached');
          return refresh();
        }

        async function runAction(name, runner) {
          state.runCount += 1;
          state.lastSettledAt = 0;
          state.lastAction = name;
          state.lastResult = null;
          state.lastError = null;
          pushLog('run ' + name);
          refresh();
          try {
            const result = await runner();
            state.lastResult = result;
            state.lastSettledAt = Date.now();
            state.results[name] = result;
            pushLog('ok ' + name + ': ' + safeJson(result));
            refresh();
            return result;
          } catch (error) {
            const normalized = error && typeof error === 'object'
              ? { message: error.message, code: error.code }
              : { message: String(error) };
            state.lastError = normalized;
            state.lastSettledAt = Date.now();
            pushLog('error ' + name + ': ' + safeJson(normalized));
            refresh();
            throw error;
          }
        }

        window.providerHarness = {
          refresh: function () {
            attachEvents();
            return refresh();
          },
          clearLog: function () {
            state.logs = [];
            state.lastAction = 'clearLog';
            logEl.textContent = '';
            return refresh();
          },
          smoke: function () {
            return runAction('smoke', async function () {
              attachEvents();
              return {
                walletInfo: hasMethod('getWalletInfo') ? await window.mina.getWalletInfo() : 'unavailable',
                requestNetwork: hasMethod('requestNetwork') ? await window.mina.requestNetwork() : 'unavailable',
                getAccounts: hasMethod('getAccounts') ? await window.mina.getAccounts() : 'unavailable',
              };
            });
          },
          invoke: function (name, params) {
            return runAction(name, async function () {
              attachEvents();
              if (!window.mina || typeof window.mina[name] !== 'function') {
                throw new Error('Method not available: ' + name);
              }
              if (params === undefined || params === null) {
                return await window.mina[name]();
              }
              return await window.mina[name](params);
            });
          },
          verifyLastMessage: function () {
            return runAction('verifyMessage', async function () {
              const signed = state.results.signMessage;
              if (!signed) {
                throw new Error('Run signMessage first');
              }
              return await window.mina.verifyMessage({
                data: signed.data,
                signature: JSON.stringify(signed.signature),
              });
            });
          },
          verifyLastJsonMessage: function () {
            return runAction('verifyJsonMessage', async function () {
              const signed = state.results.signJsonMessage;
              if (!signed) {
                throw new Error('Run signJsonMessage first');
              }
              return await window.mina.verifyJsonMessage({
                data: signed.data,
                signature: JSON.stringify(signed.signature),
              });
            });
          },
          verifyLastFields: function () {
            return runAction('verifyFields', async function () {
              const signed = state.results.signFields;
              if (!signed) {
                throw new Error('Run signFields first');
              }
              return await window.mina.verifyFields({
                data: signed.data,
                signature: signed.signature,
              });
            });
          },
          emit: function (action, result) {
            return runAction('emit:' + action, async function () {
              if (typeof window.onAppResponse !== 'function') {
                throw new Error('onAppResponse unavailable');
              }
              window.onAppResponse({ action: action, result: result });
              return { action: action, result: result };
            });
          },
          snapshot: function () {
            attachEvents();
            return refresh();
          },
        };

        setInterval(function () {
          attachEvents();
          refresh();
        }, 1000);

        if (document.readyState === 'loading') {
          document.addEventListener('DOMContentLoaded', function () {
            attachEvents();
            refresh();
          });
        } else {
          attachEvents();
          refresh();
        }
      })();
    </script>
  </body>
</html>
''';
  }

  Map<String, dynamic>? _decodeProviderMap(dynamic raw) {
    if (raw == null) {
      return null;
    }
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    if (raw is String) {
      final normalized = raw.trim();
      if (normalized.isEmpty ||
          normalized == 'null' ||
          normalized == 'undefined') {
        return null;
      }
      try {
        return _decodeProviderMap(jsonDecode(normalized));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<bool> _waitForProviderActionCompletion(
    String expectedAction, {
    required int previousRunCount,
    required int previousSettledAt,
    Duration timeout = const Duration(seconds: 90),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await _pullProviderSnapshot();
      final runCount = (providerSnapshot['runCount'] as num?)?.toInt() ?? 0;
      final lastAction = providerSnapshot['lastAction']?.toString() ?? '';
      final lastSettledAt =
          (providerSnapshot['lastSettledAt'] as num?)?.toInt() ?? 0;
      if (runCount > previousRunCount &&
          lastAction == expectedAction &&
          lastSettledAt > previousSettledAt) {
        return true;
      }
      await Future.delayed(Duration(milliseconds: 300));
    }
    await _pullProviderSnapshot();
    return false;
  }

  void _showProviderActionResultDialog(
    String expectedAction, {
    bool timedOut = false,
  }) {
    final snapshot = providerSnapshot;
    final lastAction = snapshot['lastAction']?.toString() ?? expectedAction;
    final lastError = snapshot['lastError'];
    final lastResult = snapshot['lastResult'];
    final lastEvent = snapshot['lastEvent'];
    final sections = <String>[
      'Action: $lastAction',
      timedOut
          ? 'Status: Timed out waiting for provider response'
          : lastError != null
              ? 'Status: Failed'
              : 'Status: Success',
    ];
    if (lastResult != null) {
      sections.add('Result:\n${_formatDialogValue(lastResult)}');
    }
    if (lastError != null) {
      sections.add('Error:\n${_formatDialogValue(lastError)}');
    }
    if (lastEvent != null && lastAction.startsWith('emit:')) {
      sections.add('Event:\n${_formatDialogValue(lastEvent)}');
    }
    _showProviderResultPanel(
      sections.join('\n\n'),
      title: 'Provider Result',
      isError: timedOut || lastError != null,
    );
  }

  bool _ensureProviderWallet() {
    if (store.wallet == null || store.wallet!.currentAddress.isEmpty) {
      showConfirmDialog('Please create or import a wallet before running provider tests');
      return false;
    }
    return true;
  }

  bool get _isProviderHarnessReady =>
      _providerController != null && providerSnapshot['ready'] == true;

  void _startProviderSnapshotPolling() {
    _providerSnapshotTimer?.cancel();
    _providerSnapshotTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _pullProviderSnapshot();
    });
    _pullProviderSnapshot();
  }

  Future<void> _pullProviderSnapshot() async {
    if (_providerController == null || !mounted) {
      return;
    }
    try {
      await _providerController!.evaluateJavascript(
        source: 'window.providerHarness && window.providerHarness.refresh()',
      );
      final snapshotRaw = await _providerController!.evaluateJavascript(
        source:
            'document.getElementById("snapshot-json") && document.getElementById("snapshot-json").textContent',
      );
      final decodedSnapshot = _decodeProviderMap(snapshotRaw);
      if (!mounted) {
        return;
      }
      if (decodedSnapshot != null) {
        setState(() {
          providerSnapshot = decodedSnapshot;
          providerStatusMessage = _buildProviderStatusMessage(decodedSnapshot);
        });
      }
    } catch (_) {}
  }

  Future<void> _runProviderAction(
    String source,
    String nextStatus, {
    String? expectedAction,
    bool showResultDialog = true,
  }) async {
    if (!_ensureProviderWallet()) {
      return;
    }
    if (_providerController == null) {
      _showProviderResultPanel(
        'Provider harness is not ready yet.',
        title: 'Provider Result',
        isError: true,
      );
      return;
    }
    await _pullProviderSnapshot();
    if (!_isProviderHarnessReady) {
      _showProviderResultPanel(
        'Provider harness is still loading. Please wait until the status shows Provider ready.',
        title: 'Provider Result',
        isError: true,
      );
      return;
    }
    if (providerActionRunning) {
      return;
    }
    final previousRunCount = (providerSnapshot['runCount'] as num?)?.toInt() ?? 0;
    final previousSettledAt =
        (providerSnapshot['lastSettledAt'] as num?)?.toInt() ?? 0;
    bool jsTriggered = false;
    setState(() {
      providerActionRunning = true;
      providerStatusMessage = nextStatus;
    });
    try {
      await _providerController?.evaluateJavascript(source: source);
      jsTriggered = true;
    } catch (error) {
      _showProviderResultPanel(
        error.toString(),
        title: 'Provider Result',
        isError: true,
      );
    } finally {
      if (!jsTriggered) {
      } else if (expectedAction == null) {
        await Future.delayed(Duration(milliseconds: 250));
        await _pullProviderSnapshot();
      } else {
        final completed = await _waitForProviderActionCompletion(
          expectedAction,
          previousRunCount: previousRunCount,
          previousSettledAt: previousSettledAt,
        );
        if (showResultDialog && mounted) {
          _showProviderActionResultDialog(
            expectedAction,
            timedOut: !completed,
          );
        }
      }
      if (mounted) {
        setState(() {
          providerActionRunning = false;
        });
      } else {
        providerActionRunning = false;
      }
    }
  }

  Map<String, dynamic> _providerSendPaymentParams() {
    final params = Map<String, dynamic>.from(
      testTransactionData['signPayment']['testnet']['signParams'],
    );
    return {
      'to': params['toAddress'],
      'amount': '0.01',
      'fee': params['fee'].toString(),
      'memo': params['memo'],
    };
  }

  Map<String, dynamic> _providerStakeDelegationParams() {
    final params = Map<String, dynamic>.from(
      testTransactionData['signStakeTransaction']['testnet']['signParams'],
    );
    return {
      'to': params['toAddress'],
      'fee': params['fee'].toString(),
      'memo': params['memo'],
    };
  }

  Map<String, dynamic> _providerSendTransactionParams() {
    final params = Map<String, dynamic>.from(
      testTransactionData['signZkTransaction']['testnet']['signParams'],
    );
    return {
      'transaction': params['transaction'],
      'fee': params['fee'].toString(),
      'memo': params['memo'],
      'onlySign': true,
    };
  }

  Map<String, dynamic> _providerSignMessageParams() {
    final params = Map<String, dynamic>.from(
      testTransactionData['signMessageTransaction']['testnet']['signParams'],
    );
    return {
      'message': params['message'],
    };
  }

  Map<String, dynamic> _providerSignJsonMessageParams() {
    final params = Map<String, dynamic>.from(
      testTransactionData['signMessageTransaction']['mainnet']['signParams'],
    );
    return {
      'message': jsonDecode(params['message']),
    };
  }

  Map<String, dynamic> _providerSignFieldsParams() {
    final params = Map<String, dynamic>.from(
      testTransactionData['signFiledsData']['testnet']['signParams'],
    );
    return {
      'message': params['message'],
    };
  }

  Map<String, dynamic> _providerCreateNullifierParams() {
    final params = Map<String, dynamic>.from(
      testTransactionData['nullifierData']['testnet']['signParams'],
    );
    return {
      'message': params['message'],
    };
  }

  Map<String, dynamic> _providerSwitchChainParams() {
    final currentNode = store.settings!.currentNode;
    final current = currentNode == null ? '' : currentNode.networkID.toLowerCase();
    final supported = List<String>.from(store.settings!.getSupportNetworkIDs());
    final target = supported.firstWhere(
      (item) => item.toLowerCase() != current,
      orElse: () => current,
    );
    return {
      'networkID': target,
    };
  }

  Map<String, dynamic> _providerAddChainParams() {
    final currentNode = store.settings!.currentNode;
    return {
      'name': currentNode?.name ?? 'Current Node',
      'url': Uri.encodeComponent(currentNode?.url ?? ''),
    };
  }

  Future<void> _reloadProviderHarness() async {
    if (_providerController == null) {
      _showProviderResultPanel(
        'Provider harness is not ready yet.',
        title: 'Provider Result',
        isError: true,
      );
      return;
    }
    if (providerActionRunning) {
      return;
    }
    setState(() {
      providerActionRunning = true;
      providerStatusMessage = 'Reloading provider harness';
    });
    providerSnapshot = {};
    try {
      await _providerController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(_providerHarnessUrl)),
      );
    } finally {
      if (mounted) {
        setState(() {
          providerActionRunning = false;
        });
      } else {
        providerActionRunning = false;
      }
    }
  }

  Future<void> _runProviderSmoke() async {
    await _runProviderAction(
      'window.providerHarness && window.providerHarness.smoke()',
      'Running provider smoke checks',
      expectedAction: 'smoke',
    );
  }

  Future<void> _invokeProviderMethod(String name, [Map<String, dynamic>? params]) async {
    final source = params == null
        ? 'window.providerHarness && window.providerHarness.invoke(${jsonEncode(name)})'
        : 'window.providerHarness && window.providerHarness.invoke(${jsonEncode(name)}, ${jsonEncode(params)})';
    await _runProviderAction(
      source,
      'Running provider.$name',
      expectedAction: name,
    );
  }

  Future<void> _verifyProviderMessage() async {
    await _runProviderAction(
      'window.providerHarness && window.providerHarness.verifyLastMessage()',
      'Running provider.verifyMessage',
      expectedAction: 'verifyMessage',
    );
  }

  Future<void> _verifyProviderJsonMessage() async {
    await _runProviderAction(
      'window.providerHarness && window.providerHarness.verifyLastJsonMessage()',
      'Running provider.verifyJsonMessage',
      expectedAction: 'verifyJsonMessage',
    );
  }

  Future<void> _verifyProviderFields() async {
    await _runProviderAction(
      'window.providerHarness && window.providerHarness.verifyLastFields()',
      'Running provider.verifyFields',
      expectedAction: 'verifyFields',
    );
  }

  Future<void> _emitProviderAccountsChanged() async {
    await _runProviderAction(
      'window.providerHarness && window.providerHarness.emit("accountsChanged", [${jsonEncode(store.wallet!.currentAddress)}])',
      'Emitting accountsChanged',
      expectedAction: 'emit:accountsChanged',
    );
  }

  Future<void> _emitProviderChainChanged() async {
    final payload = {
      'networkID': store.settings!.currentNode?.networkID ?? '',
    };
    await _runProviderAction(
      'window.providerHarness && window.providerHarness.emit("chainChanged", ${jsonEncode(payload)})',
      'Emitting chainChanged',
      expectedAction: 'emit:chainChanged',
    );
  }

  Future<void> _emitProviderNetworkChanged() async {
    await _runProviderAction(
      'window.providerHarness && window.providerHarness.emit("networkChanged", ${jsonEncode(store.settings!.currentNode?.networkID ?? '')})',
      'Emitting networkChanged',
      expectedAction: 'emit:networkChanged',
    );
  }

  Future<void> _clearProviderLog() async {
    await _runProviderAction(
      'window.providerHarness && window.providerHarness.clearLog()',
      'Provider log cleared',
      showResultDialog: false,
    );
  }

  Widget _buildProviderActionButton({
    Key? key,
    required String text,
    required Future<void> Function() onPressed,
  }) {
    return SizedBox(
      width: 164,
      child: OutlinedButton(
        key: key,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(164, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: Color(0x1A000000)),
        ),
        onPressed: providerActionRunning
            ? null
            : () async {
                await onPressed();
              },
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget buildProviderCoverageSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0x1A000000)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Provider Coverage',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Use the buttons below to test provider.js. Results are shown in popups after each action finishes.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
              height: 1.4,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildProviderActionButton(
                key: TestKeys.providerRunAutoButton,
                text: 'Run Provider Smoke',
                onPressed: _runProviderSmoke,
              ),
              _buildProviderActionButton(
                key: TestKeys.providerReloadButton,
                text: 'Reload Harness',
                onPressed: _reloadProviderHarness,
              ),
              _buildProviderActionButton(
                text: 'Get Wallet Info',
                onPressed: () => _invokeProviderMethod('getWalletInfo'),
              ),
              _buildProviderActionButton(
                text: 'Request Network',
                onPressed: () => _invokeProviderMethod('requestNetwork'),
              ),
              _buildProviderActionButton(
                text: 'Get Accounts',
                onPressed: () => _invokeProviderMethod('getAccounts'),
              ),
              _buildProviderActionButton(
                key: TestKeys.providerRequestAccountsButton,
                text: 'Request Accounts',
                onPressed: () => _invokeProviderMethod('requestAccounts'),
              ),
              _buildProviderActionButton(
                key: TestKeys.providerSignMessageButton,
                text: 'Sign Message',
                onPressed: () => _invokeProviderMethod('signMessage', _providerSignMessageParams()),
              ),
              _buildProviderActionButton(
                text: 'Verify Message',
                onPressed: _verifyProviderMessage,
              ),
              _buildProviderActionButton(
                text: 'Sign Json Message',
                onPressed: () => _invokeProviderMethod('signJsonMessage', _providerSignJsonMessageParams()),
              ),
              _buildProviderActionButton(
                text: 'Verify Json Message',
                onPressed: _verifyProviderJsonMessage,
              ),
              _buildProviderActionButton(
                text: 'Sign Fields',
                onPressed: () => _invokeProviderMethod('signFields', _providerSignFieldsParams()),
              ),
              _buildProviderActionButton(
                text: 'Verify Fields',
                onPressed: _verifyProviderFields,
              ),
              _buildProviderActionButton(
                text: 'Send Payment',
                onPressed: () => _invokeProviderMethod('sendPayment', _providerSendPaymentParams()),
              ),
              _buildProviderActionButton(
                text: 'Send Delegation',
                onPressed: () => _invokeProviderMethod('sendStakeDelegation', _providerStakeDelegationParams()),
              ),
              _buildProviderActionButton(
                text: 'Send zk Transaction',
                onPressed: () => _invokeProviderMethod('sendTransaction', _providerSendTransactionParams()),
              ),
              _buildProviderActionButton(
                text: 'Create Nullifier',
                onPressed: () => _invokeProviderMethod('createNullifier', _providerCreateNullifierParams()),
              ),
              _buildProviderActionButton(
                text: 'Switch Chain',
                onPressed: () => _invokeProviderMethod('switchChain', _providerSwitchChainParams()),
              ),
              _buildProviderActionButton(
                text: 'Add Chain',
                onPressed: () => _invokeProviderMethod('addChain', _providerAddChainParams()),
              ),
              _buildProviderActionButton(
                text: 'Revoke Permissions',
                onPressed: () => _invokeProviderMethod('revokePermissions'),
              ),
              _buildProviderActionButton(
                key: TestKeys.providerEmitAccountsChangedButton,
                text: 'Emit Accounts Changed',
                onPressed: _emitProviderAccountsChanged,
              ),
              _buildProviderActionButton(
                key: TestKeys.providerEmitChainChangedButton,
                text: 'Emit Chain Changed',
                onPressed: _emitProviderChainChanged,
              ),
              _buildProviderActionButton(
                key: TestKeys.providerEmitNetworkChangedButton,
                text: 'Emit Network Changed',
                onPressed: _emitProviderNetworkChanged,
              ),
              _buildProviderActionButton(
                key: TestKeys.providerClearLogButton,
                text: 'Clear Provider Log',
                onPressed: _clearProviderLog,
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            key: TestKeys.providerStatus,
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0x14000000)),
            ),
            child: Text(
              providerStatusMessage,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xCC000000),
              ),
            ),
          ),
          SizedBox(height: 12),
          Container(
            height: 72,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0x1A000000)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: WebViewInjected(
              _providerHarnessUrl,
              onGetNewestNonce: () => 0,
              onTxConfirmed: (_) {},
              onRefreshChain: () async {},
              messageOriginFallback: 'https://provider-stability.test',
              onPageFinished: (_, __) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  providerStatusMessage = 'Provider harness loaded';
                });
                _startProviderSnapshotPolling();
              },
              onWebViewCreated: (controller) {
                _providerController = controller;
              },
            ),
          ),
        ],
      ),
    );
  }

  void _startAwakeCountdown({Future<void> Function()? onFinished}) {
    awakeTimer?.cancel();
    setState(() {
      awakeCountdown = _defaultAwakeTestSeconds;
    });
    awakeTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (awakeCountdown <= 1) {
        timer.cancel();
        awakeTimer = null;
        setState(() {
          awakeCountdown = 0;
        });
        if (onFinished != null) {
          await onFinished();
        }
        return;
      }
      setState(() {
        awakeCountdown -= 1;
      });
    });
  }

  Future<void> enableScreenAwakeTest() async {
    await ScreenAwake.acquire(ScreenAwakeKeys.webviewBridgeTestPage);
    if (!mounted) {
      return;
    }
    setState(() {
      screenAwakeEnabled = true;
    });
    _startAwakeCountdown(onFinished: disableScreenAwakeTest);
  }

  Future<void> disableScreenAwakeTest() async {
    awakeTimer?.cancel();
    awakeTimer = null;
    await ScreenAwake.release(ScreenAwakeKeys.webviewBridgeTestPage);
    if (!mounted) {
      return;
    }
    setState(() {
      screenAwakeEnabled = false;
    });
    _startAwakeCountdown();
  }

  Widget buildScreenAwakeTestSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0x1A000000)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Screen Awake Test',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Status: ${screenAwakeEnabled ? 'Enabled' : 'Disabled'}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: screenAwakeEnabled ? Color(0xFF0DB27C) : Color(0xFF808080),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Countdown: $_awakeCountdownLabel',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Set your device auto-lock to 15s or 30s, tap Enable Awake, and compare whether the screen stays on past the system lock timeout.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: NormalButton(
                  text: 'Enable Awake',
                  onPressed: enableScreenAwakeTest,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Color(0x1A000000)),
                  ),
                  onPressed: disableScreenAwakeTest,
                  child: Text(
                    'Disable Awake',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void getSdkVersion() async {
    // 1. get sdk version
    var version = await webApi.bridge.getCurrentSDKVersion();
    print('sdk version = $version');
    showConfirmDialog("Version is: " + version);
  }

  void createWallet() async {
    setState(() {
      createWalletStatus = true;
    });
    var checkFailedCount = 0;

    Map seedType = {"mnemonic": "mnemonic", "priKey": "priKey"};

    var createWalletMneRes = await webApi.bridge
        .createWallet(testAccount["mnemonic"], seedType["mnemonic"]);

    if (createWalletMneRes["pubKey"] != testAccount["account0"]["pubKey"]) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m createWalletMneRes failed: ${jsonEncode(createWalletMneRes)} \u001b[0m');
    }

    var createWalletWithPrivateKey = await webApi.bridge
        .createWalletByMnemonic(testAccount["mnemonic"], 0, true);

    if (createWalletWithPrivateKey["priKey"] !=
        testAccount["account0"]["priKey"]) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m createWalletWithPrivateKey failed: ${jsonEncode(createWalletWithPrivateKey)} \u001b[0m');
    }

    var createWalletPriRes = await webApi.bridge
        .createWallet(testAccount["account0"]["priKey"], "priKey");

    if (createWalletPriRes["pubKey"] != testAccount["account0"]["pubKey"]) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m createWalletPriRes failed: ${jsonEncode(createWalletPriRes)} \u001b[0m');
    }

    var createAccountByPrivateKeyRes = await webApi.bridge
        .createAccountByPrivateKey(testAccount["account0"]["priKey"]);

    if (createAccountByPrivateKeyRes["pubKey"] !=
        testAccount["account0"]["pubKey"]) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m createAccountByPrivateKeyRes failed: ${jsonEncode(createAccountByPrivateKeyRes)} \u001b[0m');
    }
    setState(() {
      createWalletStatus = false;
    });
    if (checkFailedCount > 0) {
      showConfirmDialog(
          "CreateWallet have $checkFailedCount failed, Please check");
    } else {
      showConfirmDialog("CreateWallet all success");
    }
  }

  Future<int> signPayment() async {
    var checkFailedCount = 0;

    /// mainnetTest
    Map signPaymentData = testTransactionData['signPayment'];
    var mainnetSignPaymentRes = await webApi.bridge
        .signPaymentTx(signPaymentData['mainnet']['signParams']);

    Map expectMainnetSignPaymentData = signPaymentData["mainnet"]["signResult"];
    if (mainnetSignPaymentRes["signature"]['field'] !=
            expectMainnetSignPaymentData['signature']['field'] ||
        mainnetSignPaymentRes["signature"]['scalar'] !=
            expectMainnetSignPaymentData['signature']['scalar']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetSignPaymentRes failed: ${jsonEncode(mainnetSignPaymentRes)} \u001b[0m');
    }

    /// testnetTest
    var testnetSignPaymentRes = await webApi.bridge
        .signPaymentTx(signPaymentData['testnet']['signParams']);

    Map expectTestnetSignPaymentData = signPaymentData["testnet"]["signResult"];
    if (testnetSignPaymentRes["signature"]['field'] !=
            expectTestnetSignPaymentData['signature']['field'] ||
        testnetSignPaymentRes["signature"]['scalar'] !=
            expectTestnetSignPaymentData['signature']['scalar']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m testnetSignPaymentRes failed: ${jsonEncode(testnetSignPaymentRes)} \u001b[0m');
    }

    return checkFailedCount;
  }

  Future<int> signStakeDelegation() async {
    var checkFailedCount = 0;

    /// mainnetTest
    Map signStakeTransactionData = testTransactionData['signStakeTransaction'];
    var mainnetSignStakeTransactionRes = await webApi.bridge
        .signStakeDelegationTx(
            signStakeTransactionData['mainnet']['signParams']);
    print('mainnetSignPaymentRes${jsonEncode(mainnetSignStakeTransactionRes)}');

    Map expectMainnetSignStakeTransactionData =
        signStakeTransactionData["mainnet"]["signResult"];
    if (mainnetSignStakeTransactionRes["signature"]['field'] !=
            expectMainnetSignStakeTransactionData['signature']['field'] ||
        mainnetSignStakeTransactionRes["signature"]['scalar'] !=
            expectMainnetSignStakeTransactionData['signature']['scalar']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetSignStakeTransactionRes failed: ${jsonEncode(mainnetSignStakeTransactionRes)} \u001b[0m');
    }

    /// testnetTest
    var testnetSignStakeTransactionRes = await webApi.bridge
        .signStakeDelegationTx(
            signStakeTransactionData['testnet']['signParams']);

    Map expectTestnetSignStakeTransactionData =
        signStakeTransactionData["testnet"]["signResult"];
    if (testnetSignStakeTransactionRes["signature"]['field'] !=
            expectTestnetSignStakeTransactionData['signature']['field'] ||
        testnetSignStakeTransactionRes["signature"]['scalar'] !=
            expectTestnetSignStakeTransactionData['signature']['scalar']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m testnetSignStakeTransactionRes failed: ${jsonEncode(testnetSignStakeTransactionRes)} \u001b[0m');
    }

    return checkFailedCount;
  }

  Future<int> signZkTransaction() async {
    var checkFailedCount = 0;
    Map signZkTransactionData = testTransactionData['signZkTransaction'];

    var testnetSignZkTransactionRes = await webApi.bridge
        .signZkTransaction(signZkTransactionData['testnet']['signParams']);

    Map expectTestnetSignZkTransactionData =
        signZkTransactionData["testnet"]["signResult"];
    if (testnetSignZkTransactionRes["signature"] !=
        expectTestnetSignZkTransactionData['signature']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m testnetSignZkTransactionRes failed: ${jsonEncode(testnetSignZkTransactionRes)} \u001b[0m');
    }

    return checkFailedCount;
  }

  Future<int> signMessage() async {
    var checkFailedCount = 0;

    /// mainnetTest
    Map signData = testTransactionData['signMessageTransaction'];
    var mainnetSignRes =
        await webApi.bridge.signMessage(signData['mainnet']['signParams']);
    print('mainnetSignRes${jsonEncode(mainnetSignRes)}');

    Map expectMainnetSignData = signData["mainnet"]["signResult"];
    if (mainnetSignRes["signature"]['field'] !=
            expectMainnetSignData['signature']['field'] ||
        mainnetSignRes["signature"]['scalar'] !=
            expectMainnetSignData['signature']['scalar']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetSignRes failed: ${jsonEncode(mainnetSignRes)} \u001b[0m');
    }

    /// verifyMessage
    Map mainnetVerifyData = {
      "network": "mainnet",
      "publicKey": mainnetSignRes["publicKey"],
      "signature": mainnetSignRes['signature'],
      "verifyMessage": mainnetSignRes["data"],
    };

    var mainnetVerifyRes = await webApi.bridge.verifyMessage(mainnetVerifyData);
    print('mainnetVerifyRes${jsonEncode(mainnetVerifyRes)}');
    if (!mainnetVerifyRes) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetVerifyRes failed: ${jsonEncode(mainnetVerifyRes)} \u001b[0m');
    }

    /// testnetTest
    var testnetSignRes =
        await webApi.bridge.signMessage(signData['testnet']['signParams']);
    print('testnetSignRes, ${jsonEncode(testnetSignRes)}');

    Map expectTestnetSignData = signData["testnet"]["signResult"];
    if (testnetSignRes["signature"]['field'] !=
            expectTestnetSignData['signature']['field'] ||
        testnetSignRes["signature"]['scalar'] !=
            expectTestnetSignData['signature']['scalar']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m testnetSignRes failed: ${jsonEncode(testnetSignRes)} \u001b[0m');
    }

    /// verifyMessage
    Map testnetVerifyData = {
      "network": "testnet",
      "publicKey": testnetSignRes["publicKey"],
      "signature": testnetSignRes['signature'],
      "verifyMessage": testnetSignRes["data"],
    };

    var testnetVerifyRes = await webApi.bridge.verifyMessage(testnetVerifyData);
    print('testnetVerifyRes, ${jsonEncode(testnetVerifyRes)}');
    if (!testnetVerifyRes) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m testnetVerifyRes failed: ${jsonEncode(testnetVerifyRes)} \u001b[0m');
    }

    return checkFailedCount;
  }

  Future<int> signFields() async {
    var checkFailedCount = 0;

    /// mainnetTest
    Map signData = testTransactionData['signFiledsData'];
    var mainnetSignRes =
        await webApi.bridge.signFields(signData['mainnet']['signParams']);
    print('mainnetSignRes${jsonEncode(mainnetSignRes)}');

    Map expectMainnetSignData = signData["mainnet"]["signResult"];
    if (mainnetSignRes["signature"] != expectMainnetSignData['signature']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetSignRes failed: ${jsonEncode(mainnetSignRes)} \u001b[0m');
    }

    /// verifyFields
    Map mainnetVerifyData = {
      "network": "mainnet",
      "publicKey": mainnetSignRes["publicKey"],
      "signature": mainnetSignRes['signature'],
      "fields": mainnetSignRes["data"],
    };

    var mainnetVerifyRes = await webApi.bridge.verifyFields(mainnetVerifyData);
    print('mainnetVerifyRes, ${jsonEncode(mainnetVerifyRes)}');
    if (!mainnetVerifyRes) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetVerifyRes failed: ${jsonEncode(mainnetVerifyRes)} \u001b[0m');
    }

    /// testnetTest
    var testnetSignRes =
        await webApi.bridge.signFields(signData['testnet']['signParams']);
    print('testnetSignRes${jsonEncode(testnetSignRes)}');

    Map expectTestnetSignData = signData["testnet"]["signResult"];
    if (testnetSignRes["signature"] != expectTestnetSignData['signature']) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m testnetSignRes failed: ${jsonEncode(testnetSignRes)} \u001b[0m');
    }

    /// verifyMessage
    Map testnetVerifyData = {
      "network": "testnet",
      "publicKey": testnetSignRes["publicKey"],
      "signature": testnetSignRes['signature'],
      "fields": testnetSignRes["data"],
    };

    var testnetVerifyRes = await webApi.bridge.verifyFields(testnetVerifyData);
    print('testnetVerifyRes, ${jsonEncode(testnetVerifyRes)}');
    if (!testnetVerifyRes) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m testnetVerifyRes failed: ${jsonEncode(testnetVerifyRes)} \u001b[0m');
    }

    return checkFailedCount;
  }

  Future<int> createNullifier() async {
    var checkFailedCount = 0;
    Map nullifierData = testTransactionData['nullifierData'];

    var mainnetNullifierRes = await webApi.bridge
        .createNullifier(nullifierData['mainnet']['signParams']);

    if (mainnetNullifierRes["private"].isEmpty) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m mainnetNullifierRes failed: ${jsonEncode(mainnetNullifierRes)} \u001b[0m');
    }

    var testnetNullifierRes = await webApi.bridge
        .createNullifier(nullifierData['testnet']['signParams']);

    if (testnetNullifierRes["private"].isEmpty) {
      checkFailedCount++;

      debugPrint(
          '\u001b[31m testnetNullifierRes failed: ${jsonEncode(testnetNullifierRes)} \u001b[0m');
    }

    return checkFailedCount;
  }

  Future<int> _checkCreateWalletOnce() async {
    var checkFailedCount = 0;

    Map seedType = {"mnemonic": "mnemonic", "priKey": "priKey"};

    var createWalletMneRes = await webApi.bridge
        .createWallet(testAccount["mnemonic"], seedType["mnemonic"]);

    if (createWalletMneRes["pubKey"] != testAccount["account0"]["pubKey"]) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m bridge createWalletMneRes failed: ${jsonEncode(createWalletMneRes)} \u001b[0m');
    }

    var createWalletWithPrivateKey =
        await webApi.bridge.createWalletByMnemonic(testAccount["mnemonic"], 0, true);

    if (createWalletWithPrivateKey["priKey"] !=
        testAccount["account0"]["priKey"]) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m bridge createWalletWithPrivateKey failed: ${jsonEncode(createWalletWithPrivateKey)} \u001b[0m');
    }

    var createWalletPriRes =
        await webApi.bridge.createWallet(testAccount["account0"]["priKey"], "priKey");

    if (createWalletPriRes["pubKey"] != testAccount["account0"]["pubKey"]) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m bridge createWalletPriRes failed: ${jsonEncode(createWalletPriRes)} \u001b[0m');
    }

    var createAccountByPrivateKeyRes =
        await webApi.bridge.createAccountByPrivateKey(testAccount["account0"]["priKey"]);

    if (createAccountByPrivateKeyRes["pubKey"] !=
        testAccount["account0"]["pubKey"]) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m bridge createAccountByPrivateKeyRes failed: ${jsonEncode(createAccountByPrivateKeyRes)} \u001b[0m');
    }

    return checkFailedCount;
  }

  Future<int> checkEncryptData() async {
    var checkFailedCount = 0;
    final Map<String, dynamic> payload = {
      "message": "bridge_stability_test",
      "network": "testnet",
      "publicKey": testAccount["account0"]["pubKey"],
      "nonce": "1",
    };

    final encrypted =
        await webApi.bridge.encryptData(jsonEncode(payload), center_public_keys);
    final encryptedData = encrypted['encryptedData'];
    final encryptedAESKey = encrypted['encryptedAESKey'];
    final iv = encrypted['iv'];

    if (encryptedData is! String ||
        encryptedData.isEmpty ||
        encryptedAESKey is! String ||
        encryptedAESKey.isEmpty ||
        iv is! String ||
        iv.isEmpty) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m bridge encryptData invalid payload: ${jsonEncode(encrypted)} \u001b[0m');
      return checkFailedCount;
    }

    if (encryptedData == jsonEncode(payload)) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m bridge encryptData returned plaintext payload \u001b[0m');
    }

    return checkFailedCount;
  }

  Future<int> _expectBridgeReject(
      Future<dynamic> Function() action, String label) async {
    try {
      await action();
      debugPrint(
          '\u001b[31m $label expected rejection but succeeded \u001b[0m');
      return 1;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _expectBridgeErrorResult(
      Future<Map<String, dynamic>> Function() action, String label) async {
    try {
      final res = await action();
      final error = res['error'];
      if (error is Map &&
          error['message'] != null &&
          error['message'].toString().isNotEmpty) {
        return 0;
      }
      debugPrint(
          '\u001b[31m $label expected error result but got: ${jsonEncode(res)} \u001b[0m');
      return 1;
    } catch (error) {
      debugPrint(
          '\u001b[31m $label expected resolved error result but threw: $error \u001b[0m');
      return 1;
    }
  }

  Future<int> _checkBridgeLibNegativeCases() async {
    int checkFailedCount = 0;

    final paymentMissingPrivateKey = Map<String, dynamic>.from(
        testTransactionData['signPayment']['mainnet']['signParams']);
    paymentMissingPrivateKey.remove('privateKey');
    checkFailedCount += await _expectBridgeReject(
      () => webApi.bridge.signPaymentTx(paymentMissingPrivateKey),
      'bridge signPaymentTx missing privateKey',
    );

    final delegationMissingPrivateKey = Map<String, dynamic>.from(
        testTransactionData['signStakeTransaction']['mainnet']['signParams']);
    delegationMissingPrivateKey.remove('privateKey');
    checkFailedCount += await _expectBridgeReject(
      () => webApi.bridge.signStakeDelegationTx(delegationMissingPrivateKey),
      'bridge signStakeDelegationTx missing privateKey',
    );

    final messageMissingPrivateKey = Map<String, dynamic>.from(
        testTransactionData['signMessageTransaction']['mainnet']['signParams']);
    messageMissingPrivateKey.remove('privateKey');
    checkFailedCount += await _expectBridgeReject(
      () => webApi.bridge.signMessage(messageMissingPrivateKey),
      'bridge signMessage missing privateKey',
    );

    final invalidZkPayload = Map<String, dynamic>.from(
        testTransactionData['signZkTransaction']['testnet']['signParams']);
    invalidZkPayload['transaction'] = '{invalid-json';
    checkFailedCount += await _expectBridgeErrorResult(
      () => webApi.bridge.signZkTransaction(invalidZkPayload),
      'bridge signZkTransaction invalid transaction',
    );

    final fieldsMissingPrivateKey = Map<String, dynamic>.from(
        testTransactionData['signFiledsData']['mainnet']['signParams']);
    fieldsMissingPrivateKey.remove('privateKey');
    checkFailedCount += await _expectBridgeReject(
      () => webApi.bridge.signFields(fieldsMissingPrivateKey),
      'bridge signFields missing privateKey',
    );

    final invalidFieldsPayload = Map<String, dynamic>.from(
        testTransactionData['signFiledsData']['mainnet']['signParams']);
    invalidFieldsPayload['message'] = ['invalid-field-value'];
    checkFailedCount += await _expectBridgeErrorResult(
      () => webApi.bridge.signFields(invalidFieldsPayload),
      'bridge signFields invalid message',
    );

    final validMessageSign = await webApi.bridge
        .signMessage(testTransactionData['signMessageTransaction']['mainnet']['signParams']);
    final invalidVerifyMessageRes = await webApi.bridge.verifyMessage({
      'network': 'mainnet',
      'publicKey': validMessageSign['publicKey'],
      'signature': validMessageSign['signature'],
      'verifyMessage': '${validMessageSign['data']}_tampered',
    });
    if (invalidVerifyMessageRes) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m bridge verifyMessage tampered payload should be false \u001b[0m');
    }

    final validFieldsSign = await webApi.bridge
        .signFields(testTransactionData['signFiledsData']['mainnet']['signParams']);
    final tamperedFields = List<dynamic>.from(validFieldsSign['data']);
    tamperedFields[0] = (BigInt.parse(tamperedFields[0].toString()) + BigInt.one)
        .toString();
    final invalidVerifyFieldsRes = await webApi.bridge.verifyFields({
      'network': 'mainnet',
      'publicKey': validFieldsSign['publicKey'],
      'signature': validFieldsSign['signature'],
      'fields': tamperedFields,
    });
    if (invalidVerifyFieldsRes) {
      checkFailedCount++;
      debugPrint(
          '\u001b[31m bridge verifyFields tampered fields should be false \u001b[0m');
    }

    final nullifierMissingPrivateKey = Map<String, dynamic>.from(
        testTransactionData['nullifierData']['mainnet']['signParams']);
    nullifierMissingPrivateKey.remove('privateKey');
    checkFailedCount += await _expectBridgeReject(
      () => webApi.bridge.createNullifier(nullifierMissingPrivateKey),
      'bridge createNullifier missing privateKey',
    );

    final invalidNullifierPayload = Map<String, dynamic>.from(
        testTransactionData['nullifierData']['mainnet']['signParams']);
    invalidNullifierPayload['message'] = ['invalid-field-value'];
    checkFailedCount += await _expectBridgeErrorResult(
      () => webApi.bridge.createNullifier(invalidNullifierPayload),
      'bridge createNullifier invalid message',
    );

    return checkFailedCount;
  }

  Future<int> _runBridgeCheck(
    int round,
    String label,
    int currentFailedCount,
    Future<int> Function() action,
  ) async {
    if (mounted) {
      setState(() {
        bridgeStressMessage =
            'Running $round/$bridgeStressRounds: $label, cumulative failures: $currentFailedCount';
      });
    }
    try {
      return await action();
    } catch (error, stackTrace) {
      debugPrint('\u001b[31m $label threw: $error \u001b[0m');
      debugPrint(stackTrace.toString());
      return 1;
    }
  }

  Future<int> _runBridgeSuiteOnce(int round, int accumulatedFailedCount) async {
    int checkFailedCount = 0;
    if (mounted) {
      setState(() {
        bridgeStressMessage =
            'Running $round/$bridgeStressRounds: sdk version, cumulative failures: $accumulatedFailedCount';
      });
    }
    final version = await webApi.bridge.getCurrentSDKVersion();
    if (version.isEmpty) {
      checkFailedCount++;
      debugPrint('\u001b[31m bridge sdk version empty \u001b[0m');
    }

    checkFailedCount += await _runBridgeCheck(
      round,
      'bridge createWallet suite',
      accumulatedFailedCount + checkFailedCount,
      _checkCreateWalletOnce,
    );
    checkFailedCount += await _runBridgeCheck(
      round,
      'bridge signPayment',
      accumulatedFailedCount + checkFailedCount,
      signPayment,
    );
    checkFailedCount += await _runBridgeCheck(
      round,
      'bridge signStakeDelegation',
      accumulatedFailedCount + checkFailedCount,
      signStakeDelegation,
    );
    checkFailedCount += await _runBridgeCheck(
      round,
      'bridge signZkTransaction',
      accumulatedFailedCount + checkFailedCount,
      signZkTransaction,
    );
    checkFailedCount += await _runBridgeCheck(
      round,
      'bridge signMessage',
      accumulatedFailedCount + checkFailedCount,
      signMessage,
    );
    checkFailedCount += await _runBridgeCheck(
      round,
      'bridge signFields',
      accumulatedFailedCount + checkFailedCount,
      signFields,
    );
    checkFailedCount += await _runBridgeCheck(
      round,
      'bridge createNullifier',
      accumulatedFailedCount + checkFailedCount,
      createNullifier,
    );
    checkFailedCount += await _runBridgeCheck(
      round,
      'bridge encryptData',
      accumulatedFailedCount + checkFailedCount,
      checkEncryptData,
    );
    checkFailedCount += await _runBridgeCheck(
      round,
      'bridge negative cases',
      accumulatedFailedCount + checkFailedCount,
      _checkBridgeLibNegativeCases,
    );
    return checkFailedCount;
  }

  Future<void> runBridgeStabilityStress() async {
    setState(() {
      bridgeStressRunning = true;
      bridgeStressMessage = 'Running 0/$bridgeStressRounds';
    });

    int totalFailed = 0;
    String resultMessage = '';
    final stopwatch = Stopwatch()..start();

    try {
      for (int round = 1; round <= bridgeStressRounds; round++) {
        final roundFailed = await _runBridgeSuiteOnce(round, totalFailed);
        totalFailed += roundFailed;
        if (!mounted) {
          return;
        }
        setState(() {
          bridgeStressMessage =
              'Running $round/$bridgeStressRounds, cumulative failures: $totalFailed';
        });
      }
      stopwatch.stop();
      resultMessage = totalFailed > 0
          ? 'Bridge stress completed in ${stopwatch.elapsed.inSeconds}s with $totalFailed failures'
          : 'Bridge stress all success in ${stopwatch.elapsed.inSeconds}s';
    } catch (error) {
      stopwatch.stop();
      totalFailed += 1;
      resultMessage =
          'Bridge stress interrupted in ${stopwatch.elapsed.inSeconds}s: $error';
    }

    if (!mounted) {
      return;
    }

    setState(() {
      bridgeStressRunning = false;
      bridgeStressMessage = resultMessage;
    });
    showConfirmDialog(resultMessage);
  }

  /// sign all transaction
  void signTransaction() async {
    setState(() {
      signTransactionStatus = true;
    });
    int checkFailedCount = 0;
    int paymentFailedCount = await signPayment();
    checkFailedCount = checkFailedCount + paymentFailedCount;
    int stakeDelegationFailedCount = await signStakeDelegation();
    checkFailedCount = checkFailedCount + stakeDelegationFailedCount;
    int zkFailedCount = await signZkTransaction();
    checkFailedCount = checkFailedCount + zkFailedCount;
    int messageFailedCount = await signMessage();
    checkFailedCount = checkFailedCount + messageFailedCount;
    int fieldsFailedCount = await signFields();
    checkFailedCount = checkFailedCount + fieldsFailedCount;

    int createNullifierFailedCount = await createNullifier();
    checkFailedCount = checkFailedCount + createNullifierFailedCount;

    setState(() {
      signTransactionStatus = false;
    });

    if (checkFailedCount > 0) {
      showConfirmDialog(
          "signTransaction have $checkFailedCount failed, Please check");
    } else {
      showConfirmDialog("signTransaction all success");
    }
  }

  Future<void> createWalletInDev() async {
    setState(() {
      pageCreateWalletStatus = true;
    });
    var isSuccess = await webApi.account.createWalletByPrivateKey("accountName",
        "EKEfKdYoaCeGy4aZoCSam6DdGejrL121HSwFGrckzkLcLqPTMUxW", "Qw1skjaas",
        context: context, source: WalletSource.outside);
    setState(() {
      pageCreateWalletStatus = false;
    });
    print('createWalletInDev: $isSuccess');
    if (isSuccess) {
      showConfirmDialog("Wallet create success");
    } else {
      showConfirmDialog("Wallet create failed");
    }
  }

  // 获取dapp链接
  Future<void> getConnect() async {
    // 获取当前本地存储的 授权链接
    List<String>? list = store.browser?.zkAppConnectingList;
    print('list===list=${list}');
  }

  String generateRandomString(int length) {
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();

    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => characters.codeUnitAt(random.nextInt(characters.length)),
    ));
  }

  // 设置dapp 链接
  Future<void> setConnect() async {
    print('add connect');
    String address = store.wallet!.currentAddress;
    print('setConnect===setConnect__==,${address}');

    String url = "https://test.com/" +
        generateRandomString(5) +
        "_" +
        address.substring(address.length - 5);
    // 添加本地存储的授权链接，如果有就添加
    await store.browser?.addZkAppConnect(store.wallet!.currentAddress, url);
    print('add connect end');
  }

  int generateRandomInt(int max) {
    Random random = Random();
    return random.nextInt(max);
  }

  // 移除dapp链接
  Future<void> removeConnect() async {
    // 按照地址 + 账户移除授权链接 ，先找到当前地址
    // 获取 某一个
    String address = store.wallet!.currentAddress;
    int listLength = store.browser!.zkAppConnectingList.length;
    print('listLength,${listLength}');
    int removeNumber = generateRandomInt(listLength);
    print('removeNumber,${removeNumber}');
    String removeItem = store.browser!.zkAppConnectingList[removeNumber];
    print('removeItem,${removeItem}');
    await store.browser?.removeZkAppConnect(address, removeItem);
    print('remove connect end');
  }

  // 清空dapp链接
  Future<void> clearConnect() async {
    // 清除当前账户所有链接
    // 清除所有账户的所有链接
    String address = store.wallet!.currentAddress;
    await store.browser?.clearZkAppConnect(address);
  }

  // 还有切换账户后的展示
  Future<void> switchAccount() async {
    // 尝试切换账户。看看账户管理的账户，随机切换，并且显示出来
    // B62qpjxUpgdjzwQfd8q2gzxi99wN7SCgmofpvw27MBkfNHfHoY2VH32
// B62qkVs6zgN84e1KjFxurigqTQ57FqV3KnWubV3t77E9R6uBm4DmkPi
// 当前有这两个账户， 随机时候把这两个的后缀加上
    print('switchAccount===0,${store.wallet!.currentAddress}');
    String nextAddress =
        store.wallet!.currentAddress == accountA ? accountB : accountA;
    print('switchAccount===1,${nextAddress}');
    // 获取账户列表
    // 随机切换到 另一个账户，看看是否展示已添加数据
    // 这里就给2个账户，随机切换
    // 获取账户列表
    // webApi.assets.fetchBatchAccountsInfo(
    //       store.wallet!.accountListAll.map((acc) => acc.pubKey).toList());
    // _changeCurrentAccount(account.address != store.wallet!.currentAddress);
    await webApi.account
        .changeCurrentAccount(pubKey: nextAddress, fetchData: true);
    print('switchAccount===2,${store.wallet!.currentAddress}');
    await store.browser?.loadZkAppConnect(nextAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF594AF1),
        title: Text(
          "Webview Bridge Test",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: providerResultVisible ? 140 : 16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    buildScreenAwakeTestSection(),
                    buildProviderCoverageSection(),
                    _buildTokenTransferGuideSection(),
                    Container(
                      key: TestKeys.bridgeStressStatus,
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0x1A000000)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Bridge stress: $bridgeStressMessage',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xCC000000),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: NormalButton(
                        key: TestKeys.bridgeStressButton,
                        text: "Bridge Stability Stress x10",
                        onPressed: runBridgeStabilityStress,
                        submitting: bridgeStressRunning,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: NormalButton(
                        text: "Get Version",
                        onPressed: getSdkVersion,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: NormalButton(
                        text: "Create Wallet",
                        onPressed: createWallet,
                        submitting: createWalletStatus,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: NormalButton(
                        text: "Sign Transaction",
                        onPressed: signTransaction,
                        submitting: signTransactionStatus,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: NormalButton(
                        text: "Page test create wallet",
                        onPressed: createWalletInDev,
                        submitting: pageCreateWalletStatus,
                      ),
                    ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            //   child: NormalButton(
            //     text: "GetConnect",
            //     onPressed: getConnect,
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            //   child: NormalButton(
            //     text: "AddConnect",
            //     onPressed: setConnect,
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            //   child: NormalButton(
            //     text: "RemoveConnect",
            //     onPressed: removeConnect,
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            //   child: NormalButton(
            //     text: "ClearConnect",
            //     onPressed: clearConnect,
            //   ),
            // ),
            // // Switch Account Button
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            //   child: NormalButton(
            //     text: "SwitchAccount",
            //     onPressed: switchAccount,
            //   ),
            // ),
            // Observer to show the current account connections

            // Center(
            //   child: Container(
            //     constraints: BoxConstraints(
            //       minHeight: 200.0,
            //       maxHeight: 300.0,
            //     ),
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.blue, width: 2.0),
            //       borderRadius: BorderRadius.circular(8.0),
            //     ),
            //     child: Expanded(
            //       child: Observer(
            //         builder: (BuildContext context) {
            //           print(
            //               'test zk length=== ${store.browser?.zkAppConnectingList.length}');
            //           return ListView.builder(
            //             shrinkWrap: true,
            //             itemCount:
            //                 store.browser?.zkAppConnectingList.length ?? 0,
            //             itemBuilder: (context, index) {
            //               return Text((index + 1).toString() +
            //                   " : " +
            //                   (store.browser?.zkAppConnectingList[index] ??
            //                       ""));
            //             },
            //           );
            //         },
            //       ),
            //     ),
            //   ),
            // )
                  ],
                ),
              ),
            ),
            _buildProviderResultOverlay(),
          ],
        ),
      ),
    );
  }
}
