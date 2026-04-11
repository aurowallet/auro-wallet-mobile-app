import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/common/components/menuItem.dart';
import 'package:auro_wallet/page/account/import/importMnemonicPage.dart';
import 'package:auro_wallet/page/account/import/importPrivateKeyPage.dart';
import 'package:auro_wallet/page/account/import/importKeyStorePage.dart';

class ImportWaysPage extends StatefulWidget {
  const ImportWaysPage(this.store);

  static final String route = '/wallet/import';
  final AppStore store;

  @override
  _ImportWaysPageState createState() => _ImportWaysPageState(store);
}

class _ImportWaysPageState extends State<ImportWaysPage> {
  _ImportWaysPageState(this.store);

  final AppStore store;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _getNextHDWalletName() {
    int count =
        store.wallet!.getNextWalletIndexOfType(WalletStore.seedTypeMnemonic) +
        1;
    return 'Wallet $count';
  }

  String _getNextImportWalletName() {
    int count =
        store.wallet!.getNextWalletIndexOfType(WalletStore.seedTypePrivateKey) +
        1;
    return 'Imported $count';
  }

  void _onMnemonic() {
    store.wallet!.resetNewWallet();
    store.wallet!.setNewWalletName(_getNextHDWalletName());
    Navigator.pushNamed(context, ImportMnemonicPage.route);
  }

  void _onPrivateKey() {
    store.wallet!.resetNewWallet();
    Navigator.pushNamed(
      context,
      ImportPrivateKeyPage.route,
      arguments: {"accountName": _getNextImportWalletName()},
    );
  }

  void _onKeyStore() {
    store.wallet!.resetNewWallet();
    Navigator.pushNamed(
      context,
      ImportKeyStorePage.route,
      arguments: {"accountName": _getNextImportWalletName()},
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(dic.importWallet), centerTitle: true),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            children: <Widget>[
              MenuItem(text: dic.mnemonicPhrase, onTap: _onMnemonic),
              MenuItem(text: dic.privateKey, onTap: _onPrivateKey),
              MenuItem(text: dic.keystoreWallet, onTap: _onKeyStore),
            ],
          ),
        ),
      ),
    );
  }
}
