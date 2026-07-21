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
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auro_wallet/common/consts/testKeys.dart';

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
    final accountName = WalletStore.defaultAccountName(store.wallet!.getNextWalletAccountIndex(wallet) + 1);
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
    if (await UI.showDuplicateAccountAlertIfNeeded(
      context: context,
      walletStore: store.wallet!,
      pubKey: accountData['pubKey'],
    )) {
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
    if (keyring.type != WalletStore.keyringTypeHD) return;
    final wallet = store.wallet!.walletList.firstWhereOrNull((w) => w.id == keyring.id);
    if (wallet != null) {
      Navigator.pushNamed(context, WalletDetailsPage.route, arguments: {'wallet': wallet});
    }
  }

  void _onAccountTap(UIKeyringAccount account) async {
    if (account.address == store.wallet!.currentAddress) {
      Navigator.of(context).pop();
      return;
    }
    await webApi.account.changeCurrentAccount(pubKey: account.address, fetchData: true);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _onAccountDetails(UIKeyringAccount account) {
    final wallet = store.wallet!.walletList.firstWhereOrNull((w) => w.id == account.walletId);
    if (wallet == null) return;
    
    final accountData = wallet.accounts.firstWhereOrNull((a) => a.pubKey == account.address);
    if (accountData == null) return;
    
    Navigator.pushNamed(context, AccountManagePage.route, arguments: {
      'account': accountData,
      'wallet': wallet,
    });
  }

  List<Widget> _renderKeyringList() {
    final keyringsList = store.wallet!.getKeyringsList();
    final currentAddress = store.wallet!.currentAddress;
    final watchModeAccounts = store.wallet!.watchModeAccountListAll;
    Map<String, WalletData> walletMap = store.wallet!.walletsMap;
    AppLocalizations dic = AppLocalizations.of(context)!;
    
    final Map<String, BigInt> balanceMap = {};
    store.assets!.accountsInfo.forEach((key, value) {
      balanceMap[key] = value.total;
    });
    
    List<Widget> items = [];
    
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
      await webApi.account.resetAllSecurityFlags();
      if (!mounted) return;
      store.wallet!.clearRuntimePwd();
      store.settings!.setLockWalletStatus(false);
      store.walletConnectService?.clearAllPairings();

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
              Container(
                padding: EdgeInsets.only(left: 38, right: 37, top: 12, bottom: 30),
                child: NormalButton(
                  key: TestKeys.addWalletButton,
                  text: dic.addWallet,
                  color: Theme.of(context).primaryColor,
                  onPressed: _onAddWallet,
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
                  color: Theme.of(context).primaryColor,
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
