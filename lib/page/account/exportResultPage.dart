import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExportResultPage extends StatelessWidget {
  static final String route = '/wallet/account_key';

  void _showExportDialog(BuildContext context, Map args) async {
    var dic = I18n.of(context).main;
    bool? rejected = await UI.showConfirmDialog(context: context, contents: [
      dic['copyTipContent']!
    ], okText: dic['copyCancel']!, cancelText: dic['copyConfirm']!);
    if (rejected != null && !rejected) {
      Clipboard.setData(ClipboardData(
        text: args['key'],
      ));
      UI.toast(dic['copySuccess']!);
      await new Future.delayed(const Duration(milliseconds: 1500));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(dic['exportPrivateKey']!)),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                children: <Widget>[
                  Text(dic['walletAddress']!, style: textTheme.headline5!.copyWith(color: ColorsUtil.hexColor(0x666666))),
                  Padding(padding: EdgeInsets.only(top: 10),),
                  Text(args['address'], style: textTheme.headline5!.copyWith(color: ColorsUtil.hexColor(0x333333))),
                  Container(
                    decoration: BoxDecoration(
                        color: ColorsUtil.hexColor(0xD8D8D8),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    padding: EdgeInsets.all(23),
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      args['key'],
                      style: textTheme.headline5!.copyWith(color: ColorsUtil.hexColor(0x333333)),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.asset(
                          'assets/images/assets/copy.svg',
                          width: 15,
                          height: 16,
                          color: Theme.of(context).primaryColor
                      ),
                      GestureDetector(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 5),
                          child: Text(
                            I18n.of(context).main['copyToClipboard']!,
                            style: textTheme.headline5!.copyWith(
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
    );
  }
}
