import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/page/account/create/backupMnemonicPage.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/page/account/import/importSuccessPage.dart';
class BackupMnemonicTipsPage extends StatefulWidget {
  const BackupMnemonicTipsPage(this.store);

  static final String route = '/account/backup_tips';
  final AppStore store;

  @override
  _BackupMnemonicTipsPageState createState() => _BackupMnemonicTipsPageState();
}

class _BackupMnemonicTipsPageState extends State<BackupMnemonicTipsPage> {
  Future<void> _onFinishedBackup(bool finished) async {
    if (finished) {
      EasyLoading.show(status: '');
      var acc = await webApi.account.importWalletByWalletParams();
      await webApi.account.saveWallet(
          acc,
          context: context,
          seedType: WalletStore.seedTypeMnemonic,
          walletSource: WalletSource.inside
      );
      EasyLoading.dismiss();
      await Navigator.pushNamedAndRemoveUntil(context, ImportSuccessPage.route, (Route<dynamic> route) => false, arguments: {
        'type': 'create'
      });
      // Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }
  }
  Future<void> _onNext() async {
    await Navigator.pushNamed(context, BackupMnemonicPage.route, arguments: {
      "callback": _onFinishedBackup
    });
    // Navigator.of(context).pop(finishedBackup);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    final Map<String, String> i18n = I18n.of(context).main;

    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).main['backTips_title']!)),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(i18n['backTips_1']!, style: theme.headline5!.copyWith(
                      height: 1.4
                    )),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(i18n['backTips_2']!, style: theme.headline5!.copyWith(
                        height: 1.4
                    )),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(i18n['backTips_3']!, style: theme.headline5!.copyWith(
                        height: 1.4
                    )),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: NormalButton(
                text: I18n.of(context).main['next']!,
                onPressed: () => _onNext(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
