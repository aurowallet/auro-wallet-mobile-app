import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auro_wallet/common/consts/browser.dart';
import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/page/browser/components/signTransactionDialog.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/index.dart';
import 'package:auro_wallet/walletSdk/minaSDK.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

class WalletConnectService {
  static const String projectId = WalletConnectProjectId;
  late ReownWalletKit _walletKit;
  final AppStore appStore;
  BuildContext? _context;
  bool _isInitialized = false;
  String? tempScheme;

  final Map<String, PairingMetadata> _sessionMetadata = {};

  WalletConnectService(this.appStore);

  ReownWalletKit get walletKit {
    if (!_isInitialized) {
      throw StateError(
          'WalletConnectService is not initialized. Call init() first.');
    }
    return _walletKit;
  }

  bool get isInitialized => _isInitialized;
  Future<void> testInit(BuildContext context) async {
    _context = context;
  }

  void setTempScheme(String? scheme) {
    tempScheme = scheme;
  }

  Future<void> init(BuildContext context) async {
    if (_isInitialized) return;

    _context = context;

    _walletKit = ReownWalletKit(
      core: ReownCore(
        projectId: projectId,
        logLevel: LogLevel.all,
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
    await _walletKit.init();
    _isInitialized = true;
  }

  List<String> getAllSupportChains() {
    List<String> currentSupportChainList =
        appStore.settings!.getSupportNetworkIDs();
    return currentSupportChainList;
  }

  void _setupListeners() {
    _walletKit.core.addLogListener(_logListener);
    _walletKit.core.pairing.onPairingInvalid.subscribe(_onPairingInvalid);
    _walletKit.core.pairing.onPairingCreate.subscribe(_onPairingCreate);
    _walletKit.core.relayClient.onRelayClientError
        .subscribe(_onRelayClientError);
    _walletKit.core.relayClient.onRelayClientMessage
        .subscribe(_onRelayClientMessage);
    _walletKit.onSessionProposalError.subscribe(_onSessionProposalError);
    _walletKit.onSessionConnect.subscribe(_onSessionConnect);
    _walletKit.onSessionAuthRequest.subscribe(_onSessionAuthRequest);
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

        await UI.showSignTransactionAction(
          context: _context!,
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
          fee: Fmt.isNumber(params?['fee']) ? (params?['fee'].toString()) : "",
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
                result: responseData,
              ),
            );
            handleRedirect(params?["scheme"]);
            return "";
          },
          onCancel: () {
            onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
          },
        );
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

      await UI.showSignatureAction(
        method: event.method,
        context: _context!,
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
              result: data,
            ),
          );
          handleRedirect(params?["scheme"]);
        },
        onCancel: () {
          onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
        },
      );
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
            result: {
              "version": app_version,
              "init": true,
            },
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
              "network": event.chainId == networkIDMap['mainnet']
                  ? "mainnet"
                  : "testnet",
              "publicKey": params["from"],
              "signature": params['signature'],
              "verifyMessage": params["data"],
            };
            bool res = await webApi.account.verifyMessage(
              verifyData,
              context: _context!,
            );
            _walletKit.respondSessionRequest(
              topic: event.topic,
              response: JsonRpcResponse(
                id: event.id,
                jsonrpc: '2.0',
                result: res,
              ),
            );
            break;
          case "mina_verifyFields":
            Map verifyData = {
              "network": event.chainId == networkIDMap['mainnet']
                  ? "mainnet"
                  : "testnet",
              "publicKey": params["from"],
              "signature": params['signature'],
              "fields": params["data"],
            };
            bool res = await webApi.account.verifyFields(
              verifyData,
              context: _context!,
            );
            _walletKit.respondSessionRequest(
              topic: event.topic,
              response: JsonRpcResponse(
                id: event.id,
                jsonrpc: '2.0',
                result: res,
              ),
            );
            break;
          default:
        }
        return;
      } catch (e) {
        print("[aurowallet] onSessionRequest failed, event:  ${event}");
        print("[aurowallet] onSessionRequest failed, error: ${e}");
      }
    }
  }

  void _logListener(String event) {
    debugPrint('[WalletKit] $event');
  }

  void _onRelayClientError(ErrorEvent? args) {
    debugPrint('[WalletConnect] _onRelayClientError ${args?.error}');
  }

  void _onPairingInvalid(PairingInvalidEvent? args) {
    debugPrint('[WalletConnect] _onPairingInvalid $args');
  }

  void _onPairingCreate(PairingEvent? args) {
    debugPrint('[WalletConnect] _onPairingCreate $args');
  }

  void _onRelayClientMessage(MessageEvent? event) async {
    if (event != null) {
      debugPrint('[WalletConnect] _onRelayClientMessage $event');
    }
  }

  void _onSessionProposalError(SessionProposalErrorEvent? args) {
    debugPrint('[WalletConnect] _onSessionProposalError $args');
    if (args != null) {
      String errorMessage = args.error.message;
      if (args.error.code == 5100) {
        errorMessage =
            errorMessage.replaceFirst('Requested:', '\n\nRequested:');
        errorMessage =
            errorMessage.replaceFirst('Supported:', '\n\nSupported:');
      }
    }
  }

  void _onSessionAuthRequest(SessionAuthRequest? args) {
    if (args != null) {
    }
  }

  void _onSessionConnect(SessionConnect? args) {
    if (args != null) {
      debugPrint(
          '[WalletConnect] _onSessionConnect ${jsonEncode(args.session.toJson())}');
    }
  }

  void _onSessionProposal(SessionProposalEvent? args) async {
    debugPrint(
        '[SampleWallet] _onSessionProposal ${jsonEncode(args?.params)}');

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
            "wallet_info"
          ],
          events: ["accountsChanged", "chainChanged"],
        ),
      };
      UI.showConnectAction(
        context: _context!,
        url: proposer.metadata.url,
        iconUrl: proposer.metadata.icons.isNotEmpty
            ? proposer.metadata.icons.first
            : "",
        onConfirm: () async {
          try {
            _sessionMetadata[args.params.pairingTopic] = proposer.metadata;
            await _walletKit.approveSession(
              id: args.id,
              namespaces: defaultNamespaces,
              sessionProperties: args.params.sessionProperties,
            );
            handleRedirect(tempScheme);
          } catch (error) {
            print('showConnectAction===0,${error}');
          }
        },
        onCancel: () async {
          final error = Errors.getSdkError(Errors.USER_REJECTED).toSignError();
          await _walletKit.rejectSession(id: args.id, reason: error);
          await _walletKit.core.pairing
              .disconnect(topic: args.params.pairingTopic);
        },
      );
    }
  }

  void handleRedirect(String? scheme) async {
    if (Platform.isAndroid) {
      if (scheme != null) {
        const MethodChannel _channel = MethodChannel('browser_launcher');
        String targetPackageName = scheme;

        try {
          await _channel
              .invokeMethod('openBrowser', {'packageName': targetPackageName});
        } on PlatformException catch (e) {
          print("Failed to open browser: '${e.message}'");
          UI.showBottomTipDialog(context: _context!);
        }
      }
    }
  }

  Future<void> pair(Uri uri) async {
    PairingInfo info = await _walletKit.pair(uri: uri);
  }

  Future<void> disconnect(String topic) async {
    await _walletKit.core.pairing.disconnect(topic: topic);
  }

  Future<void> clearAllPairings() async {
    final pairings = _walletKit.core.pairing.getPairings();
    for (final pairing in pairings) {
      try {
        await _walletKit.core.pairing.disconnect(topic: pairing.topic);
      } catch (e) {
      }
    }
  }

  List<PairingInfo> getAllPairedLinks() {
    final pairings = _walletKit.core.pairing.getPairings();
    if (pairings.isEmpty) {
      return [];
    }

    // for (var pairing in pairings) {
    //   final metadata = pairing.peerMetadata;
    //   if (metadata != null) {
    //     print('Paired Link Information:');
    //     print('Name: ${metadata.name}');
    //     print('Description: ${metadata.description}');
    //     print('URL: ${metadata.url}');
    //     print('Icons: ${metadata.icons.join(', ')}');
    //     print('Redirect Native: ${metadata.redirect?.native ?? 'N/A'}');
    //     print('Redirect Universal: ${metadata.redirect?.universal ?? 'N/A'}');
    //     print('Topic: ${pairing.topic}');
    //     print(
    //         'Expiry: ${DateTime.fromMillisecondsSinceEpoch(pairing.expiry * 1000)}');
    //     print('---');
    //   }
    // }
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
        final supportedChains = minaNamespace.accounts
            .map((account) =>
                account.split(':')[1]) // Extract chain (e.g., mainnet, devnet)
            .toSet()
            .toList();
        for (var chain in supportedChains) {
          _walletKit.emitSessionEvent(
            topic: topic,
            chainId: 'mina:$chain',
            event: SessionEventParams(
              name: 'accountsChanged',
              data: ['mina:$chain:$newAccount'],
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
