import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auro_wallet/page/account/accountNamePage.dart';
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

  String _getNextImportWalletName() {
   int count = store.wallet!.getNextWalletIndexOfType(WalletStore.seedTypePrivateKey) + 1;
    return 'Import Account $count';
  }

  String _getNextWatchedWalletName() {
    int count = store.wallet!.getNextWalletIndexOfType(WalletStore.seedTypeNone) + 1;
    return 'Watched Account $count';
  }

  void _onPrivateKey() {
    Navigator.pushReplacementNamed(context, AccountNamePage.route, arguments: AccountNameParams(
      redirect: ImportPrivateKeyPage.route,
      placeholder: _getNextImportWalletName()
    ));
  }

  void _onKeyStore() {
    Navigator.pushReplacementNamed(context, AccountNamePage.route, arguments: AccountNameParams(
        redirect: ImportKeyStorePage.route,
        placeholder: _getNextImportWalletName()
    ));
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.import),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
            padding: EdgeInsets.only(left: 0, right: 0, top: 20),
          child: Column(
            children: <Widget>[
                ImportItem(
                  text: dic.privateKey,
                  onClick: _onPrivateKey,
                ),
                ImportItem(
                  text: 'Keystore',
                  onClick: _onKeyStore,
                ),
                // ImportItem(
                //   text: dic['watchAccount']!,
                //   onClick: _onWatchMode,
                // ),
              ],
          )
        ),
      ),
    );
  }
}

class ImportItem extends StatelessWidget {
  ImportItem({required this.text,required this.onClick});

  final String text;
  final void Function() onClick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            // border: Border(bottom: BorderSide(width: 1, color: ColorsUtil.hexColor(0xeeeeee))),
          ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: TextStyle(fontSize: 16, color: ColorsUtil.hexColor(0x010000)),),
            Container(
                width: 6,
                margin: EdgeInsets.only(left: 14,),
                child: SvgPicture.asset(
                    'assets/images/assets/right_arrow.svg',
                    width: 6,
                    height: 12
                )
            ),
          ],
        )
      )
    );
  }
}
