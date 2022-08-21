import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/common/components/accountItem.dart';
import 'package:auro_wallet/common/components/customPromptDialog.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      final accountData = await webApi.account
          .createAccountByAccountIndex(wallet, accountName, password);
      final Map<String, String> dic = I18n.of(context).main;
      if (accountData == null) {
        UI.toast(dic['passwordError']!);
        return false;
      } else {
        AccountData? matchedAccount = store.wallet!.accountListAll
            .map((e) => e as AccountData?)
            .firstWhere((account) => account!.pubKey == accountData['pubKey'],
                orElse: () => null);

        if (matchedAccount != null) {
          UI.showAlertDialog(
              context: context,
              contents: [
                dic['accountRepeatAlert']!.replaceAll('{address}', matchedAccount.address).replaceAll('{accountName}', matchedAccount.name)
              ],
              confirm: dic['isee']!
          );
          return false;
        } else {
          await store.wallet!.addAccount(accountData, accountName, wallet);
          store.assets!.loadAccountCache();
          return true;
        }
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
    final watchModeAccounts = store.wallet!.watchModeAccountListAll;
    final theme = Theme.of(context).textTheme;
    final Map<String, String> dic = I18n.of(context).main;
    final renderItem = (account) {
      AccountInfo? balancesInfo = store.assets!.accountsInfo[account.pubKey];
      return WalletItem(
        account: account,
        balance: balancesInfo?.total ?? BigInt.from(0),
        store: store,
        wallet: walletMap[account.walletId]!,
      );
    };
    items.addAll(store.wallet!.accountListAll.map((account){
      return renderItem(account);
    }));
    if (watchModeAccounts.length > 0) {
      items.add(
        Padding(
          padding: EdgeInsets.only(
              left: 28,
              top: 20
          ),
          child: Text(
            dic['noMoreSupported']!,
            style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(0x666666)),
          ),
        )
      );
      items.addAll(
          watchModeAccounts.map((account){
            return renderItem(account);
          })
      );
    }
    
    items.add(this._renderResetButton());
    return items;
  }
  Widget _renderResetButton() {
    var theme = Theme.of(context).textTheme;
    final Map<String, String> dic = I18n.of(context).main;
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onResetApp,
          child: Text(
            dic['resetWallet']!,
            style: theme.headline5!.copyWith(color: Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }
  void _onResetApp() async {
    final Map<String, String> dic = I18n.of(context).main;
    bool? rejected = await UI.showConfirmDialog(
        context: context,
        icon: Icon(Icons.error,size: 60,color: Color(0xfff95051),),
        contents: [
          dic['resetWarnContent']!
        ],
        okText: dic['cancelReset']!,
        cancelText: dic['confirmReset']!
    );
    if (rejected != false) {
      return;
    }
    String? confirmInput = await showDialog<String>(
      context: context,
      builder: (_) {
        return CustomPromptDialog(
            title: dic['deleteConfirm']!,
            placeholder: '',
            onOk:(String? text) {
              if (text == null || text.isEmpty) {
                return false;
              }
              return true;
            },
          validate: (text){
            return text.toLowerCase() == dic['delete']!.toLowerCase();
          },
        );
      },
    );
    if (confirmInput != null && confirmInput.toLowerCase() == dic['delete']!.toLowerCase()) {
      store.wallet!.clearWallets();
      store.assets!.clearAccountCache();
      webApi.account.setBiometricDisabled();
      Phoenix.rebirth(context);
    }
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
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: ColorsUtil.hexColor(0x252275, alpha: 0.08),
                              blurRadius: 30.0,
                              // has the effect of softening the shadow
                              spreadRadius: 0,
                              // has the effect of extending the shadow
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
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28.0),
                              // side: BorderSide(color: Colors.red)
                            )),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                                    EdgeInsets.all(12)),
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
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28.0),
                              // side: BorderSide(color: Colors.red)
                            )),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                                    EdgeInsets.all(12)),
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
