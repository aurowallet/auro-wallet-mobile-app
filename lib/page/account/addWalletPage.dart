import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/import/importWaysPage.dart';
import 'package:auro_wallet/page/account/create/backupMnemonicTipsPage.dart';
import 'package:auro_wallet/page/account/connectHardwareWalletIntroPage.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Add Wallet Page - matches screenshot 2
/// Options: Create Wallet, Import Wallet, Hardware Wallet
class AddWalletPage extends StatelessWidget {
  const AddWalletPage(this.store);

  static final String route = '/wallet/add';
  final AppStore store;

  String _getNextHDWalletName() {
    int count = store.wallet!.getNextWalletIndexOfType(WalletStore.seedTypeMnemonic) + 1;
    return 'Wallet $count';
  }

  String _getNextLedgerWalletName() {
    int count = store.wallet!.getNextWalletIndexOfType(WalletStore.seedTypeLedger) + 1;
    return 'Ledger $count';
  }

  void _onCreateWallet(BuildContext context) async {
    // Verify password first (force password input, no biometric)
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
    Navigator.pushNamed(context, ImportWaysPage.route);
  }

  void _onHardwareWallet(BuildContext context) {
    // Go to Connect Hardware Wallet intro page
    Navigator.pushNamed(
      context,
      ConnectHardwareWalletIntroPage.route,
      arguments: ConnectHardwareWalletIntroParams(defaultName: _getNextLedgerWalletName()),
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
              _MenuItem(
                text: dic.createWallet,
                onTap: () => _onCreateWallet(context),
              ),
              _MenuItem(
                text: dic.importWallet,
                onTap: () => _onImportWallet(context),
              ),
              _MenuItem(
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

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            SvgPicture.asset(
              'assets/images/assets/right_arrow.svg',
              width: 6,
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}
