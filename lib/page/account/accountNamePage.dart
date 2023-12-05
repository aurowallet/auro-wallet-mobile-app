import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
class AccountNameParams {
  AccountNameParams({
    this.redirect,
    this.callback,
    this.placeholder,
  });
  final String? redirect;
  final String? placeholder;
  final Future<bool> Function(String accountName)? callback;
}

class AccountNamePage extends StatefulWidget {
  const AccountNamePage(this.store);

  static final String route = '/wallet/accountName';
  final AppStore store;

  @override
  _AccountNamePageState createState() => _AccountNamePageState(store);
}

class _AccountNamePageState extends State<AccountNamePage> {
  _AccountNamePageState(this.store);

  final AppStore store;
  final TextEditingController _nameCtrl = new TextEditingController();
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameCtrl.addListener(_onTextChange);
    });
  }
  @override
  void dispose() {
    super.dispose();
    _nameCtrl.dispose();
  }

  void _onTextChange() {
  }
  void _handleSubmit() async {
    AccountNameParams params = ModalRoute.of(context)!.settings.arguments as AccountNameParams;
    String accountName = _nameCtrl.text.trim();
    if (accountName.isEmpty && params.placeholder != null) {
      accountName = params.placeholder!;
    }
    if (params.callback != null) {
      setState(() {
        submitting = true;
      });
      bool res = await params.callback!(accountName);
      setState(() {
        submitting = false;
      });
      if (res) {
        Navigator.of(context).pop();
      }
      return;
    }
    if (params.redirect != null && params.redirect!.isNotEmpty) {
      Navigator.pushReplacementNamed(context, params.redirect!, arguments: {"accountName": accountName});
    }
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;
    AccountNameParams params = ModalRoute.of(context)!.settings.arguments as AccountNameParams;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['accountName']!),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    InputItem(
                      maxLength: 16,
                      label: dic['accountNameTip']!,
                      initialValue: '',
                      placeholder: params.placeholder,
                      controller: _nameCtrl,
                    ),
                  ]
                )
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 30),
                  child:
                  NormalButton(
                    color: ColorsUtil.hexColor(0x6D5FFE),
                    text: I18n.of(context).main['confirm']!,
                    onPressed: _handleSubmit,
                    submitting:submitting
                  )

              )
            ],
          ),
        )
      ),
    );
  }
}
