import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/page/account/exportResultPage.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
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
    AppLocalizations dic = AppLocalizations.of(context)!;
    
    final newName = await _showRenameDialog(walletName);
    if (newName != null && newName.isNotEmpty && newName != walletName) {
      setState(() => _isLoading = true);
      
      final success = await store.wallet!.renameWallet(wallet.id, newName);
      
      setState(() => _isLoading = false);
      
      if (success) {
        setState(() {
          walletName = newName;
        });
        UI.toast(dic.walletRenamed);
      }
    }
  }

  Future<String?> _showRenameDialog(String currentName) async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentName);
    
    return showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.hardEdge,
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                dic.changeWalletName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: InputItem(
                maxLength: 20,
                initialValue: currentName,
                placeholder: dic.walletNamePlaceholder,
                padding: EdgeInsets.only(top: 20),
                controller: controller,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              height: 1,
              color: Colors.black12,
            ),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text(
                        dic.cancel,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                Container(
                  width: 0.5,
                  height: 48,
                  color: Colors.black12,
                ),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text(
                        dic.confirm,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) {
                          Navigator.of(context).pop(text);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
      UI.toast(dic.walletDeleted);
      // Go back to wallet manage page
      Navigator.of(context).pop(true);
    } else {
      UI.toast(dic.passwordError);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.walletDetails),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
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
          
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
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
