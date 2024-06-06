import 'dart:async';

import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/accountNamePage.dart';
import 'package:auro_wallet/page/account/import/importKeyStorePage.dart';
import 'package:auro_wallet/page/account/import/importPrivateKeyPage.dart';
import 'package:auro_wallet/page/account/ledgerAccountNamePage.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage(this.store);

  static final String route = '/account/addaccount';
  final AppStore store;

  @override
  _AddAccountPageState createState() => _AddAccountPageState(store);
}

class _AddAccountPageState extends State<AddAccountPage> {
  _AddAccountPageState(this.store);

  final AppStore store;

  @override
  void initState() {
    super.initState();
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
      if (accountData?['error'] != null) {
        UI.toast(accountData?['error']['message']);
        return false;
      }
      AppLocalizations dic = AppLocalizations.of(context)!;
      if (accountData == null) {
        UI.toast(dic.passwordError);
        return false;
      } else {
        AccountData? matchedAccount = store.wallet!.accountListAll
            .map((e) => e as AccountData?)
            .firstWhere((account) => account!.pubKey == accountData['pubKey'],
                orElse: () => null);

        if (matchedAccount != null) {
          UI.showAlertDialog(
              context: context,
              crossAxisAlignment: CrossAxisAlignment.start,
              contents: [
                dic.importSameAccount_1(matchedAccount.address) + "\n",
                dic.importSameAccount_2(matchedAccount.name)
              ],
              confirm: dic.isee);
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

  String _getNextImportWalletName() {
    int count =
        store.wallet!.getNextWalletIndexOfType(WalletStore.seedTypePrivateKey) +
            1;
    return 'Import Account $count';
  }

  void _onPrivateKey() {
    Navigator.pushReplacementNamed(context, AccountNamePage.route,
        arguments: AccountNameParams(
            redirect: ImportPrivateKeyPage.route,
            placeholder: _getNextImportWalletName()));
  }

  void _onKeyStore() {
    Navigator.pushReplacementNamed(context, AccountNamePage.route,
        arguments: AccountNameParams(
            redirect: ImportKeyStorePage.route,
            placeholder: _getNextImportWalletName()));
  }

  void _showLedgerImport() async {
    int count =
        store.wallet!.getNextWalletIndexOfType(WalletStore.seedTypeLedger) + 1;
    final ledgerWalletName = 'Ledger $count';
    Navigator.pushNamed(context, LedgerAccountNamePage.route,
        arguments: LedgerAccountNameParams(placeholder: ledgerWalletName));
    return;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.addAccount),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              children: <Widget>[
                MenuItem(
                  text: dic.createAccount,
                  onClick: _onCreate,
                ),
                MenuItem(
                  text: dic.privateKey,
                  onClick: _onPrivateKey,
                ),
                MenuItem(
                  text: "Keystore",
                  onClick: _onKeyStore,
                ),
                MenuItem(
                  text: dic.hardwareWallet,
                  onClick: _showLedgerImport,
                ),
              ],
            )),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  MenuItem({required this.text, required this.onClick});

  final String text;
  final void Function() onClick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onClick,
        child: Container(
            height: 54,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(text,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600)),
                Container(
                    width: 6,
                    margin: EdgeInsets.only(
                      left: 14,
                    ),
                    child: SvgPicture.asset(
                        'assets/images/assets/right_arrow.svg',
                        width: 6,
                        height: 12)),
              ],
            )));
  }
}
