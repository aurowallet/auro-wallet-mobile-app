import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExportResultPage extends StatelessWidget {
  static final String route = '/wallet/account_key';

  void _showExportDialog(BuildContext context, Map args) async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    bool? rejected = await UI.showConfirmDialog(context: context, contents: [
      dic.copyTipContent,
      '\n',
      dic.copyTipContent2,
    ], okText: dic.copyCancel, cancelText: dic.copyConfirm);
    if (rejected != null && !rejected) {
      Clipboard.setData(ClipboardData(
        text: args['key'],
      ));
      UI.toast(dic.copySuccess);
      await new Future.delayed(const Duration(milliseconds: 1500));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(dic.exportPrivateKey)),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                children: <Widget>[
                  Text(dic.walletAddress, style: textTheme.headlineMedium!.copyWith(color: ColorsUtil.hexColor(0x666666))),
                  Padding(padding: EdgeInsets.only(top: 10),),
                  Text(args['address'], style: textTheme.headlineMedium!.copyWith(color: ColorsUtil.hexColor(0x333333))),
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xFFF9FAFC),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          args['key'],
                          style: textTheme.headlineMedium!.copyWith(color: ColorsUtil.hexColor(0x333333)),
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SvgPicture.asset(
                                'assets/images/assets/copy.svg',
                                width: 15,
                                height: 16,
                                color: Theme.of(context).primaryColor
                            ),
                            GestureDetector(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                                child: Text(
                                  dic.copyToClipboard,
                                  style: textTheme.headlineMedium!.copyWith(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                              onTap: () => _showExportDialog(context, args),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
