import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/page/account/setNewWalletPasswordPage.dart';
class TermParams {
  TermParams({
    this.showBtn = true,
    this.arguments,
  });
  final bool showBtn;
  final Map? arguments;
}

class TermPage extends StatefulWidget {
  const TermPage(this.store);

  static final String route = '/account/term';
  final AppStore store;

  @override
  _TermPageState createState() => _TermPageState(store);
}

class _TermPageState extends State<TermPage> {
  _TermPageState(this.store);

  final AppStore store;



  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  void _handleSubmit() async {
    TermParams params = ModalRoute.of(context)!.settings.arguments as TermParams;
    Navigator.pushNamed(context, SetNewWalletPasswordPage.route, arguments: params.arguments);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;
    TermParams params = ModalRoute.of(context)!.settings.arguments as TermParams;
    bool showBtn = params == null || params.showBtn;
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['userAgree']!),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 30, right: 30, top: 20),
          child: Column(
            children: [
              Expanded(
                child: Container(
                    decoration: BoxDecoration(
                    ),
                    child: ListView(
                      children: [
                        Text(dic['term']!, style: theme.headline5!.copyWith(
                        height: 1.4
                      ))
                      ]
                    )
                ),
              ),
              showBtn ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  child:  NormalButton(
                    color: ColorsUtil.hexColor(0x6D5FFE),
                    text: I18n.of(context).main['agree']!,
                    onPressed: _handleSubmit,
                  )
              ) : Padding(
                padding: EdgeInsets.only(top: 30),
              )
            ],
          ),
        )
      ),
    );
  }
}
