import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/common/components/accountItem.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/assets/types/accountInfo.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/page/account/accountNamePage.dart';
import 'package:auro_wallet/page/account/import/importWaysPage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class WalletManagePage extends StatefulWidget {
  const WalletManagePage(this.store);

  static final String route = '/wallet/manage';
  final AppStore store;

  @override
  _WalletManagePageState createState() => _WalletManagePageState(store);
}

class _WalletManagePageState extends State<WalletManagePage> {
  _WalletManagePageState(this.store);

  final AppStore store;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      webApi.assets.fetchBatchAccountsInfo(store.wallet!.accountListAll.map((acc)=>acc.pubKey).toList());
    });
  }
  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onSubmitAccountName(String accountName) async {
    String? password = await UI.showPasswordDialog(
        context: context,
        wallet: store.wallet!.currentWallet
    );
    if (password == null) {
      return false;
    }
    WalletData? wallet = store.wallet!.mnemonicWallet;
    if (wallet != null) {
      bool success = await webApi.account.createAccountByAccountIndex(wallet, accountName, password);
      if (!success) {
        final Map<String, String> dic = I18n.of(context).main;
        UI.toast(dic['passwordError']!);
        return false;
      }
    }
    return true;
  }
  void _onCreate() {
    Navigator.pushNamed(context, AccountNamePage.route, arguments: AccountNameParams(
      callback: _onSubmitAccountName,
      placeholder: 'Account ${store.wallet!.getNextWalletAccountIndex(store.wallet!.mnemonicWallet) + 1}'
    ));
  }
  void _showActions() {
    Navigator.pushNamed(context, ImportWaysPage.route);
  }
  List<Widget> _renderAccountList() {
    Map<String, WalletData> walletMap = store.wallet!.walletsMap;
    List<Widget> items = [];
    items.addAll(store.wallet!.accountListAll.map((account){
      AccountInfo? balancesInfo = store.assets!.accountsInfo[account.pubKey];
      return WalletItem(
        account: account,
        balance: balancesInfo?.total ?? BigInt.from(0),
        store: store,
        wallet: walletMap[account.walletId]!,
      );
    }).toList());
    items.add(this._renderResetButton());
    return items;
  }
  Widget _renderResetButton() {
    var theme = Theme.of(context).textTheme;
    final Map<String, String> dic = I18n.of(context).main;
    return TextButton(onPressed: _onResetApp, child: Text(
      dic['resetWallet']!,
      style: theme.headline5!.copyWith(color: Theme.of(context).primaryColor),
    ));
  }
  void _onResetApp() async {
    final Map<String, String> dic = I18n.of(context).main;
    bool? confirm = await UI.showConfirmDialog(context: context, contents: [
      dic['resetWarnContent']!
    ], okText: dic['confirmReset']!, cancelText: dic['cancelReset']!);
    if (confirm != true) {
      return;
    }
    store.wallet!.clearWallets();
    store.assets!.clearAccountCache();
    webApi.account.setBiometricDisabled();
    Phoenix.rebirth(context);
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['accountManage']!),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Observer(builder: (BuildContext context) {
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: _renderAccountList(),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 9, horizontal: 30),
                height: 1,
                color: ColorsUtil.hexColor(0xf5f5f5),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: ColorsUtil.hexColor(0x252275, alpha: 0.08),
                              blurRadius: 30.0, // has the effect of softening the shadow
                              spreadRadius: 0, // has the effect of extending the shadow
                              offset: Offset(
                                0, // horizontal, move right 10
                                12.0, // vertical, move down 10
                              ),
                            )
                          ],
                        ),
                        constraints: BoxConstraints(
                            minWidth: 114,
                            minHeight: 45
                        ),
                        child:  TextButton.icon(
                          icon: SvgPicture.asset(
                            'assets/images/assets/add_wallet.svg',
                            width: 24,
                            height: 24,
                          ),
                          label: Text(dic['createAccount']!, style: theme.headline6),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28.0),
                                  // side: BorderSide(color: Colors.red)
                                )
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(16)),
                          ),
                          // padding: EdgeInsets.all(16),
                          onPressed: _onCreate,
                        )
                    ),
                    Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: ColorsUtil.hexColor(0x252275, alpha: 0.08),
                              blurRadius: 30.0, // has the effect of softening the shadow
                              spreadRadius: 0, // has the effect of extending the shadow
                              offset: Offset(
                                0, // horizontal, move right 10
                                12.0, // vertical, move down 10
                              ),
                            )
                          ],
                        ),
                        constraints: BoxConstraints(
                            minWidth: 114,
                            minHeight: 45
                        ),
                        child:  TextButton.icon(
                          icon: SvgPicture.asset(
                            'assets/images/assets/import_wallet.svg',
                            width: 24,
                            height: 24,
                          ),
                          label: Text(dic['importAccount']!, style:  theme.headline6),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28.0),
                                  // side: BorderSide(color: Colors.red)
                                )
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(16)),
                          ),
                          // padding: EdgeInsets.all(16),
                          onPressed: _showActions,
                        )
                    ),
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
