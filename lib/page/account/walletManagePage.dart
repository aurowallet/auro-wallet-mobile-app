import 'dart:async';
import 'package:auro_wallet/page/account/ledgerAccountNamePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/common/components/accountItem.dart';
import 'package:auro_wallet/common/components/customPromptDialog.dart';
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
      webApi.assets.fetchBatchAccountsInfo(
          store.wallet!.accountListAll.map((acc) => acc.pubKey).toList());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onSubmitAccountName(String accountName) async {
    String? password = await UI.showPasswordDialog(
        context: context,
        wallet: store.wallet!.currentWallet,
        inputPasswordRequired: true);
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
                dic['accountRepeatAlert']!
                    .replaceAll('{address}', matchedAccount.address)
                    .replaceAll('{accountName}', matchedAccount.name)
              ],
              confirm: dic['isee']!);
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
    Navigator.pushNamed(context, AccountNamePage.route,
        arguments: AccountNameParams(
            callback: _onSubmitAccountName,
            placeholder:
                'Account ${store.wallet!.getNextWalletAccountIndex(store.wallet!.mnemonicWallet) + 1}'));
  }

  void _showActions() {
    Navigator.pushNamed(context, ImportWaysPage.route);
  }

  void _showLedgerImport() async {
    int count =
        store.wallet!.getNextWalletIndexOfType(WalletStore.seedTypeLedger) + 1;
    final ledgerWalletName = 'Ledger $count';
    Navigator.pushNamed(context, LedgerAccountNamePage.route,
        arguments: LedgerAccountNameParams(placeholder: ledgerWalletName));
    return;
  }

  List<Widget> _renderAccountList() {
    Map<String, WalletData> walletMap = store.wallet!.walletsMap;
    List<Widget> items = [];
    final watchModeAccounts = store.wallet!.watchModeAccountListAll;
    final theme = Theme.of(context).textTheme;
    final Map<String, String> dic = I18n.of(context).main;
    final renderItem = (account) {
      AccountInfo? balancesInfo = store.assets!.accountsInfo[account.pubKey];
      print('balancesInfo');
      print(balancesInfo?.total);
      return WalletItem(
        account: account,
        balance: balancesInfo?.total ?? BigInt.from(0),
        store: store,
        wallet: walletMap[account.walletId]!,
      );
    };
    items.addAll(store.wallet!.accountListAll.map((account) {
      return renderItem(account);
    }));
    if (watchModeAccounts.length > 0) {
      items.add(Padding(
        padding: EdgeInsets.only(left: 28, top: 20),
        child: Text(
          dic['noMoreSupported']!,
          style:
              theme.headline5!.copyWith(color: ColorsUtil.hexColor(0x666666)),
        ),
      ));
      items.addAll(watchModeAccounts.map((account) {
        return renderItem(account);
      }));
    }

    return items;
  }

  void _onResetApp() async {
    final Map<String, String> dic = I18n.of(context).main;
    bool? confirmed = await UI.showConfirmDialog(
        context: context,
        icon: SvgPicture.asset(
          'assets/images/public/error.svg',
          width: 58,
          height: 58,
        ),
        title: dic['resetWarnContentTitle']!,
        contents: [dic['resetWarnContent']!],
        okColor: Color(0xFFD65A5A),
        okText: dic['confirmReset']!,
        cancelText: dic['cancelReset']!);
    if (confirmed != true) {
      return;
    }
    String? confirmInput = await showDialog<String>(
      context: context,
      builder: (_) {
        return CustomPromptDialog(
          title: dic['deleteConfirm']!,
          placeholder: '',
          onOk: (String? text) {
            if (text == null || text.isEmpty) {
              return false;
            }
            return true;
          },
          validate: (text) {
            return text.toLowerCase() == dic['delete']!.toLowerCase();
          },
        );
      },
    );
    if (confirmInput != null &&
        confirmInput.toLowerCase() == dic['delete']!.toLowerCase()) {
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
    var outlineBtnStyle = OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        foregroundColor: Theme.of(context).primaryColor,
        // backgroundColor: Theme.of(context).primaryColor,
        textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        minimumSize: Size(0, 48));
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        title: Text(
          dic['accountManage']!,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: <Widget>[
          TextButton(
            style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent)),
            child: Text(
              dic['resetWallet']!,
              style: TextStyle(fontSize: 14, color: Color(0xFFD65A5A)),
            ),
            onPressed: _onResetApp,
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Observer(builder: (BuildContext context) {
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: _renderAccountList(),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onCreate,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SvgPicture.asset(
                              'assets/images/assets/add_wallet.svg',
                              width: 20,
                              height: 20,
                            ),
                            Container(
                              width: 8,
                            ),
                            Text(dic['createAccount']!)
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            shadowColor: Colors.transparent,
                            backgroundColor: Theme.of(context).primaryColor,
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 48)),
                      ),
                    ),
                    Container(
                      width: 15,
                    ),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _showActions,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SvgPicture.asset(
                              'assets/images/assets/import_wallet.svg',
                              width: 16,
                              height: 15,
                            ),
                            Container(
                              width: 8,
                            ),
                            Text(dic['importAccount']!)
                          ],
                        ),
                        style: outlineBtnStyle,
                      ),
                    ),
                    Container(
                      width: 15,
                    ),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _showLedgerImport,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SvgPicture.asset(
                              'assets/images/assets/import_ledger.svg',
                              width: 18,
                              height: 15,
                            ),
                            Container(
                              width: 8,
                            ),
                            Text(dic['importLedger']!)
                          ],
                        ),
                        style: outlineBtnStyle,
                      ),
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
