import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/import/importWaysPage.dart';
import 'package:auro_wallet/page/account/create/backupMnemonicTipsPage.dart';
import 'package:auro_wallet/page/account/connectHardwareWalletIntroPage.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/menuItem.dart';

class AddWalletPage extends StatelessWidget {
  const AddWalletPage(this.store);

  static final String route = '/wallet/add';
  final AppStore store;

  String _getNextHDWalletName() {
    int count =
        store.wallet!.getNextWalletIndexOfType(WalletStore.seedTypeMnemonic) +
            1;
    return 'Wallet $count';
  }

  String _getNextLedgerWalletName() {
    int count =
        store.wallet!.getNextWalletIndexOfType(WalletStore.seedTypeLedger) + 1;
    return 'Ledger $count';
  }

  void _onCreateWallet(BuildContext context) async {
    store.wallet!.resetNewWallet();
    final currentWallet = store.wallet!.currentWallet;
    final password = await UI.showPasswordDialog(
      context: context,
      wallet: currentWallet,
      inputPasswordRequired: true,
    );

    if (password == null) return;

    // Set the verified password and default wallet name for new wallet creation
    store.wallet!.setNewAccount(password);
    store.wallet!.setNewWalletName(_getNextHDWalletName());

    // Go directly to backup mnemonic flow (skip name input)
    Navigator.pushNamed(context, BackupMnemonicTipsPage.route);
  }

  void _onImportWallet(BuildContext context) {
    store.wallet!.resetNewWallet();
    Navigator.pushNamed(context, ImportWaysPage.route);
  }

  void _onHardwareWallet(BuildContext context) {
    store.wallet!.resetNewWallet();
    Navigator.pushNamed(
      context,
      ConnectHardwareWalletIntroPage.route,
      arguments: ConnectHardwareWalletIntroParams(
          defaultName: _getNextLedgerWalletName()),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.addWallet),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            children: [
              MenuItem(
                text: dic.createWallet,
                onTap: () => _onCreateWallet(context),
              ),
              MenuItem(
                text: dic.importWallet,
                onTap: () => _onImportWallet(context),
              ),
              MenuItem(
                text: dic.hardwareWallet,
                onTap: () => _onHardwareWallet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
