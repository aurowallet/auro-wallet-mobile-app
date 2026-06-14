import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auro_wallet/common/consts/browser.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/page/browser/components/signTransactionDialog.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/index.dart';
import 'package:auro_wallet/walletSdk/minaSDK.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

class WalletConnectService {
  static const String projectId = WalletConnectProjectId;
  late ReownWalletKit _walletKit;
  final AppStore appStore;
  BuildContext? _context;
  bool _isInitialized = false;
  Future<void>? _initFuture;
  String? tempScheme;

  WalletConnectService(this.appStore);

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  void _debugError(String message, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('$message: $error');
      debugPrint(stackTrace.toString());
    }
  }

  String _preview(String value, {int edge = 8}) {
    if (value.length <= edge * 2) return value;
    return '${value.substring(0, edge)}...${value.substring(value.length - edge)}';
  }

  String _redactWalletConnectValue(String value) {
    return value.replaceAll(RegExp(r'symKey=[^&]+'), 'symKey=<redacted>');
  }

  String _describeUri(Uri uri) {
    final path = uri.path;
    final atIndex = path.indexOf('@');
    final topic = atIndex >= 0 ? path.substring(0, atIndex) : path;
    final version = atIndex >= 0 ? path.substring(atIndex + 1) : null;
    final symKey = uri.queryParameters['symKey'] == null ? 'none' : '<redacted>';
    final uriPreview = _preview(_redactWalletConnectValue(uri.toString()));
    return 'scheme=${uri.scheme}, hasAt=${atIndex >= 0}, version=$version, '
        'topic=${_preview(topic)}, relay=${uri.queryParameters['relay-protocol']}, '
        'symKey=$symKey, uri=$uriPreview';
  }

  String _describeScannedValue(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('wc:')) {
      final uri = Uri.tryParse(trimmed);
      if (uri == null) {
        return 'isWc=true, parseable=false, '
            'value=${_preview(_redactWalletConnectValue(trimmed))}';
      }
      return 'isWc=true, ${_describeUri(uri)}';
    }
    if (Fmt.isAddress(trimmed)) {
      return 'isWc=false, address=${_preview(trimmed)}';
    }
    return 'isWc=false, value=${_preview(trimmed)}';
  }

  void debugLogScannedValue(String source, String value) {
    _debugLog('[WalletConnect] $source: ${_describeScannedValue(value)}');
  }

  void debugLogError(String message, Object error, StackTrace stackTrace) {
    _debugError(message, error, stackTrace);
  }

  ReownWalletKit get walletKit {
    if (!_isInitialized) {
      throw StateError(
          'WalletConnectService is not initialized. Call init() first.');
    }
    return _walletKit;
  }

  bool get isInitialized => _isInitialized;
  void setContext(BuildContext context) async {
    _context = context;
  }

  void setTempScheme(String? scheme) {
    tempScheme = scheme;
  }

  Future<void> init() {
    if (_isInitialized) {
      _debugLog('[WalletConnect] init skipped: already initialized');
      return Future.value();
    }
    final pendingInit = _initFuture;
    if (pendingInit != null) {
      _debugLog('[WalletConnect] init pending: reuse existing future');
      return pendingInit;
    }
    _debugLog('[WalletConnect] init started');
    _initFuture = _init().whenComplete(() {
      _initFuture = null;
    });
    return _initFuture!;
  }

  Future<void> _init() async {
    _walletKit = ReownWalletKit(
      core: ReownCore(
        projectId: projectId,
        logLevel: LogLevel.nothing,
      ),
      metadata: const PairingMetadata(
        name: 'Auro Wallet',
        description: 'Auro Wallet, Mina Protocol',
        url: 'https://www.aurowallet.com/',
        icons: ['https://www.aurowallet.com/imgs/auro.png'],
        redirect: Redirect(
          native: 'aurowallet://',
          universal: 'https://www.aurowallet.com/applinks',
          linkMode: true,
        ),
      ),
    );

    _setupListeners();
    try {
      await _walletKit.init();
    } catch (error, stackTrace) {
      _debugError('[WalletConnect] init failed', error, stackTrace);
      rethrow;
    }
    _isInitialized = true;
    _debugLog('[WalletConnect] init completed');
    getAllPairedLinks();
  }

  List<String> getAllSupportChains() {
    List<String> currentSupportChainList =
        appStore.settings!.getSupportNetworkIDs();
    return currentSupportChainList;
  }

  BuildContext _getValidContext() {
    if (_context != null && _context!.mounted) {
      return _context!;
    }
    final rootContext = WidgetsBinding.instance.rootElement;
    if (rootContext != null && rootContext.mounted) {
      return rootContext;
    }
    throw StateError("[aurowallet] No valid context available for UI trigger");
  }

  void _setupListeners() {
    _walletKit.onSessionProposal.subscribe(_onSessionProposal);
    _walletKit.onSessionRequest.subscribe(onSessionRequest);
  }

  void onHandleErrorReject(SessionRequestEvent? event, int code) {
    if (event != null) {
      _walletKit.respondSessionRequest(
        topic: event.topic,
        response: JsonRpcResponse(
          id: event.id,
          jsonrpc: '2.0',
          error: JsonRpcError(
            code: code,
            message: getMessageFromCode(code),
          ),
        ),
      );
    }
  }

  void onHandleSignTransactionDialog(SessionRequestEvent? event,
      {WalletData? signWallet, PairingMetadata? dAppMetadata}) async {
    if (event != null) {
      Map? params = event.params;
      dynamic signType;
      switch (event.method) {
        case "mina_sendPayment":
          signType = SignTxDialogType.Payment;
          break;
        case "mina_sendStakeDelegation":
          signType = SignTxDialogType.Delegation;
          break;
        case "mina_sendTransaction":
          signType = SignTxDialogType.zkApp;
          break;
        default:
      }

      List<String> checkAddressAction = [
        "mina_sendPayment",
        "mina_sendStakeDelegation"
      ];

      if (checkAddressAction.indexOf(event.method) != -1) {
        if (params?['to'] == null || !ifAddressValid(params?['to'])) {
          onHandleErrorReject(event, ErrorCodes.invalidParams);
          return;
        }
      }

      if (event.method == "mina_sendPayment") {
        if (!Fmt.isNumber(params?['amount'])) {
          onHandleErrorReject(event, ErrorCodes.invalidParams);
          return;
        }
      }

      if (params?['fee'] != null && (params?['fee'] as String).isNotEmpty) {
        if (!Fmt.isNumber(params?['fee'])) {
          onHandleErrorReject(event, ErrorCodes.invalidParams);
          return;
        }
      }
      String toAddress = "";

      if (event.method != "mina_sendTransaction") {
        toAddress = params?['to'];
      }

      if (signType != null) {
        dynamic nextTx = null;
        try {
          if (params?['transaction'] != null) {
            if (params?['transaction'].runtimeType == String) {
              nextTx = params?['transaction'];
            } else {
              nextTx = jsonEncode(params?['transaction']);
            }
          }
        } catch (e) {}

        String? nextChainId;
        if (event.chainId != appStore.settings?.currentNode?.networkID) {
          nextChainId = event.chainId;
        }

        String iconUrl = "";
        String zkUrl = "";
        if (dAppMetadata == null) {
          iconUrl = "";
          zkUrl = "";
        } else {
          iconUrl = dAppMetadata.icons.length > 0 ? dAppMetadata.icons[0] : "";
          zkUrl = dAppMetadata.url;
        }

        final validContext = _getValidContext();
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await UI.showSignTransactionAction(
            context: validContext,
            signType: signType,
            to: toAddress,
            nonce: int.parse(appStore
                    .assets!.mainTokenNetInfo.tokenAssestInfo?.inferredNonce ??
                "0"),
            zkNonce: Fmt.isNumber(params?['nonce'])
                ? (params?['nonce'].toString())
                : "",
            amount: Fmt.isNumber(params?['amount'])
                ? (params?['amount'].toString())
                : "",
            fee:
                Fmt.isNumber(params?['fee']) ? (params?['fee'].toString()) : "",
            memo: params?['memo'],
            transaction: nextTx,
            feePayer: params?['feePayer'],
            onlySign: params?['onlySign'],
            url: zkUrl,
            iconUrl: iconUrl,
            walletConnectChainId: nextChainId,
            signWallet: signWallet,
            fromAddress: params?["from"],
            onConfirm: (Map<String, dynamic> result) async {
              Map<String, dynamic> responseData = {};
              if (params?['onlySign'].runtimeType == bool &&
                  params?['onlySign']) {
                responseData = {"signedData": result['signedData']};
              } else {
                responseData = {
                  "hash": result['hash'],
                  "paymentId": result['paymentId']
                };
              }
              _walletKit.respondSessionRequest(
                topic: event.topic,
                response: JsonRpcResponse(
                  id: event.id,
                  jsonrpc: '2.0',
                  result: jsonEncode(responseData),
                ),
              );
              await Future.delayed(const Duration(milliseconds: 500));
              handleRedirect(params?["scheme"]);
              return "";
            },
            onCancel: () {
              onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
            },
          );
        });
      }
    }
  }

  void onHandleSignMessageDialog(SessionRequestEvent? event,
      {WalletData? signWallet, PairingMetadata? dAppMetadata}) async {
    if (event != null) {
      Map? params = event.params;
      Object message = params?["message"];
      String? nextChainId;
      if (event.chainId != appStore.settings?.currentNode?.networkID) {
        nextChainId = event.chainId;
      }
      String iconUrl = "";
      String zkUrl = "";
      if (dAppMetadata == null) {
        iconUrl = "";
        zkUrl = "";
      } else {
        iconUrl = dAppMetadata.icons.length > 0 ? dAppMetadata.icons[0] : "";
        zkUrl = dAppMetadata.url;
      }
      final validContext = _getValidContext();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await UI.showSignatureAction(
          method: event.method,
          context: validContext,
          content: message,
          iconUrl: iconUrl,
          url: zkUrl,
          walletConnectChainId: nextChainId,
          signWallet: signWallet,
          fromAddress: params?["from"],
          onConfirm: (Map data) async {
            await _walletKit.respondSessionRequest(
              topic: event.topic,
              response: JsonRpcResponse(
                id: event.id,
                jsonrpc: '2.0',
                result: jsonEncode(data),
              ),
            );
            await Future.delayed(const Duration(milliseconds: 500));
            handleRedirect(params?["scheme"]);
            return;
          },
          onCancel: () {
            onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
          },
        );
      });
    }
  }

  void onSessionRequest(SessionRequestEvent? event) async {
    if (event != null) {
      final method = event.method;
      if (method == "wallet_info") {
        _walletKit.respondSessionRequest(
          topic: event.topic,
          response: JsonRpcResponse(
            id: event.id,
            jsonrpc: '2.0',
            result: jsonEncode({
              "version": app_version,
              "init": true,
            }),
          ),
        );
        return;
      }
      if (method == "wallet_revokePermissions") {
        await _walletKit.core.pairing.disconnect(topic: event.topic);
        _walletKit.respondSessionRequest(
          topic: event.topic,
          response: JsonRpcResponse(
            id: event.id,
            jsonrpc: '2.0',
            result: jsonEncode([]),
          ),
        );
        return;
      }

      final params = event.params as Map;
      final fromAddress = params['from'];
      PairingMetadata? dAppMetadata;
      try {
        final session = walletKit.sessions.get(event.topic);
        if (session != null) {
          dAppMetadata = session.peer.metadata;
        }
      } catch (e) {}
      try {
        _getValidContext();
        if (!getAllSupportChains().contains(event.chainId)) {
          onHandleErrorReject(event, ErrorCodes.notSupportChain);
          return;
        }

        List<String> localAccountKeys =
            appStore.wallet!.accountListAll.map((acc) => acc.pubKey).toList();
        if (localAccountKeys.indexOf(params['from']) == -1) {
          onHandleErrorReject(event, ErrorCodes.addressNotExist);
          return;
        }

        WalletData? signWallet;
        if (appStore.wallet!.currentAddress != params['from']) {
          signWallet = appStore.wallet!.walletList.firstWhere((w) =>
              w.accounts
                  .indexWhere((account) => account.pubKey == fromAddress) >=
              0);
        }

        switch (method) {
          case 'mina_signMessage':
          case 'mina_sign_JsonMessage':
          case 'mina_signFields':
          case 'mina_createNullifier':
            onHandleSignMessageDialog(event,
                signWallet: signWallet, dAppMetadata: dAppMetadata);
            break;
          case 'mina_sendPayment':
          case 'mina_sendStakeDelegation':
          case 'mina_sendTransaction':
            onHandleSignTransactionDialog(event,
                signWallet: signWallet, dAppMetadata: dAppMetadata);
            break;
          case "mina_verifyMessage":
          case "mina_verify_JsonMessage":
            Map verifyData = {
              "publicKey": params["from"],
              "signature": params['signature'],
              "verifyMessage": params["data"],
            };
            bool res = await webApi.account.verifyMessage(
              verifyData,
              context: _getValidContext(),
              networkId: event.chainId,
            );
            _walletKit.respondSessionRequest(
              topic: event.topic,
              response: JsonRpcResponse(
                id: event.id,
                jsonrpc: '2.0',
                result: jsonEncode(res),
              ),
            );
            break;
          case "mina_verifyFields":
            Map verifyData = {
              "publicKey": params["from"],
              "signature": params['signature'],
              "fields": params["data"],
            };
            bool res = await webApi.account.verifyFields(
              verifyData,
              context: _getValidContext(),
              networkId: event.chainId,
            );
            _walletKit.respondSessionRequest(
              topic: event.topic,
              response: JsonRpcResponse(
                id: event.id,
                jsonrpc: '2.0',
                result: jsonEncode(res),
              ),
            );
            break;
          default:
        }
        return;
      } catch (_) {
        // Keep request listener failures from escaping the WalletConnect callback.
      }
    }
  }

  void _onSessionProposal(SessionProposalEvent? args) async {
    if (args != null && _context != null) {
      final proposer = args.params.proposer;
      List<String> supportChains = getAllSupportChains();
      List<String> accountsNs = supportChains
          .map((chain) => '$chain:${appStore.wallet!.currentAddress}')
          .toList();

      Map<String, Namespace> defaultNamespaces = {
        'mina': Namespace(
          accounts: accountsNs,
          methods: [
            "mina_sendPayment",
            "mina_sendStakeDelegation",
            "mina_sendTransaction",
            "mina_signMessage",
            "mina_sign_JsonMessage",
            "mina_signFields",
            "mina_createNullifier",
            "mina_verifyMessage",
            "mina_verify_JsonMessage",
            "mina_verifyFields",
            "wallet_info",
            "wallet_revokePermissions"
          ],
          events: ["accountsChanged", "chainChanged"],
        ),
      };
      final validContext = _getValidContext();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UI.showConnectAction(
          context: validContext,
          url: proposer.metadata.url,
          iconUrl: proposer.metadata.icons.isNotEmpty
              ? proposer.metadata.icons.first
              : "",
          onConfirm: () async {
            try {
              await _walletKit.approveSession(
                id: args.id,
                namespaces: defaultNamespaces,
                sessionProperties: args.params.sessionProperties,
              );
              handleRedirect(tempScheme);
            } catch (error) {
              // Keep approval failures local to the connect sheet action.
            }
          },
          onCancel: () async {
            final error =
                Errors.getSdkError(Errors.USER_REJECTED).toSignError();
            await _walletKit.rejectSession(id: args.id, reason: error);
            await _walletKit.core.pairing
                .disconnect(topic: args.params.pairingTopic);
          },
        );
      });
    }
  }

  void handleRedirect(String? scheme) async {
    if (Platform.isAndroid) {
      if (scheme != null && scheme.isNotEmpty) {
        const MethodChannel _channel = MethodChannel('browser_launcher');
        String targetPackageName = scheme;

        try {
          await _channel
              .invokeMethod('openBrowser', {'packageName': targetPackageName});
        } on PlatformException {
          final validContext = _getValidContext();
          UI.showBottomTipDialog(context: validContext);
        }
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      final validContext = _getValidContext();
      UI.showBottomTipDialog(context: validContext);
    }
  }

  Future<void> pair(Uri uri) async {
    _debugLog('[WalletConnect] pair started: ${_describeUri(uri)}');
    try {
      await _walletKit.pair(uri: uri);
      _debugLog('[WalletConnect] pair completed');
    } catch (error, stackTrace) {
      _debugError('[WalletConnect] pair failed', error, stackTrace);
      rethrow;
    }
  }

  Future<void> disconnect(String topic) async {
    await _walletKit.core.pairing.disconnect(topic: topic);
  }

  Future<void> clearAllPairings() async {
    final pairings = _walletKit.core.pairing.getPairings();
    for (final pairing in pairings) {
      try {
        await _walletKit.core.pairing.disconnect(topic: pairing.topic);
      } catch (e) {}
    }
  }

  List<PairingInfo> getAllPairedLinks() {
    final pairings = _walletKit.core.pairing.getPairings();
    if (pairings.isEmpty) {
      return [];
    }

    return pairings;
  }

  Future<void> dispatchEnvelope(String uri) async {
    await _walletKit.dispatchEnvelope(uri);
  }

  /// Emit the `accountsChanged` event to notify the dApp of a change in the selected account.
  Future<void> emitAccountsChanged(String newAccount) async {
    // Get all active sessions
    final sessions = _walletKit.sessions.getAll();
    if (sessions.isEmpty) {
      return;
    }
    // Update the namespace with the new account
    for (var session in sessions) {
      final topic = session.topic;
      final minaNamespace = session.namespaces['mina'];
      if (minaNamespace != null) {
        // Emit the accountsChanged event for each supported chain
        final supportedChainIds = minaNamespace.accounts
            .map((account) {
              final segments = account.split(':');
              if (segments.length >= 2) {
                return '${segments[0]}:${segments[1]}';
              }
              return '';
            })
            .where((chainId) => chainId.isNotEmpty)
            .toSet()
            .toList();
        for (var chainId in supportedChainIds) {
          _walletKit.emitSessionEvent(
            topic: topic,
            chainId: chainId,
            event: SessionEventParams(
              name: 'accountsChanged',
              data: ['$chainId:$newAccount'],
            ),
          );
        }
      }
    }
  }

  /// Emit the `chainChanged` event to notify the dApp of a change in the selected chain.
  Future<void> emitChainChanged(String newChainId) async {
    final sessions = _walletKit.sessions.getAll();
    if (sessions.isEmpty) {
      return;
    }
    // Emit the chainChanged event for each session
    for (var session in sessions) {
      final topic = session.topic;
      final minaNamespace = session.namespaces['mina'];
      if (minaNamespace != null) {
        _walletKit.emitSessionEvent(
          topic: topic,
          chainId: newChainId,
          event: SessionEventParams(
            name: 'chainChanged',
            data: newChainId,
          ),
        );
      }
    }
  }
}
