import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/page/account/exportResultPage.dart';
import 'package:auro_wallet/common/components/changeNameDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// Wallet Details Page - similar to browser extension's WalletDetails
/// Provides: rename wallet, show seed phrase, delete wallet
class WalletDetailsPage extends StatefulWidget {
  const WalletDetailsPage(this.store);

  static final String route = '/wallet/details';
  final AppStore store;

  @override
  _WalletDetailsPageState createState() => _WalletDetailsPageState(store);
}

class _WalletDetailsPageState extends State<WalletDetailsPage> {
  _WalletDetailsPageState(this.store);

  final AppStore store;
  late WalletData wallet;
  late String walletName;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    wallet = args['wallet'] as WalletData;
    walletName = store.wallet!.getWalletDisplayName(wallet);
  }

  bool get isHDWallet => wallet.walletType == WalletStore.seedTypeMnemonic;

  Future<void> _onRenameWallet() async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) {
        return ChangeNameDialog(
          title: AppLocalizations.of(context)!.changeWalletName,
          placeholder: walletName,
          maxLength: 20,
        );
      },
    );
    if (newName != null && newName.isNotEmpty) {
      await store.wallet!.renameWallet(wallet.id, newName);
      setState(() {
        walletName = newName;
      });
    }
  }

  Future<void> _onShowSeedPhrase() async {
    if (!isHDWallet) return;
    
    String? password = await UI.showPasswordDialog(
      context: context,
      wallet: wallet,
      inputPasswordRequired: true,
    );
    
    if (password == null) return;
    
    final mnemonic = await store.wallet!.getMnemonic(wallet, password);
    if (mnemonic != null && mnemonic.isNotEmpty) {
      Navigator.of(context).pushNamed(
        ExportResultPage.route,
        arguments: {'key': mnemonic, 'type': 'mnemonic'},
      );
    } else {
      AppLocalizations dic = AppLocalizations.of(context)!;
      UI.toast(dic.passwordError);
    }
  }

  Future<void> _onDeleteWallet() async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    
    // Show confirmation dialog
    bool? confirmed = await UI.showConfirmDialog(
      context: context,
      title: dic.deleteWallet,
      contents: [dic.deleteWalletWarning],
      okText: dic.confirm,
      cancelText: dic.cancel,
      okColor: Color(0xFFD65A5A),
    );
    
    if (confirmed != true) return;
    
    // Get password (skip for watch-only wallets)
    String password = '';
    if (wallet.walletType != WalletStore.seedTypeNone) {
      String? pwd = await UI.showPasswordDialog(
        context: context,
        wallet: wallet,
        inputPasswordRequired: true,
      );
      if (pwd == null) return;
      password = pwd;
    }
    
    setState(() => _isLoading = true);
    
    final success = await store.wallet!.deleteWallet(wallet.id, password);
    
    setState(() => _isLoading = false);
    
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      UI.toast(dic.passwordError);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(dic.walletDetails),
            centerTitle: true,
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Observer(
              builder: (_) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wallet Name Row
                  _buildInfoRow(
                    title: dic.walletNameLabel,
                    value: walletName,
                    onTap: _onRenameWallet,
                    showArrow: true,
                  ),
                  // Seed Phrase Row (only for HD wallets)
                  if (isHDWallet)
                    _buildInfoRow(
                      title: dic.seedPhrase,
                      onTap: _onShowSeedPhrase,
                      showArrow: true,
                    ),
                  
                  SizedBox(height: 16),
                  
                  // Delete button - left aligned red text
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: InkWell(
                      onTap: _onDeleteWallet,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          dic.delete,
                          style: TextStyle(
                            color: Color(0xFFD65A5A),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black45,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String title,
    String? value,
    VoidCallback? onTap,
    bool showArrow = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  if (value != null)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
