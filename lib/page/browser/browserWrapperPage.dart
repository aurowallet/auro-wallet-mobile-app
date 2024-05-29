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
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';

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

  late InAppWebViewController _controller;
  bool canGoback = false;
  bool canGoForward = false;
  bool isFav = false;
  late String loadUrl;
  String loadTitle = "";
  Map websiteInitInfo = {};

  int nextUseInferredNonce = 0;

  Widget _buildScaffold({
    required Function onBack,
    required Widget body,
    required Function() actionOnPressed,
  }) {
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
                GestureDetector(
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      child: SvgPicture.asset(
                        'assets/images/public/icon_nav_close.svg',
                        width: 24,
                        height: 24,
                      )),
                  onTap: () {
                    onBack();
                  },
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
    if (!mounted) return;
    setState(() {
      isFav = index >= 0;
    });
  }

  void onClickFav() async {
    if (isFav) {
      store.browser!.removeFavItem(loadUrl);
    } else {
      final String? title = websiteInitInfo['webTitle'];
      final String? icon = websiteInitInfo['webIconUrl'];
      store.browser!.updateFavItem({
        "url": loadUrl,
        "title": title != null && title.isNotEmpty ? title : loadUrl,
        "icon": icon != null && icon.isNotEmpty ? icon : "",
        "time": DateTime.now().toString(),
      }, loadUrl);
    }
    if (!mounted) return;
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
    if (!mounted) return "";
    setState(() {
      loadUrl = url;
    });
    return url;
  }

  String getOrigin(String url) {
    Uri uri = Uri.parse(url);
    String origin = '${uri.scheme}://${uri.host}:${uri.port}';
    print("Origin: $origin");
    return origin;
  }

  void onSelectAccount(String address) async {
    if (address.isNotEmpty) {
      WebUri? currentUrl = await _controller.getUrl();
      String origin = getOrigin(currentUrl.toString());

      bool isNewAccountConnect =
          store.browser?.zkAppConnectingList.contains(origin) ?? false;

      Map<String, dynamic> resData = {
        "result": isNewAccountConnect ? [address] : [],
        "action": "accountsChanged"
      };
      _controller.evaluateJavascript(
          source: "onAppResponse(${jsonEncode(resData)})");
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
            bool? canGoBack = await _controller.canGoBack();
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
                  child: WebViewInjected(
                    url,
                    onGetNewestNonce: () => nextUseInferredNonce,
                    onWebViewCreated: (controller) {
                      _controller = controller;
                    },
                    onPageFinished: (gobackStatus, goForwardStatus) async {
                      String title = await _controller.getTitle() ?? "";
                      if (title.isNotEmpty) {
                        if (!mounted) return;
                        setState(() {
                          loadTitle = title;
                        });
                      } else {
                        setState(() {
                          loadTitle = url;
                        });
                      }
                      if (!mounted) return;
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
                    },
                    onWebInfoBack: (Map websiteInfo) {
                      if (!mounted) return;
                      setState(() {
                        websiteInitInfo = websiteInfo;
                      });
                    },
                    onRefreshChain: () async {
                      nextUseInferredNonce = 0;
                      await _loadData();
                    },
                  ),
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
                          _controller.reload();
                        },
                      ),
                      Observer(builder: (BuildContext context) {
                        return IconButton(
                          icon: Icon(Icons.more_horiz),
                          color: ColorsUtil.hexColor(0x000000).withOpacity(0.8),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              isDismissible: true,
                              enableDrag: false,
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
        final canGoBack = await _controller.canGoBack();
        if (canGoBack ?? false) {
          _controller.goBack();
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
    accountName = accountName.trim();
    if (accountName.contains(' ')) {
      int spaceIndex = accountName.indexOf(' ');
      if (spaceIndex + 1 < accountName.length) {
        return accountName[0] + accountName[spaceIndex + 1];
      } else {
        return accountName[0];
      }
    } else {
      return accountName.length >= 2
          ? accountName.substring(0, 2)
          : accountName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed,
        child: CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xFF594AF1),
            child: Text(
              formatAccountName(accountName).toUpperCase(),
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            )));
  }
}
