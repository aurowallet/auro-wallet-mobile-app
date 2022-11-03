import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/changeNameDialog.dart';
import 'package:auro_wallet/common/components/accountItem.dart';
import 'package:auro_wallet/common/components/copyContainer.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/assets/types/accountInfo.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/page/account/exportResultPage.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountManagePage extends StatefulWidget {
  const AccountManagePage(this.store);

  static final String route = '/account/manage';
  final AppStore store;

  @override
  _AccountManagePageState createState() => _AccountManagePageState(store);
}

class _AccountManagePageState extends State<AccountManagePage> {
  _AccountManagePageState(this.store);

  final AppStore store;
  late AccountData account;
  late WalletData wallet;
  bool isWatchedAccount = false;

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Map<String,dynamic> params = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>;
    account = params['account'];
    wallet = params['wallet'];
    isWatchedAccount = wallet.walletType == WalletStore.seedTypeNone;
  }
  void _onExportPrivateKey() async {
    final Map<String, String> dic = I18n.of(context).main;
    await UI.showAlertDialog(
      context: context,
      contents:[
        dic['privateKeyTip_1']! + '\n',
        dic['privateKeyTip_2']!,
      ],
    );
    String? password = await UI.showPasswordDialog(context: context, wallet: wallet);
    if (password == null) {
      return;
    }
    String? privateKey = await webApi.account.getPrivateKey(wallet, account.accountIndex, password);
    if (privateKey == null) {
      UI.toast(dic['passwordError']!);
      return;
    }
    await Navigator.pushNamed(context, ExportResultPage.route, arguments: {
      "key": privateKey,
      "address": account.pubKey,
      "type": WalletStore.seedTypePrivateKey
    });
  }
  void _changeAccountName() async {
    String? accountName = await showDialog<String>(
      context: context,
      builder: (_) {
        return ChangeNameDialog();
      },
    );
    if(accountName != null && accountName.isNotEmpty) {
      await store.wallet!.updateAccountName(account, accountName);
      print('accountName:$accountName');
      setState(() {
        account = store.wallet!.walletsMap[account.walletId]!.accounts.firstWhere((acc) => acc.pubKey == account.pubKey);
      });
    }
  }
  void _deleteAccount() async {
    final Map<String, String> dic = I18n.of(context).main;
    print('do delete');
    if (isWatchedAccount) {
      await store.wallet!.removeAccount(account);
      print('account removed');
      UI.toast(dic['deleteAccountSuccess']!);
      Navigator.of(context).pop();
    } else {
      await UI.showAlertDialog(
        context: context,
        contents:[
          dic['deleteAccountTip']!
        ],
      );
      String? password = await UI.showPasswordDialog(context: context, wallet: wallet, validate: true);
      if (password == null) {
        return;
      }
      await store.wallet!.removeAccount(account);
      await store.assets!.loadAccountCache();
      globalBalanceRefreshKey.currentState!.show();
      print('account removed');
      UI.toast(dic['deleteAccountSuccess']!);
      Navigator.of(context).pop();
    }
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;
    final bool isMnemonicWallet = wallet.walletType == WalletStore.seedTypeMnemonic;
    return Scaffold(
      appBar: AppBar(
          title: Text(dic['accountInfo']!),
          centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CopyContainer(
                  child:  AccountInfoItem(label: dic['accountAddress']!, value: account.pubKey),
                  text: account.pubKey
              ),
              AccountInfoItem(label: dic['accountName']!, value: Fmt.accountName(account), onClick: _changeAccountName,),
              !isWatchedAccount ? AccountInfoItem(label: dic['exportPrivateKey']!, onClick: _onExportPrivateKey) : Container(),
              !isMnemonicWallet ? TextButton(
                child: Text(dic['accountDelete']!),
                onPressed: _deleteAccount,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: Color(0xFFD65A5A),
                  minimumSize: Size(double.infinity, 54),
                  alignment: Alignment.centerLeft,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ) : Container(),
            ],
          )
        ),
      ),
    );
  }
}

class AccountInfoItem extends StatelessWidget {
  AccountInfoItem({required this.label, this.value, this.onClick});

  final String label;
  final String? value;
  final void Function()? onClick;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return GestureDetector(
        onTap: onClick,
        child: Container(
            // height: 55,
          constraints: BoxConstraints(
            minHeight: 55
          ),
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 1, color: ColorsUtil.hexColor(0xeeeeee))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  // width: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                            fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600)),
                      value == null || value!.isEmpty
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                value!,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.3), height: 1.2))
                      )
                    ],
                  ),
                ),
                onClick != null ? Container(
                    width: 6,
                    margin: EdgeInsets.only(left: 14,),
                    child: SvgPicture.asset(
                        'assets/images/assets/right_arrow.svg',
                        width: 6,
                        height: 12,
                      color: Colors.black.withOpacity(0.3),
                    )
                ): Container(),
              ],
            )
        )
    );
  }
}
