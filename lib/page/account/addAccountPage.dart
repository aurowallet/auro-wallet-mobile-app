import 'dart:async';

import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/import/importKeyStorePage.dart';
import 'package:auro_wallet/page/account/import/importPrivateKeyPage.dart';
import 'package:auro_wallet/page/account/ledgerAccountNamePage.dart';
import 'package:auro_wallet/page/account/walletManagePage.dart';
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

  // Selected wallet for adding account (used when multiple HD wallets exist)
  WalletData? _selectedWallet;

  Future<bool> _onSubmitAccountName(String accountName) async {
    String? password = await UI.showPasswordDialog(
        context: context,
        wallet: store.wallet!.currentWallet,
        inputPasswordRequired: true);
    if (password == null) {
      return false;
    }
    // Use selected wallet or fall back to first mnemonic wallet
    WalletData? wallet = _selectedWallet ?? store.wallet!.mnemonicWallet;
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
          store.walletConnectService?.emitAccountsChanged(accountData['pubKey']);
          store.assets!.loadAccountCache();
          store.assets!.setAssetsLoading(true);
          webApi.assets.fetchAllTokenAssets();
          return true;
        }
      }
    }
    return true;
  }

  void _onCreate() {
    final hdWallets = store.wallet!.hdWalletList;

    if (hdWallets.isEmpty) {
      // No HD wallet available
      AppLocalizations dic = AppLocalizations.of(context)!;
      UI.toast(dic.noMnemonicWallet);
      return;
    }

    if (hdWallets.length == 1) {
      // Only one HD wallet, use it directly
      _selectedWallet = hdWallets[0];
      _createAccountDirectly(_selectedWallet!);
    } else {
      // Multiple HD wallets, show selection dialog
      _showWalletSelector(hdWallets);
    }
  }

  void _showWalletSelector(List<WalletData> hdWallets) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                dic.selectWallet,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Divider(height: 1),
            ...hdWallets.map((wallet) => ListTile(
                  leading: Icon(
                    Icons.account_balance_wallet,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(store.wallet!.getWalletDisplayName(wallet)),
                  subtitle: Text('${wallet.accounts.length} ${dic.accounts}'),
                  onTap: () {
                    Navigator.pop(context);
                    _selectedWallet = wallet;
                    _createAccountDirectly(wallet);
                  },
                )),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Create account directly with default name (skip name input)
  Future<void> _createAccountDirectly(WalletData wallet) async {
    final accountName = WalletStore.defaultAccountName(store.wallet!.getNextWalletAccountIndex(wallet) + 1);
    final success = await _onSubmitAccountName(accountName);
    if (success) {
      Navigator.popUntil(context, (route) => route.settings.name == WalletManagePage.route);
    }
  }

  String _getNextImportWalletName() {
    int count =
        store.wallet!.getNextWalletIndexOfType(WalletStore.seedTypePrivateKey) +
            1;
    return 'Import Account $count';
  }

  void _onPrivateKey() {
    // Go directly to import page with default name (skip name input)
    Navigator.pushReplacementNamed(context, ImportPrivateKeyPage.route,
        arguments: {"accountName": _getNextImportWalletName()});
  }

  void _onKeyStore() {
    // Go directly to import page with default name (skip name input)
    Navigator.pushReplacementNamed(context, ImportKeyStorePage.route,
        arguments: {"accountName": _getNextImportWalletName()});
  }

  void _showLedgerImport() async {
    int count =
        store.wallet!.getNextWalletIndexOfType(WalletStore.seedTypeLedger) + 1;
    final ledgerWalletName = 'Ledger $count';
    // Go directly to Ledger import with default name (skip name input)
    Navigator.pushNamed(context, LedgerAccountNamePage.route,
        arguments: LedgerAccountNameParams(defaultName: ledgerWalletName));
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
