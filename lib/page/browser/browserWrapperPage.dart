import 'dart:convert';

import 'package:auro_wallet/page/browser/components/browserActionButton.dart';
import 'package:auro_wallet/page/browser/injectedBrowser.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/browser/types/webConfig.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserWrapperPage extends StatefulWidget {
  BrowserWrapperPage(this.store);

  final AppStore store;

  static const String route = '/browserwrapperpage';

  @override
  _BrowserWrapperPageState createState() =>
      _BrowserWrapperPageState(this.store);
}

class _BrowserWrapperPageState extends State<BrowserWrapperPage> {
  _BrowserWrapperPageState(this.store);
  final AppStore store;

  late WebViewController _controller;
  bool canGoback = false;
  bool canGoForward = false;
  bool isFav = false;
  late String loadUrl;
  String loadTitle = "";

  int nextUseInferredNonce = 0;

  Widget _buildScaffold({
    required Function onBack,
    required Widget body,
    required Function() actionOnPressed,
  }) {
    String url = getLoadUrl(context);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      body: body,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(42.0),
        child: Material(
          elevation: 1.0,
          shadowColor: Colors.black,
          child: AppBar(
            title: Text(
              loadTitle,
              style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                  fontSize: 14,
                  color: Color(0xFF000000).withOpacity(0.8),
                  fontWeight: FontWeight.w500),
            ),
            automaticallyImplyLeading: false,
            titleTextStyle: Theme.of(context)
                .appBarTheme
                .titleTextStyle
                ?.copyWith(color: Colors.white),
            elevation: 0.0,
            toolbarHeight: 42,
            centerTitle: true,
            leading: Row(
              children: [
                Container(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: GestureDetector(
                        child: SvgPicture.asset(
                          'assets/images/public/icon_nav_close.svg',
                          width: 24,
                          height: 24,
                        ),
                        onTap: () {
                          onBack();
                        },
                      )),
                ),
              ],
            ),
            actions: [
              Observer(builder: (_) {
                WalletData acc = store.wallet!.currentWallet;
                return Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: AccoutIcon(
                        accountName: Fmt.accountName(acc.currentAccount),
                        onPressed: actionOnPressed));
              })
            ],
          ),
        ),
      ),
    );
    ;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      nextUseInferredNonce = store
          .assets!.accountsInfo[store.wallet!.currentAddress]!.inferredNonce;
      _loadData();
      onCheckFav();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      webApi.assets.fetchAccountInfo(),
      webApi.assets.queryTxFees(),
    ]);
    nextUseInferredNonce =
        store.assets!.accountsInfo[store.wallet!.currentAddress]!.inferredNonce;
  }

  void onCheckFav() async {
    List<WebConfig> list = store.browser!.webFavList;
    int index = list.indexWhere((item) => item.url == loadUrl);
    setState(() {
      isFav = index >= 0;
    });
  }

  void onClickFav() async {
    if (isFav) {
      store.browser!.removeFavItem(loadUrl);
    } else {
      Map info = await getWebInfoFromBridge(loadUrl);
      store.browser!.updateFavItem({
        "url": loadUrl,
        "title": info['webTitle'],
        "icon": info['webIconUrl'],
        "time": DateTime.now().toString(),
      }, loadUrl);
    }
    setState(() {
      isFav = !isFav;
    });
  }

  String getLoadUrl(BuildContext context) {
    String url = "";
    if (ModalRoute.of(context)!.settings.arguments is Map) {
      url = (ModalRoute.of(context)!.settings.arguments as Map)["url"];
    } else {
      url = ModalRoute.of(context)!.settings.arguments as String;
    }
    setState(() {
      loadUrl = url;
    });
    return url;
  }

  Future<Map<String, dynamic>> getWebInfoFromBridge(String url) async {
    final webIconUrl =
        await _controller.runJavaScript("getSiteIcon(window)") as String?;
    String? webTitle = await _controller.getTitle();
    String title = webTitle ?? url;

    return {"webIconUrl": webIconUrl, "webTitle": title};
  }

  String getOrigin(String url) {
    Uri uri = Uri.parse(url);
    String origin = '${uri.scheme}://${uri.host}:${uri.port}';
    print("Origin: $origin");
    return origin;
  }

  void onSelectAccount(String address) async {
    if (address.isNotEmpty) {
      String? currentUrl = await _controller.currentUrl();
      String origin = getOrigin(currentUrl!);

      bool isNewAccountConnect =
          (store.browser!.browserConnectingList[address]?.contains(origin) ??
              false);

      Map<String, dynamic> resData = {
        "result": isNewAccountConnect ? [address] : [],
        "action": "accountsChanged"
      };
      _controller.runJavaScript("onAppResponse(${jsonEncode(resData)})");
      _controller.reload();
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    String url = getLoadUrl(context);

    Color disableBtnColor = ColorsUtil.hexColor(0x808080).withOpacity(0.5);
    Color enableBtnColor = ColorsUtil.hexColor(0x000000).withOpacity(0.8);
    return WillPopScope(
      child: _buildScaffold(
          onBack: () async {
            bool? canGoBack = await _controller?.canGoBack();
            print('canGoBack,${canGoBack}');
            Navigator.of(context).pop();
          },
          actionOnPressed: () async {
            await UI.showAccountSelectAction(
                context: context, onSelectAccount: onSelectAccount);
          },
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: WebViewInjected(url,
                      onGetNewestNonce: () => nextUseInferredNonce,
                      onWebViewCreated: (controller) {
                        _controller = controller;
                      },
                      onPageFinished: (gobackStatus, goForwardStatus) async {
                        String title = await _controller.getTitle() ?? "";
                        if (title.isNotEmpty) {
                          setState(() {
                            loadTitle = title;
                          });
                        }
                        setState(() {
                          canGoback = gobackStatus;
                          canGoForward = goForwardStatus;
                        });
                      },
                      onTxConfirmed: (int nonce) {
                        if (nonce == nextUseInferredNonce) {
                          nextUseInferredNonce = nextUseInferredNonce + 1;
                        } else {
                          _loadData();
                        }
                      }),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        width: 0.5,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: SvgPicture.asset(
                            'assets/images/webview/icon_back.svg',
                            width: 30,
                            height: 30,
                            color:
                                canGoback ? enableBtnColor : disableBtnColor),
                        onTap: () async {
                          if (await _controller.canGoBack()) {
                            _controller.goBack();
                          }
                        },
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: SvgPicture.asset(
                            'assets/images/webview/icon_pop.svg',
                            width: 30,
                            height: 30,
                            color: canGoForward
                                ? enableBtnColor
                                : disableBtnColor),
                        onTap: () async {
                          if (await _controller.canGoForward()) {
                            _controller.goForward();
                          }
                        },
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: SvgPicture.asset(
                            'assets/images/webview/icon_refresh.svg',
                            width: 24,
                            height: 24,
                            color:
                                ColorsUtil.hexColor(0x000000).withOpacity(0.8)),
                        onTap: () {
                          _controller!.reload();
                        },
                      ),
                      Observer(builder: (BuildContext context) {
                        return IconButton(
                          icon: Icon(Icons.more_horiz),
                          color: ColorsUtil.hexColor(0x000000).withOpacity(0.8),
                          onPressed: () {
                            showCupertinoModalPopup(
                              context: context,
                              builder: (contextPopup) {
                                return BrowserActionButton(
                                  url: url,
                                  isFav: isFav,
                                  onClickFav: onClickFav,
                                );
                              },
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          )),
      onWillPop: () async {
        final canGoBack = await _controller?.canGoBack();
        if (canGoBack ?? false) {
          _controller?.goBack();
          return false;
        } else {
          return true;
        }
      },
    );
  }
}

class AccoutIcon extends StatelessWidget {
  AccoutIcon({required this.accountName, this.onPressed});
  final String accountName;
  final Function()? onPressed;

  String formatAccountName(String accountName) {
    List<String> parts = accountName.split(' ');

    if (parts.length == 1) {
      return accountName.length > 1 ? accountName.substring(0, 2) : accountName;
    }
    String formattedName = '';
    for (String part in parts) {
      if (part.isNotEmpty) {
        formattedName += part[0];
      }
    }

    return formattedName;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed,
        child: CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xFF000000).withOpacity(0.3),
            child: Text(
              formatAccountName(accountName),
              style: TextStyle(fontSize: 12, color: Colors.white),
            )));
  }
}
