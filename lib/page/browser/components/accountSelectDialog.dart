import 'package:auro_wallet/common/components/accountItem.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/accountInfo.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AccountSelectDialog extends StatefulWidget {
  AccountSelectDialog({
    required this.onSelectAccount,
  });

  final Function(String) onSelectAccount;

  @override
  _AccountSelectDialogState createState() => new _AccountSelectDialogState();
}

class _AccountSelectDialogState extends State<AccountSelectDialog> {
  final store = globalAppStore;

  @override
  void initState() {
    super.initState();
  }

  Widget renderDrapbar() {
    return Container(
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10)),
          )
        ],
      ),
    );
  }

  List<Widget> _renderAccountList() {
    Map<String, WalletData> walletMap = store.wallet!.walletsMap;
    List<Widget> items = [];
    AppLocalizations dic = AppLocalizations.of(context)!;
    final renderItem = (account) {
      AccountInfo? balancesInfo = store.assets!.accountsInfo[account.pubKey];
      print(balancesInfo?.total);
      return WalletItem(
          account: account,
          balance: balancesInfo?.total ?? BigInt.from(0),
          store: store,
          wallet: walletMap[account.walletId]!,
          hideOption: true,
          onSelectAccount: widget.onSelectAccount,
          );
    };
    items.addAll(store.wallet!.accountListAll.map((account) {
      return renderItem(account);
    }));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double containerMaxHeight = screenHeight * 0.6;
    return Container(
        height: containerMaxHeight,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            )),
        child: SafeArea(child: Observer(builder: (BuildContext context) {
          return Column(
            children: [
              renderDrapbar(),
              Expanded(
                child: ListView(
                  children: _renderAccountList(),
                ),
              ),
            ],
          );
        })));
  }
}
