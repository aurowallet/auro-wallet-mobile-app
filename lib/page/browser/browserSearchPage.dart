import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/browser/browserWrapperPage.dart';
import 'package:auro_wallet/page/browser/components/webFavItem.dart';
import 'package:auro_wallet/page/browser/index.dart';
import 'package:auro_wallet/page/staking/components/searchInput.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/browser/types/webConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class BrowserSearchPage extends StatefulWidget {
  BrowserSearchPage(this.store);

  final AppStore store;

  static final String route = '/browserSearchPage';

  @override
  _BrowserSearchPage createState() => _BrowserSearchPage(this.store);
}

class _BrowserSearchPage extends State<BrowserSearchPage> {
  _BrowserSearchPage(this.store);
  final AppStore store;

  List<WebConfig> searchList = [];

  TextEditingController editingController = new TextEditingController();
  String? keywords;

  FocusNode _commentFocus = FocusNode();
  bool isSearchInputFocus = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      editingController.addListener(_onKeywordsChange);
      _commentFocus.requestFocus();
    });
    super.initState();
  }

  List<WebConfig> mergeWebConfigs(
      List<WebConfig> list1, List<WebConfig> list2) {
    final Map<String, WebConfig> mergedMap = {};

    for (var webConfig in list1) {
      mergedMap[webConfig.url] = webConfig;
    }

    for (var webConfig in list2) {
      mergedMap[webConfig.url] = webConfig;
    }

    return mergedMap.values.toList();
  }

  void _onKeywordsChange() {
    setState(() {
      keywords = editingController.text.trim();
    });
  }

  @override
  void dispose() {
    super.dispose();
    editingController.dispose();
  }

  bool isValidHttpUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return false;
    }
    return (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  void _onLoadUrl(String url) async {
    if (!isValidHttpUrl(url)) {
      print("error url, please reinput");
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      BrowserWrapperPage.route,
      arguments: {
        "url": url,
      },
    );
    editingController.clear();
  }

  void _onLoadHistoryUrl(WebConfig data) async {
    _onLoadUrl(data.url);
  }

  Widget _buildHistoryList() {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Expanded(
        child: ListView(shrinkWrap: true, children: [
      Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CategoryTitle(title: dic.recently),
            Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: GestureDetector(
                  child: SvgPicture.asset(
                    'assets/images/webview/icon_clear.svg',
                    width: 16,
                    height: 16,
                  ),
                  onTap: () {
                    store.browser!.clearWebHistoryList();
                  },
                )),
          ],
        ),
      ),
      ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 20, right: 20),
        itemCount: store.browser!.webHistoryList.length,
        itemBuilder: (context, index) {
          return WebHistoryItem(
            data: store.browser!.webHistoryList[index],
            onClickItem: _onLoadHistoryUrl,
          );
        },
      )
    ]));
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        title: null,
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 10, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                      child: Container(
                    child: GestureDetector(
                      child: SearchInput(
                          customMargin: EdgeInsets.all(0),
                          commentFocus: _commentFocus,
                          isReadOnly: false,
                          editingController: editingController,
                          placeholder: dic.searchOrInputUrl,
                          onSubmit: _onLoadUrl,
                          suffixIcon: keywords != null && keywords!.length > 0
                              ? GestureDetector(
                                  onTap: () {
                                    editingController.clear();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: 4, bottom: 4, right: 8),
                                    child: SvgPicture.asset(
                                      'assets/images/webview/icon_close_bg.svg',
                                      width: 16,
                                      height: 16,
                                      color: Color(0x000033).withOpacity(0.2),
                                    ),
                                  ),
                                )
                              : null),
                    ),
                  )),
                  GestureDetector(
                    onTap: () {
                      editingController.clear();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                      child: Text(
                        dic.cancel,
                        style: TextStyle(
                          color: Color(0xFF594AF1),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            store.browser!.webHistoryList.length != 0
                ? _buildHistoryList()
                : keywords == null ||
                        keywords!.isEmpty ||
                        isValidHttpUrl(keywords!)
                    ? Container()
                    : Expanded(
                        child: Center(
                            child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/setting/empty_contact.svg',
                            width: 100,
                            height: 100,
                          ),
                          Text(
                            dic.websiteNotFound,
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.3),
                                fontSize: 12,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      )))
          ],
        ),
      ),
    );
  }
}
