import 'dart:async';
import 'dart:convert';

import 'package:auro_wallet/common/consts/browser.dart';
import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/page/browser/components/signTransactionDialog.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/types/customNodeV2.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/index.dart';
import 'package:auro_wallet/utils/network.dart';
import 'package:auro_wallet/walletSdk/minaSDK.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewInjected extends StatefulWidget {
  WebViewInjected(
    this.initialUrl, {
    required this.onTxConfirmed,
    required this.onGetNewestNonce,
    this.onPageFinished,
    this.onWebViewCreated,
  });

  final String initialUrl;

  final Function(bool, bool)? onPageFinished;
  final Function(WebViewController)? onWebViewCreated;
  final Function(int) onTxConfirmed;
  final int Function() onGetNewestNonce;

  @override
  _WebViewInjectedState createState() => _WebViewInjectedState();
}

class _WebViewInjectedState extends State<WebViewInjected> {
  _WebViewInjectedState();
  final store = globalAppStore;

  late WebViewController _controller;
  bool _signing = false;
  double loadProcess = 0.0;

  Future<dynamic> _responseToZkApp(String method, Map resData) async {
    print('respond ${method} to zkApp:');
    print(resData);
    _signing = false;
    return _controller.runJavaScript("onAppResponse(${jsonEncode(resData)})");
  }

  void onHandleErrorReject(String method, String id, int code) {
    Map<String, dynamic> rejectData = {
      "result": {
        "code": code,
        "message": getMessageFromCode(code),
      },
      "id": id
    };
    _responseToZkApp(method, rejectData);
  }

  void onHandleSignTxDialog(String method, bool isConnect, Map payload) async {
    if (!isConnect) {
      onHandleErrorReject(method, payload['id'], ErrorCodes.userDisconnect);
      return;
    }
    if (_signing) {
      return;
    }
    _signing = true;
    Map? params = payload['params'];
    Map? siteInfo = payload['site'];
    dynamic signType;
    switch (method) {
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

    if (checkAddressAction.indexOf(method) != -1) {
      if (params?['to'].length <= 0 || !ifAddressValid(params?['to'])) {
        onHandleErrorReject(method, payload['id'], ErrorCodes.invalidParams);
        return;
      }
    }

    if (method == "mina_sendPayment") {
      if (!Fmt.isNumber(params?['amount'])) {
        onHandleErrorReject(method, payload['id'], ErrorCodes.invalidParams);
        return;
      }
    }

    if (params?['fee'] != null && (params?['fee'] as String).isNotEmpty) {
      if (!Fmt.isNumber(params?['fee'])) {
        onHandleErrorReject(method, payload['id'], ErrorCodes.invalidParams);
        return;
      }
    }
    String toAddress = "";

    if (method != "mina_sendTransaction") {
      toAddress = params!['to'];
    }
    if (signType != null) {
      await UI.showSignTransactionAction(
        context: context,
        signType: signType,
        to: toAddress,
        nonce: widget.onGetNewestNonce(),
        amount: params!['amount'],
        fee: params['fee'],
        memo: params['memo'],
        transaction: params['transaction'],
        feePayer: params['feePayer'],
        url: siteInfo!['origin'],
        iconUrl: siteInfo!['webIcon'],
        onConfirm: (String hash, int nonce) async {
          Map<String, dynamic> resData = {
            "result": {"hash": hash},
            "id": payload['id']
          };
          if (hash.isNotEmpty) {
            widget.onTxConfirmed(nonce);
          }
          _responseToZkApp(method, resData);
          return "";
        },
        onCancel: () {
          onHandleErrorReject(
              method, payload['id'], ErrorCodes.userRejectedRequest);
        },
      );
    }
  }

  void onHandleSignMessageDialog(
      String method, bool isConnect, Map payload) async {
    if (!isConnect) {
      onHandleErrorReject(method, payload['id'], ErrorCodes.userDisconnect);
      return;
    }
    if (_signing) {
      return;
    }
    _signing = true;
    Map? params = payload['params'];
    Map? siteInfo = payload['site'];

    Object message = params!["message"];

    await UI.showSignatureAction(
      method: method,
      context: context,
      content: message,
      url: siteInfo!['origin'],
      iconUrl: siteInfo!['webIcon'],
      onConfirm: (Map data) async {
        Map<String, dynamic> resData = {"result": data, "id": payload['id']};
        _responseToZkApp(method, resData);
        Navigator.of(context).pop();
        return;
      },
      onCancel: () {
        onHandleErrorReject(
            method, payload['id'], ErrorCodes.userRejectedRequest);
      },
    );
  }

  void saveConnectStatus(url) {
    store.browser!.addConnectConfig(url, store.wallet!.currentAddress);
  }

  Future<void> switchChainByUrl(String method, Map<dynamic, dynamic> siteInfo,
      String id, String realUrl) async {
    _signing = true;
    await UI.showSwitchChainAction(
        context: context,
        chainId: "",
        url: siteInfo!['origin'],
        iconUrl: siteInfo!['webIcon'],
        gqlUrl: realUrl,
        onConfirm: (String networkName, String chainId) async {
          Map chainInfoArgs = {
            "chainId": chainId,
            "name": networkName,
          };
          Map<String, dynamic> resData = {"result": chainInfoArgs, "id": id};
          _responseToZkApp(method, resData);
          return;
        },
        onCancel: () {
          onHandleErrorReject(method, id, ErrorCodes.userRejectedRequest);
        });
  }

  Future<dynamic> _msgHandler(Map msg) async {
    final String method = msg['action'];
    Map payload = msg['payload'];
    Map? siteInfo = payload['site'];
    Map? params = payload['params'];

    String currentAccountAddress = store.wallet!.currentAddress;
    bool isConnect = (store
            .browser!.browserConnectingList[currentAccountAddress]
            ?.contains(siteInfo?['origin']) ??
        false);
    String network = store.settings!.isMainnet ? "mainnet" : "testnet";
    switch (method) {
      case "mina_requestAccounts":
        if (isConnect) {
          Map<String, dynamic> resData = {
            "result": [currentAccountAddress],
            "id": payload['id']
          };
          _responseToZkApp(method, resData);
          return;
        }
        if (_signing) break;
        _signing = true;
        await UI.showConnectAction(
          context: context,
          url: siteInfo?['origin'],
          iconUrl: siteInfo?['webIcon'],
          onConfirm: () async {
            Map<String, dynamic> resData = {
              "result": [currentAccountAddress],
              "id": payload['id']
            };
            store.browser!
                .addConnectConfig(siteInfo?['origin'], currentAccountAddress);
            _responseToZkApp(method, resData);
          },
          onCancel: () {
            onHandleErrorReject(
                method, payload['id'], ErrorCodes.userRejectedRequest);
          },
        );
        break;
      case "mina_accounts":
        Map<String, dynamic> resData = {
          "result": isConnect ? [currentAccountAddress] : [],
          "id": payload['id']
        };
        _responseToZkApp(method, resData);
        return;
      case "mina_sendPayment":
        onHandleSignTxDialog("mina_sendPayment", isConnect, payload);
        return;
      case "mina_sendStakeDelegation":
        onHandleSignTxDialog("mina_sendStakeDelegation", isConnect, payload);
        return;
      case "mina_sendTransaction":
        onHandleSignTxDialog("mina_sendTransaction", isConnect, payload);
        return;
      case "mina_signMessage":
        print('_msgHandler===2=,${method}');
        onHandleSignMessageDialog("mina_signMessage", isConnect, payload);
        break;
      case "mina_sign_JsonMessage":
        onHandleSignMessageDialog("mina_sign_JsonMessage", isConnect, payload);
        break;
      case "mina_signFields":
        onHandleSignMessageDialog("mina_signFields", isConnect, payload);
        break;
      case "mina_createNullifier":
        onHandleSignMessageDialog("mina_createNullifier", isConnect, payload);
        break;
      case "mina_addChain":
        if (_signing) {
          return;
        }
        _signing = true;
        String uri = Uri.decodeComponent(params!['url']);
        Uri uriCheck = Uri.parse(uri);

        if (!(uriCheck.scheme == 'http' || uriCheck.scheme == 'https') ||
            uriCheck.host.isEmpty) {
          onHandleErrorReject(method, payload['id'], ErrorCodes.invalidParams);
          return;
        }
        List<CustomNodeV2> endpoints =
            List<CustomNodeV2>.of(store.settings!.customNodeListV2);
        String realUrl = uri.toString();
        if (endpoints.any((element) => element.url == realUrl) ||
            netConfigMap.values.any((node) => node.url == realUrl)) {
          CustomNodeV2? currentNode = store.settings?.currentNode;
          if (realUrl.toLowerCase() == currentNode?.url) {
            Map chainInfoArgs = {
              "chainId": currentNode?.netType!.name,
              "name": NetworkUtil.getNetworkName(store.settings!.currentNode),
            };
            Map<String, dynamic> resData = {
              "result": chainInfoArgs,
              "id": payload['id']
            };
            _responseToZkApp(method, resData);
            return;
          } else {
            await switchChainByUrl(method, siteInfo as Map<dynamic, dynamic>,
                payload["id"], realUrl);
            return;
          }
        }
        await UI.showAddChainAction(
          context: context,
          nodeName: params!['name'],
          nodeUrl: realUrl,
          url: siteInfo!['origin'],
          iconUrl: siteInfo!['webIcon'],
          onConfirm: () {
            Navigator.of(context).pop();
            switchChainByUrl(method, siteInfo, payload["id"], realUrl);
          },
          onCancel: () {
            onHandleErrorReject(
                method, payload['id'], ErrorCodes.userRejectedRequest);
          },
        );
        _signing = false;
        return;
      case "mina_switchChain":
        if (_signing) {
          return;
        }
        _signing = true;
        List<String> currentSupportChainList =
            store.settings!.getSupportNetTypes();
        if (!currentSupportChainList.contains(params!['chainId'])) {
          onHandleErrorReject(
              method, payload['id'], ErrorCodes.notSupportChain);
          return;
        }
        String? currentChainId = store.settings!.currentNode?.netType!.name;
        if (currentChainId == (params["chainId"]?.toLowerCase())) {
          var networkName =
              NetworkUtil.getNetworkName(store.settings!.currentNode);
          Map chainInfoArgs = {
            "chainId": currentChainId,
            "name": networkName,
          };
          Map<String, dynamic> resData = {
            "result": chainInfoArgs,
            "id": payload['id']
          };
          _responseToZkApp(method, resData);
          return;
        }
        await UI.showSwitchChainAction(
            context: context,
            chainId: params!['chainId'],
            url: siteInfo!['origin'],
            iconUrl: siteInfo!['webIcon'],
            onConfirm: (String networkName, String chainId) async {
              Map chainInfoArgs = {
                "chainId": chainId,
                "name": networkName,
              };
              Map<String, dynamic> resData = {
                "result": chainInfoArgs,
                "id": payload['id']
              };
              _responseToZkApp(method, resData);
              return;
            },
            onCancel: () {
              onHandleErrorReject(
                  method, payload['id'], ErrorCodes.userRejectedRequest);
            });
        return;

      case "mina_verifyMessage":
      case "mina_verify_JsonMessage":
        Map verifyData = {
          "network": network,
          "publicKey": currentAccountAddress,
          "signature": jsonDecode(params?['signature']),
          "verifyMessage": params?["data"],
        };
        print('verifyData==verifyData==0${jsonEncode(verifyData)}');
        bool res = await webApi.account.verifyMessage(
          verifyData,
          context: context,
        );
        Map<String, dynamic> resData = {"result": res, "id": payload['id']};
        _responseToZkApp(method, resData);
        return;
      case "mina_verifyFields":
        Map verifyFields = {
          "network": network,
          "publicKey": currentAccountAddress,
          "signature": params?['signature'],
          "fields": params?["data"],
        };
        bool res = await webApi.account.verifyFields(
          verifyFields,
          context: context,
        );
        Map<String, dynamic> resData = {"result": res, "id": payload['id']};
        _responseToZkApp(method, resData);
        return;
      case "mina_requestNetwork":
        CustomNodeV2? currentNode = store.settings!.currentNode;
        var networkName = NetworkUtil.getNetworkName(currentNode);
        Map chainInfoArgs = {
          "chainId": currentNode?.netType!.name,
          "name": networkName,
        };
        Map<String, dynamic> resData = {
          "result": chainInfoArgs,
          "id": payload['id']
        };
        _responseToZkApp(method, resData);
        return;
      default:
        print('Unknown message from zkApp: ${method}');
        Map res = {"message": "Method not supported.", "code": 20006};
        return _responseToZkApp(method, res);
    }
    return Future(() => "");
  }

  Future<Map<String, dynamic>> getWebInfoFromBridge(String url) async {
    final webIconUrl =
        await _controller.runJavaScript("getSiteIcon(window)") as String?;
    String? webTitle = await _controller.getTitle();
    String title = webTitle ?? url;

    return {"webIconUrl": webIconUrl ?? "", "webTitle": title};
  }

  void onSaveHistory(String url) async {
    Map info = await getWebInfoFromBridge(url);
    Map<String, dynamic> con = {
      "url": url,
      "title": info['webTitle'],
      "time": DateTime.now().toString(),
      "icon": info['webIconUrl']
    };
    store.browser!.updateHistoryItem(con, url);
  }

  Future<void> _onFinishLoad(String url) async {
    print('Inject mina provider js code...');
    final minaJsProvider =
        await rootBundle.loadString('assets/webview/provider.js');
    await _controller.runJavaScript(minaJsProvider);
    print('mina provider js code injected');

    if (widget.onPageFinished != null) {
      _onGetPageActionStatus();
    }
    onSaveHistory(url);
  }

  void _onGetPageActionStatus() async {
    bool canGoback = await _controller.canGoBack();
    bool canGoForward = await _controller.canGoForward();
    widget.onPageFinished!(canGoback, canGoForward);
  }

  @override
  void initState() {
    super.initState();

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(
            const PlatformWebViewControllerCreationParams());

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _onFinishLoad(url);

            setState(() {
              loadProcess = 1;
            });
          },
          onProgress: (progress) {
            if (progress >= 99) {
              _onGetPageActionStatus();
            }
            setState(() {
              loadProcess = progress / 100;
            });
          },
        ),
      )
      ..addJavaScriptChannel(
        'AppProvider',
        onMessageReceived: (JavaScriptMessage message) async {
          try {
            print('msg from zkApp: ${message}');

            final msg = jsonDecode(message.message);
            print('msg from zkApp==1: ${msg}');
            Map? payload = msg["payload"];
            String? id = payload!["id"];

            String? origin = payload?["site"]?['origin'];

            if (id != null && origin != null) {
              _msgHandler(msg);
            }
          } catch (e) {
            print('msg from error: ${e}');
          }
        },
      )
      ..loadRequest(Uri.parse(widget.initialUrl));

    _controller = controller;
    widget.onWebViewCreated!(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      WebViewWidget(controller: _controller),
      if (loadProcess < 1)
        LinearProgressIndicator(
          value: loadProcess,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF594AF1)),
        ),
    ]);
  }
}