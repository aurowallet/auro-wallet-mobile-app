import 'dart:async';
import 'dart:convert';

import 'package:auro_wallet/common/consts/browser.dart';
import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/page/browser/components/signTransactionDialog.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/index.dart';
import 'package:auro_wallet/walletSdk/minaSDK.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewInjected extends StatefulWidget {
  WebViewInjected(
    this.initialUrl, {
    required this.onTxConfirmed,
    required this.onGetNewestNonce,
    required this.onRefreshChain,
    this.onPageFinished,
    this.onWebViewCreated,
    this.onWebInfoBack,
  });

  final String initialUrl;

  final Function(bool, bool)? onPageFinished;
  final Function(InAppWebViewController)? onWebViewCreated;
  final Function(int) onTxConfirmed;
  final int Function() onGetNewestNonce;
  final Function(Map)? onWebInfoBack;
  final Function() onRefreshChain;

  @override
  _WebViewInjectedState createState() => _WebViewInjectedState();
}

class _WebViewInjectedState extends State<WebViewInjected> {
  _WebViewInjectedState();
  final store = globalAppStore;

  late InAppWebViewController _controller;
  bool _signing = false;
  double loadProcess = 0.0;
  bool isSaveUrlHistory = false;
  Map websiteInitInfo = {};

  Future<dynamic> _responseToZkApp(String method, Map resData) async {
    print('respond ${method} to zkApp:');
    print(resData);
    _signing = false;
    return _controller.evaluateJavascript(
        source: "onAppResponse(${jsonEncode(resData)})");
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
      toAddress = params?['to'];
    }
    if (signType != null) {
      Object nextTx = params?['transaction'];
      try {
        if (params?['transaction'] != null) {
          if (params?['transaction'].runtimeType == String) {
            nextTx = params?['transaction'];
          } else {
            nextTx = jsonEncode(params?['transaction']);
          }
        }
      } catch (e) {}

      await UI.showSignTransactionAction(
        context: context,
        signType: signType,
        to: toAddress,
        nonce: widget.onGetNewestNonce(),
        zkNonce:
            Fmt.isNumber(params?['nonce']) ? (params?['nonce'].toString()) : "",
        amount: Fmt.isNumber(params?['amount'])
            ? (params?['amount'].toString())
            : "",
        fee: Fmt.isNumber(params?['fee']) ? (params?['fee'].toString()) : "",
        memo: params?['memo'],
        transaction: nextTx,
        feePayer: params?['feePayer'],
        onlySign: params?['onlySign'],
        url: siteInfo?['origin'],
        iconUrl: siteInfo?['webIcon'],
        onConfirm: (String responseData, int nonce) async {
          Map<String, dynamic> resData;
          if (params?['onlySign'].runtimeType == bool && params?['onlySign']) {
            resData = {
              "result": {"signedData": responseData},
              "id": payload['id']
            };
          } else {
            resData = {
              "result": {"hash": responseData},
              "id": payload['id']
            };
          }

          if (responseData.isNotEmpty) {
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

    Object message = params?["message"];

    await UI.showSignatureAction(
      method: method,
      context: context,
      content: message,
      url: siteInfo?['origin'],
      iconUrl: siteInfo?['webIcon'],
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
    store.browser!.addZkAppConnect(store.wallet!.currentAddress, url);
  }

  void notifyChainChange(Map chainInfoArgs) {
    Map<String, dynamic> resData = {
      "result": chainInfoArgs,
      "action": "chainChanged"
    };
    _controller.evaluateJavascript(
        source: "onAppResponse(${jsonEncode(resData)})");
  }

  Future<void> switchChainByUrl(String method, Map<dynamic, dynamic>? siteInfo,
      String id, String realUrl) async {
    _signing = true;
    await UI.showSwitchChainAction(
        context: context,
        networkID: "",
        url: siteInfo?['origin'],
        iconUrl: siteInfo?['webIcon'],
        gqlUrl: realUrl,
        onConfirm: (String networkName, String networkID) async {
          await widget.onRefreshChain();
          Map chainInfoArgs = {
            "networkID": networkID,
          };
          notifyChainChange(chainInfoArgs);
          Map<String, dynamic> resData = {"result": chainInfoArgs, "id": id};
          _responseToZkApp(method, resData);
          return;
        },
        onCancel: () {
          onHandleErrorReject(method, id, ErrorCodes.userRejectedRequest);
        });
  }

  Future<dynamic> _msgHandler(Map msg, String origin) async {
    final String method = msg['action'];
    Map payload = msg['payload'];
    Map? siteInfo = payload['site'];
    if (siteInfo != null) {
      siteInfo['origin'] = origin;
      payload['site'] = siteInfo;
    } else {
      payload['site'] = {"origin": origin};
    }

    Map? params = payload['params'];

    String currentAccountAddress = store.wallet!.currentAddress;
    bool isConnect =
        store.browser?.zkAppConnectingList.contains(siteInfo?['origin']) ??
            false;
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
                .addZkAppConnect(currentAccountAddress, siteInfo?['origin']);
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
        String uri = Uri.decodeComponent(params?['url']);
        Uri uriCheck = Uri.parse(uri);

        if (!(uriCheck.scheme == 'http' || uriCheck.scheme == 'https') ||
            uriCheck.host.isEmpty) {
          onHandleErrorReject(method, payload['id'], ErrorCodes.invalidParams);
          return;
        }
        List<CustomNode> endpoints =
            List<CustomNode>.of(store.settings!.customNodeList);
        String realUrl = uri.toString();
        if (endpoints.any((element) => element.url == realUrl) ||
            defaultNetworkList.any((node) => node.url == realUrl)) {
          CustomNode? currentNode = store.settings?.currentNode;
          if (realUrl.toLowerCase() == currentNode?.url) {
            Map chainInfoArgs = {
              "networkID": currentNode?.networkID,
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
          nodeName: params?['name'],
          nodeUrl: realUrl,
          url: siteInfo?['origin'] ?? "",
          iconUrl: siteInfo?['webIcon'],
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
            store.settings!.getSupportNetworkIDs();
        if (!currentSupportChainList.contains(params?['networkID'])) {
          onHandleErrorReject(
              method, payload['id'], ErrorCodes.notSupportChain);
          return;
        }
        String? currentNetworkID = store.settings!.currentNode?.networkID;
        if (currentNetworkID == (params?["networkID"]?.toLowerCase())) {
          Map chainInfoArgs = {
            "networkID": currentNetworkID,
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
            networkID: params?['networkID'],
            url: siteInfo?['origin'],
            iconUrl: siteInfo?['webIcon'],
            onConfirm: (String networkName, String networkID) async {
              await widget.onRefreshChain();
              Map chainInfoArgs = {
                "networkID": networkID,
              };
              Map<String, dynamic> resData = {
                "result": chainInfoArgs,
                "id": payload['id']
              };
              notifyChainChange(chainInfoArgs);
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
        CustomNode? currentNode = store.settings!.currentNode;
        Map chainInfoArgs = {
          "networkID": currentNode?.networkID,
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
    String? webIcon = websiteInitInfo['webIcon'];
    String? icon = webIcon != null && webIcon.isNotEmpty ? webIcon : "";
    String? webTitle = await _controller.getTitle();
    String title = webTitle != null && webTitle.isNotEmpty ? webTitle : url;

    return {"webIconUrl": icon, "webTitle": title, url: url};
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
    dynamic minaConfig =
        await _controller.evaluateJavascript(source: "window.mina?.isAuro");
    if (minaConfig.runtimeType == bool && minaConfig) {
      print('mina provider injected success, $minaConfig');
    } else {
      print('mina provider injected failed,$minaConfig');
      final minaJsProvider =
          await rootBundle.loadString('assets/webview/provider.js');
      await _controller.evaluateJavascript(source: minaJsProvider);
      print('mina provider js code injected');
    }

    if (widget.onPageFinished != null) {
      _onGetPageActionStatus();
    }
    if (!isSaveUrlHistory) {
      isSaveUrlHistory = true;
      onSaveHistory(url);
    }
    if (widget.onWebInfoBack != null) {
      Map info = await getWebInfoFromBridge(url);
      widget.onWebInfoBack!(info);
    }
  }

  void _onGetPageActionStatus() async {
    bool canGoback = await _controller.canGoBack();
    bool canGoForward = await _controller.canGoForward();
    widget.onPageFinished!(canGoback, canGoForward);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(widget.initialUrl),
        ),
        onWebViewCreated: (controller) {
          print('onWebViewCreated,');
          _controller = controller;
          controller.addWebMessageListener(WebMessageListener(
            jsObjectName: "AppProvider",
            onPostMessage: (message, sourceOrigin, isMainFrame, replyProxy) {
              try {
                if (!isMainFrame) {
                  print('msg is not from MainFrame');
                  return;
                }
                final msg = jsonDecode(message?.data);
                Map? payload = msg["payload"];
                String? id = payload?["id"];

                String origin = sourceOrigin.toString();

                if (origin.isNotEmpty) {
                  if (id != null) {
                    _msgHandler(msg, origin);
                  } else {
                    if (payload?["site"]?['webIcon'] != null) {
                      websiteInitInfo = payload?["site"];
                    }
                  }
                }
              } catch (e) {
                print('msg from error: ${e}');
              }
            },
          ));
          widget.onWebViewCreated!(controller);
        },
        onPageCommitVisible: (controller, url) async {
          print('onPageCommitVisible Inject mina provider js code...');
          final minaJsProvider =
              await rootBundle.loadString('assets/webview/provider.js');
          await controller.evaluateJavascript(source: minaJsProvider);
          print('onPageCommitVisible mina provider js code injected ');
        },
        onLoadStop: (controller, url) async {
          await _onFinishLoad(url.toString());
        },
        // onConsoleMessage: (controller, consoleMessage) {
        //   print("Console message: ${consoleMessage.message}");
        // },
        onReceivedError: (controller, request, error) {
          print("Load error: $error");
        },
        onProgressChanged: (controller, progress) {
          if (progress >= 99) {
            _onGetPageActionStatus();
          }
          if (!mounted) return;
          setState(() {
            loadProcess = progress / 100;
          });
        },
        initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            javaScriptCanOpenWindowsAutomatically: false,
            isInspectable: true,
            transparentBackground: true,
            allowsBackForwardNavigationGestures: true),
        onJsAlert: (controller, jsAlertRequest) async {
          print("JS Alert: ${jsAlertRequest.message}");
          return JsAlertResponse(handledByClient: true);
        },
      ),
      if (loadProcess < 1)
        LinearProgressIndicator(
          value: loadProcess,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF594AF1)),
        ),
    ]);
  }
}
