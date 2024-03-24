import 'package:auro_wallet/common/components/tabPageTitle.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/browser/browserSearchPage.dart';
import 'package:auro_wallet/page/browser/browserWrapperPage.dart';
import 'package:auro_wallet/page/browser/components/webFavItem.dart';

import 'package:auro_wallet/page/staking/components/searchInput.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/browser/types/webConfig.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';

class Browser extends StatefulWidget {
  Browser(this.store);

  final AppStore store;

  @override
  _BrowserState createState() => _BrowserState(store);
}

class _BrowserState extends State<Browser> with WidgetsBindingObserver {
  _BrowserState(this.store);
  final AppStore store;


  TextEditingController editingController = new TextEditingController();
  String? keywords;
  bool isSearchInputFocus = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addObserver(this);
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    editingController.dispose();
    super.dispose();
  }

  void _onLoadUrl(WebConfig data) async {
    Navigator.pushNamed(
      context,
      BrowserWrapperPage.route,
      arguments: {
        "url": data.url,
      },
    );
  }

  Widget _buildBottomList() {
    if (store.browser!.webFavList.length == 0 && store.browser!.webHistoryList.length == 0) {
      return Container();
    }
    List<Widget> bottomWidget = [];
    if (store.browser!.webFavList.length > 0) {
      List<Widget> favWidget = getFavListWidget();
      bottomWidget.addAll(favWidget);
    }
    if (store.browser!.webHistoryList.length > 0) {
      List<Widget> historyWidget = getHistoryListWidget();
      bottomWidget.addAll(historyWidget);
    }
    return Expanded(child: ListView(shrinkWrap: true, children: bottomWidget));
  }

  List<Widget> getHistoryListWidget() {
     if (store.browser!.webHistoryList.length == 0) {
      return [];
    }
    AppLocalizations dic = AppLocalizations.of(context)!;
    List<Widget> historyWidget = [];
    historyWidget.add(Container(
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
    ));
    historyWidget.add(ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(left: 20, right: 20),
      itemCount: store.browser!.webHistoryList.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return WebHistoryItem(
          data: store.browser!.webHistoryList[index],
          onClickItem: _onLoadUrl,
        );
      },
    ));

    return historyWidget;
  }

  void onClickDelete(WebConfig data) {
    store.browser!.removeFavItem(data.url);
  }

  List<Widget> getFavListWidget() {
    if (store.browser!.webFavList.length == 0) {
      return [];
    }
    AppLocalizations dic = AppLocalizations.of(context)!;
    List<Widget> favWidget = [];
    var itemWidth = (MediaQuery.of(context).size.width - 40) / 2;
    var itemHeight = 40;
    double childAspectRatio = itemWidth / itemHeight;

    favWidget.add(Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: CategoryTitle(title: dic.favorites),
    ));
    List<Widget> cellsTemp = <Widget>[];
    store.browser!.webFavList.forEach((WebConfig favItem) {
      cellsTemp.add(WebFavItem(
        data: favItem,
        onClickItem: _onLoadUrl,
        onClickDelete: onClickDelete,
      ));
    });

    favWidget.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 6,
          childAspectRatio: childAspectRatio,
          children: cellsTemp,
          physics: NeverScrollableScrollPhysics(),
        )));
    return favWidget;
  }

  void onClickInput() {
    Navigator.pushNamed(
      context,
      BrowserSearchPage.route,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;

    bool favEmpty = store.browser!.webFavList.length == 0;
    bool historyEmpty = store.browser!.webHistoryList.length == 0;
    bool showEmptyTip = favEmpty && historyEmpty;

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
        child: Observer(builder: (BuildContext context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabPageTitle(title: dic.browser),
              Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                            child: Container(
                          child: GestureDetector(
                            child: SearchInput(
                              onClickInput: onClickInput,
                              isReadOnly: true,
                              editingController: editingController,
                              placeholder: dic.searchOrInputUrl,
                            ),
                          ),
                        )),
                      ],
                    ),
                  )),
              showEmptyTip
                  ? Expanded(
                      child: Center(
                          child: Text(dic.browserEmptyTip,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: ColorsUtil.hexColor(0x808080)
                                      .withOpacity(0.5),
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.none))))
                  : Container(),
              _buildBottomList(),
            ],
          );
        }),
      ),
    );
  }
}

class CategoryTitle extends StatelessWidget {
  CategoryTitle({required this.title});

  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 20, bottom: 10),
        child: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ));
  }
}
