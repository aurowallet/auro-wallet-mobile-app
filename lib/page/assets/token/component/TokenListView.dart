import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/token/TokenDetail.dart';
import 'package:auro_wallet/page/assets/token/component/TokenItem.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';

class TokenListView extends StatefulWidget {
  TokenListView(this.store, {this.onClickItem});

  final AppStore store;
  final Function()? onClickItem;

  @override
  _TokenListViewState createState() => _TokenListViewState(store);
}

class _TokenListViewState extends State<TokenListView>
    with WidgetsBindingObserver {
  _TokenListViewState(
    this.store,
  );
  final AppStore store;

  Future<void> onClickTokenItem(Token tokenItem) async {
    await store.assets!.setNextToken(tokenItem);
    Navigator.of(context).pushNamed(
      TokenDetailPage.route,
    );
  }

  void onClickManage() {
    UI.showTokenManageDialog(context: context);
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            margin: EdgeInsets.only(top: 30),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(
                  color: Colors.black.withOpacity(0.1),
                  width: 0.5,
                ))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  dic.tokens,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    letterSpacing: -0.3,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                ),
                Observer(builder: (BuildContext context) {
                  bool isLoading = store.assets!.isAssetsLoading;
                  int count = store.assets!.newTokenCount;
                  String showCount = count.toString();
                  bool showTokenTip = count > 0;
                  if (count > 99) {
                    showCount = "99+";
                  }
                  if (store.assets!.tokenList.length <= 1 || isLoading) {
                    return Container();
                  }
                  return TokenManageIcon(
                    onClickManage: onClickManage,
                    showTokenTip: showTokenTip,
                    showCount: showCount,
                  );
                })
              ],
            ),
          ),
          Observer(builder: (BuildContext context) {
            bool isLoading = store.assets!.isAssetsLoading;
            if (isLoading) {
              return Expanded(
                  child: Ink(
                      color: Color(0xFFFFFFFF),
                      child: Container(
                        child: Center(
                          child: LoadingCircle(),
                        ),
                      )));
            }
            return Expanded(
                child: ListView.builder(
                    itemCount: store.assets!.getTokenShowList().length,
                    itemBuilder: (context, index) {
                      return Container(
                          child: TokenItemView(
                        tokenItem: store.assets!.getTokenShowList()[index],
                        store: store,
                        onClickTokenItem: onClickTokenItem,
                      ));
                    }));
          })
        ],
      ),
    );
  }
}

class TokenManageIcon extends StatelessWidget {
  TokenManageIcon({
    required this.showCount,
    required this.showTokenTip,
    required this.onClickManage,
  });
  final String showCount;
  final bool showTokenTip;
  final Function onClickManage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            SvgPicture.asset('assets/images/assets/icon_add.svg'),
            if (showTokenTip)
              Positioned(
                right: -12,
                top: -10,
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      '$showCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          onClickManage();
        });
  }
}
