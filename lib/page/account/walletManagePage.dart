import 'package:auro_wallet/common/components/accountItem.dart';
import 'package:auro_wallet/common/components/customPromptDialog.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/addAccountPage.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/accountInfo.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
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

  void onClickAddAccount() {
    Navigator.pushNamed(context, AddAccountPage.route);
  }

  List<Widget> _renderAccountList() {
    Map<String, WalletData> walletMap = store.wallet!.walletsMap;
    List<Widget> items = [];
    final watchModeAccounts = store.wallet!.watchModeAccountListAll;
    AppLocalizations dic = AppLocalizations.of(context)!;
    final renderItem = (account) {
      AccountInfo? balancesInfo = store.assets!.accountsInfo[account.pubKey];
      print('balancesInfo');
      print(balancesInfo?.total);
      return WalletItem(
        account: account,
        balance: balancesInfo?.total ?? BigInt.from(0),
        store: store,
        wallet: walletMap[account.walletId]!,
      );
    };
    items.addAll(store.wallet!.accountListAll.map((account) {
      return renderItem(account);
    }));
    items.add(Container(
        child: Center(
      child: SvgBackgroundTextWidget(
          svgAssetPath: "assets/images/assets/icon_add_border.svg",
          text: dic.addAccount,
          onClick: onClickAddAccount),
    )));
    if (watchModeAccounts.length > 0) {
      items.add(Padding(
        padding: EdgeInsets.only(left: 28),
        child: Text(
          dic.noMoreSupported,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ));
      items.addAll(watchModeAccounts.map((account) {
        return renderItem(account);
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
          dic.accountManage,
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
                  children: _renderAccountList(),
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
