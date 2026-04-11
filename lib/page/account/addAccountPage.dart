import 'dart:async';

import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/import/importKeyStorePage.dart';
import 'package:auro_wallet/page/account/import/importPrivateKeyPage.dart';
import 'package:auro_wallet/page/account/connectHardwareWalletIntroPage.dart';
import 'package:auro_wallet/page/account/walletManagePage.dart';
import 'package:collection/collection.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/menuItem.dart';

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
    // Use selected wallet or fall back to first mnemonic wallet
    final WalletData? wallet = _selectedWallet ?? store.wallet!.mnemonicWallet;
    if (wallet == null) {
      AppLocalizations dic = AppLocalizations.of(context)!;
      UI.toast(dic.noMnemonicWallet);
      return false;
    }
    String? password = await UI.showPasswordDialog(
      context: context,
      wallet: wallet,
      inputPasswordRequired: true,
    );
    if (password == null) {
      return false;
    }
    final accountData = await webApi.account.createAccountByAccountIndex(
      wallet,
      accountName,
      password,
    );
    if (accountData?['error'] != null) {
      UI.toast(accountData?['error']['message']);
      return false;
    }
    AppLocalizations dic = AppLocalizations.of(context)!;
    if (accountData == null) {
      UI.toast(dic.passwordError);
      return false;
    } else {
      final existing = store.wallet!.accountListAll
          .firstWhereOrNull((a) => a.pubKey == accountData['pubKey']);
      if (existing != null) {
        UI.toast(dic.improtRepeat);
        return false;
      }
      await store.wallet!.addAccount(accountData, accountName, wallet);
      store.walletConnectService?.emitAccountsChanged(
        accountData['pubKey'],
      );
      store.assets!.loadAccountCache();
      store.assets!.setAssetsLoading(true);
      webApi.assets.fetchAllTokenAssets();
      return true;
    }
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Divider(height: 1),
            ...hdWallets.map(
              (wallet) => ListTile(
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
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Create account directly with default name (skip name input)
  Future<void> _createAccountDirectly(WalletData wallet) async {
    final accountName = WalletStore.defaultAccountName(
      store.wallet!.getNextWalletAccountIndex(wallet) + 1,
    );
    final success = await _onSubmitAccountName(accountName);
    if (success) {
      Navigator.popUntil(
        context,
        (route) => route.settings.name == WalletManagePage.route,
      );
    }
  }

  String _getNextImportWalletName() {
    int count =
        store.wallet!.getNextWalletIndexOfType(WalletStore.seedTypePrivateKey) +
        1;
    return 'Imported $count';
  }

  void _onPrivateKey() {
    // Go directly to import page with default name (skip name input)
    Navigator.pushReplacementNamed(
      context,
      ImportPrivateKeyPage.route,
      arguments: {"accountName": _getNextImportWalletName()},
    );
  }

  void _onKeyStore() {
    // Go directly to import page with default name (skip name input)
    Navigator.pushReplacementNamed(
      context,
      ImportKeyStorePage.route,
      arguments: {"accountName": _getNextImportWalletName()},
    );
  }

  void _showLedgerImport() async {
    int count =
        store.wallet!.getNextWalletIndexOfType(WalletStore.seedTypeLedger) + 1;
    final ledgerWalletName = 'Ledger $count';
    // Go to Connect Hardware Wallet intro page
    Navigator.pushNamed(
      context,
      ConnectHardwareWalletIntroPage.route,
      arguments: ConnectHardwareWalletIntroParams(
        defaultName: ledgerWalletName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(dic.addAccount), centerTitle: true),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            children: <Widget>[
              MenuItem(text: dic.createAccount, onTap: _onCreate),
              MenuItem(text: dic.privateKey, onTap: _onPrivateKey),
              MenuItem(text: dic.keystoreWallet, onTap: _onKeyStore),
              MenuItem(text: dic.hardwareWallet, onTap: _showLedgerImport),
            ],
          ),
        ),
      ),
    );
  }
}
