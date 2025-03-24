import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/browser/browserWrapperPage.dart';
import 'package:auro_wallet/page/browser/components/webFavItem.dart';
import 'package:auro_wallet/page/browser/index.dart';
import 'package:auro_wallet/page/staking/components/searchInput.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/browser/types/webConfig.dart';
import 'package:auro_wallet/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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

      setState(() {
        searchList = store.browser!.webHistoryList;
      });
    });
    super.initState();
  }

  List<WebConfig> _filter(String? key, List<WebConfig> list) {
    if (key == null || key.isEmpty) {
      return list;
    }
    var res = list.where((element) {
      return (element.url.toLowerCase().contains(key.toLowerCase())) ||
          (element.title.toLowerCase().contains(key.toLowerCase()));
    }).toList();
    return res;
  }

  void _onKeywordsChange() {
    String value = editingController.text.trim();
    List<WebConfig> uiList = _filter(value, store.browser!.webHistoryList);
    setState(() {
      keywords = value;
      searchList = uiList;
    });
  }

  @override
  void dispose() {
    super.dispose();
    editingController.dispose();
  }


  String formatUrl(String url) {
    if (url.startsWith("http") || url.startsWith("https")) {
      return url;
    }
    return "https://" + url;
  }

  void _onLoadUrl(String url) async { 
    if (!isValidHttpUrl(url)) {
      print("error url, please input");
      return;
    }
    Navigator.pushReplacementNamed(
      context,
      BrowserWrapperPage.route,
      arguments: {
        "url": formatUrl(url),
      },
    );
  }

  void _onLoadHistoryUrl(WebConfig data) async {
    _onLoadUrl(data.url);
  }

  void onClickHistoryDelete(WebConfig data) {
    store.browser!.removeWebHistoryItem(data.url);
    List<WebConfig> uiList = [...searchList];
    uiList.removeWhere((item) => item.url == data.url);
    setState(() {
      searchList = uiList;
    });
  }

  Widget _buildSearchView() {
    AppLocalizations dic = AppLocalizations.of(context)!;
    if (isValidHttpUrl(keywords)) {
      return Container();
    }
    return keywords == null || keywords!.isEmpty
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
                    color: Colors.black.withValues(alpha: 0.3),
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              )
            ],
          )));
  }

  Widget _buildHistoryList() {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Observer(builder: (BuildContext context) {
      return Expanded(
          child: ListView.builder(
        itemCount: searchList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CategoryTitle(title: dic.recently),
                  GestureDetector(
                    child: SvgPicture.asset(
                      'assets/images/webview/icon_clear.svg',
                      width: 16,
                      height: 16,
                    ),
                    onTap: () {
                      store.browser!.clearWebHistoryList();
                      setState(() {
                        searchList = [];
                      });
                    },
                  ),
                ],
              ),
            );
          } else {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: WebHistoryItem(
                data: searchList[index - 1],
                onClickItem: _onLoadHistoryUrl,
                onClickDelete: onClickHistoryDelete,
              ),
            );
          }
        },
      ));
    });
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
                                        colorFilter: ColorFilter.mode(
                                            Color(0x000033)
                                                .withValues(alpha: 0.5),
                                            BlendMode.srcIn)),
                                  ),
                                )
                              : null),
                    ),
                  )),
                  GestureDetector(
                    onTap: () {
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
            searchList.length != 0 ? _buildHistoryList() : _buildSearchView()
          ],
        ),
      ),
    );
  }
}
