import 'package:collection/collection.dart';
import 'package:auro_wallet/common/components/accountItem.dart';
import 'package:auro_wallet/common/components/customPromptDialog.dart';
import 'package:auro_wallet/common/components/keyringSection.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/accountManagePage.dart';
import 'package:auro_wallet/page/account/addWalletPage.dart';
import 'package:auro_wallet/page/account/walletDetailsPage.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/accountInfo.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/types/uiKeyring.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  void _onAddWallet() {
    Navigator.pushNamed(context, AddWalletPage.route);
  }

  /// Add account directly with password dialog (no navigation)
  Future<void> _onAddAccountToKeyring(String keyringId) async {
    final wallet = store.wallet!.walletList.firstWhereOrNull((w) => w.id == keyringId);
    if (wallet == null) return;
    
    AppLocalizations dic = AppLocalizations.of(context)!;
    
    // Show password dialog
    String? password = await UI.showPasswordDialog(
      context: context,
      wallet: wallet,
      inputPasswordRequired: true,
    );
    if (password == null) return;
    
    // Create account with next HD index
    final accountName = 'Account ${store.wallet!.getNextWalletAccountIndex(wallet) + 1}';
    final accountData = await webApi.account.createAccountByAccountIndex(wallet, accountName, password);
    
    if (accountData?['error'] != null) {
      UI.toast(accountData?['error']['message']);
      return;
    }
    
    if (accountData == null) {
      UI.toast(dic.passwordError);
      return;
    }
    
    // Check if account already exists
    final matchedAccount = store.wallet!.accountListAll
        .firstWhereOrNull((account) => account.pubKey == accountData['pubKey']);
    
    if (matchedAccount != null) {
      UI.showAlertDialog(
        context: context,
        crossAxisAlignment: CrossAxisAlignment.start,
        contents: [
          dic.importSameAccount_1(matchedAccount.address) + "\n",
          dic.importSameAccount_2(matchedAccount.name)
        ],
        confirm: dic.isee,
      );
      return;
    }
    
    // Add account
    await store.wallet!.addAccount(accountData, accountName, wallet);
    store.walletConnectService?.emitAccountsChanged(accountData['pubKey']);
    store.assets!.loadAccountCache();
    store.assets!.setAssetsLoading(true);
    webApi.assets.fetchAllTokenAssets();
    
    // Refresh balance for new account
    webApi.assets.fetchBatchAccountsInfo(
      store.wallet!.accountListAll.map((acc) => acc.pubKey).toList(),
    );
  }

  void _onGoToWalletDetails(UIKeyring keyring) {
    // Only HD wallets have individual wallet details
    if (keyring.type != WalletStore.keyringTypeHD) return;
    final wallet = store.wallet!.walletList.firstWhereOrNull((w) => w.id == keyring.id);
    if (wallet != null) {
      Navigator.pushNamed(context, WalletDetailsPage.route, arguments: {'wallet': wallet});
    }
  }

  void _onAccountTap(UIKeyringAccount account) async {
    await webApi.account.changeCurrentAccount(pubKey: account.address, fetchData: true);
    Navigator.of(context).pop();
  }

  void _onAccountDetails(UIKeyringAccount account) {
    // Find the wallet and account data for this UI account
    final wallet = store.wallet!.walletList.firstWhereOrNull((w) => w.id == account.walletId);
    if (wallet == null) return;
    
    final accountData = wallet.accounts.firstWhereOrNull((a) => a.pubKey == account.address);
    if (accountData == null) return;
    
    // Navigate to account manage page with correct parameters
    Navigator.pushNamed(context, AccountManagePage.route, arguments: {
      'account': accountData,
      'wallet': wallet,
    });
  }

  /// Build keyring-based UI list (React extension style)
  List<Widget> _renderKeyringList() {
    final keyringsList = store.wallet!.getKeyringsList();
    final currentAddress = store.wallet!.currentAddress;
    final watchModeAccounts = store.wallet!.watchModeAccountListAll;
    Map<String, WalletData> walletMap = store.wallet!.walletsMap;
    AppLocalizations dic = AppLocalizations.of(context)!;
    
    // Build balance map
    final Map<String, BigInt> balanceMap = {};
    store.assets!.accountsInfo.forEach((key, value) {
      balanceMap[key] = value.total;
    });
    
    List<Widget> items = [];
    
    // Add keyring sections
    for (final keyring in keyringsList) {
      items.add(KeyringSection(
        keyring: keyring,
        currentAddress: currentAddress,
        balanceMap: balanceMap,
        onAccountTap: _onAccountTap,
        onAccountDetails: _onAccountDetails,
        onAddAccount: keyring.canAddAccount ? () => _onAddAccountToKeyring(keyring.id) : null,
        onWalletDetails: keyring.type == WalletStore.keyringTypeHD ? () => _onGoToWalletDetails(keyring) : null,
      ));
    }
    
    // Watch mode accounts (not supported notice)
    if (watchModeAccounts.isNotEmpty) {
      items.add(Padding(
        padding: EdgeInsets.only(left: 28, top: 16),
        child: Text(
          dic.noMoreSupported,
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w600, 
            color: Colors.black,
          ),
        ),
      ));
      
      items.addAll(watchModeAccounts.map((account) {
        AccountInfo? balancesInfo = store.assets!.accountsInfo[account.pubKey];
        return WalletItem(
          account: account,
          balance: balancesInfo?.total ?? BigInt.from(0),
          store: store,
          wallet: walletMap[account.walletId]!,
        );
      }));
    }
    
    return items;
  }

  void _onResetApp() async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    bool? confirmed = await UI.showConfirmDialog(
        context: context,
        icon: SvgPicture.asset(
          'assets/images/public/error.svg',
          width: 58,
          height: 58,
        ),
        title: dic.resetWarnContentTitle,
        contents: [dic.resetWarnContent],
        okColor: Color(0xFFD65A5A),
        okText: dic.confirmReset,
        cancelText: dic.cancelReset);
    if (confirmed != true) {
      return;
    }
    String deleteTag = dic.delete.toLowerCase();
    String? confirmInput = await showDialog<String>(
      context: context,
      builder: (_) {
        return CustomPromptDialog(
          title: dic.deleteConfirm(deleteTag),
          placeholder: deleteTag,
          onOk: (String? text) {
            if (text == null || text.isEmpty) {
              return false;
            }
            return true;
          },
          validate: (text) {
            return text.toLowerCase() == deleteTag;
          },
        );
      },
    );
    if (confirmInput != null &&
        confirmInput.toLowerCase() == dic.delete.toLowerCase()) {
      store.wallet!.clearWallets();
      store.assets!.clearAccountCache();
      webApi.account.setBiometricDisabled();

      // reset pwd verification
      webApi.account.setAppAccessDisabled();
      webApi.account.setTransactionPwdEnabled();
      store.wallet!.clearRuntimePwd();

      Phoenix.rebirth(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        title: Text(
          dic.walletManagement,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: <Widget>[
          TextButton(
            style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.transparent)),
            child: Text(
              dic.reset,
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
                  children: _renderKeyringList(),
                ),
              ),
              // Add Wallet button at bottom - purple solid button with proper spacing
              Container(
                padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _onAddWallet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF594AF1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      dic.addWallet,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class SvgBackgroundTextWidget extends StatelessWidget {
  const SvgBackgroundTextWidget({
    Key? key,
    required this.svgAssetPath,
    required this.text,
    this.onClick,
  }) : super(key: key);

  final String svgAssetPath;
  final String text;
  final Function()? onClick;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 10, bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        width: MediaQuery.of(context).size.width - 40,
        height: 60,
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          onTap: () {
            if (onClick != null) {
              onClick!();
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned.fill(
                child: SvgPicture.asset(
                  svgAssetPath,
                  fit: BoxFit.fill,
                ),
              ),
              Text(
                text,
                style: TextStyle(
                  color: Color(0xFF594AF1),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ));
  }
}
