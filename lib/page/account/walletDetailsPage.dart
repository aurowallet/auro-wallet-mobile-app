import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/page/account/exportResultPage.dart';
import 'package:auro_wallet/common/components/changeNameDialog.dart';
import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      if (!mounted) return;
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
    if (!mounted) return;
    
    final mnemonic = await store.wallet!.getMnemonic(wallet, password);
    if (mnemonic != null && mnemonic.isNotEmpty) {
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        ExportResultPage.route,
        arguments: {'key': mnemonic, 'type': 'mnemonic'},
      );
    } else {
      if (!mounted) return;
      AppLocalizations dic = AppLocalizations.of(context)!;
      UI.toast(dic.passwordError);
    }
  }

  Future<void> _onDeleteWallet() async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    
    bool? confirmed = await UI.showConfirmDialog(
      context: context,
      title: dic.deleteWallet,
      contents: [dic.deleteWalletWarning],
      okText: dic.confirm,
      cancelText: dic.cancel,
      okColor: Color(0xFFD65A5A),
    );
    
    if (confirmed != true) return;
    
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
    
    if (!mounted) return;
    
    if (success) {
      if (store.wallet!.walletList.isEmpty) {
        await webApi.account.resetAllSecurityFlags();
        if (!mounted) return;
        store.wallet!.clearRuntimePwd();
        store.settings!.setLockWalletStatus(false);
        store.walletConnectService?.clearAllPairings();
        Phoenix.rebirth(context);
        return;
      }
      setState(() => _isLoading = false);
      Navigator.of(context).pop(true);
    } else {
      setState(() => _isLoading = false);
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
                      title: dic.restoreSeed,
                      onTap: _onShowSeedPhrase,
                      showArrow: true,
                    ),
                  
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    height: 1,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.10),
                    ),
                  ),
                  TextButton(
                    child: Text(dic.delete),
                    onPressed: _onDeleteWallet,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      textStyle: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      foregroundColor: Color(0xFFD65A5A),
                      minimumSize: Size(double.infinity, 54),
                      alignment: Alignment.centerLeft,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                child: RotatingCircle(size: 30, color: Theme.of(context).primaryColor),
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
        constraints: BoxConstraints(minHeight: 55),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withValues(alpha: 0.3),
                          height: 1.2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (showArrow)
              Container(
                width: 6,
                margin: EdgeInsets.only(left: 14),
                child: SvgPicture.asset(
                  'assets/images/assets/right_arrow.svg',
                  width: 6,
                  height: 12,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
