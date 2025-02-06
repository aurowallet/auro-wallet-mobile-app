import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/page/account/create/backupMnemonicPage.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

class BackupMnemonicTipsPage extends StatefulWidget {
  const BackupMnemonicTipsPage(this.store);

  static final String route = '/account/backup_tips';
  final AppStore store;

  @override
  _BackupMnemonicTipsPageState createState() => _BackupMnemonicTipsPageState();
}

class _BackupMnemonicTipsPageState extends State<BackupMnemonicTipsPage> {
  bool value1Checked = false;
  bool value2Checked = false;


  Future<void> _onNext() async {
    await Navigator.pushNamed(context, BackupMnemonicPage.route);
    // Navigator.of(context).pop(finishedBackup);
  }

  _onValue1Checked(state) {
    setState(() {
      value1Checked = state;
    });
  }

  _onValue2Checked(state) {
    setState(() {
      value2Checked = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
      AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(dic.restoreSeed)),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(dic.backTips_1,
                        style: theme.headlineSmall!.copyWith(
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.normal)),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(dic.backTips_2,
                        style: theme.headlineSmall!.copyWith(
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                            color: Color(0x80000000))),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 0),
                    child: Text(dic.backTips_3,
                        style: theme.headlineSmall!.copyWith(
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                            color: Color(0x80000000))),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  CheckItem(
                    onChecked: _onValue1Checked,
                    checked: value1Checked,
                    text: dic.mnemonicLost,
                  ),
                  Container(height: 20,),
                  CheckItem(
                    onChecked: _onValue2Checked,
                    checked: value2Checked,
                    text: dic.protectMnemonic,
                  ),
                  Container(height: 20,),
                  Container(
                    padding: EdgeInsets.only(left: 18, right: 18, top: 12, bottom: 30),
                    child: NormalButton(
                      disabled: !value1Checked || !value2Checked,
                      text: dic.next,
                      onPressed: () => _onNext(),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CheckItem extends StatelessWidget {
  CheckItem({
    required this.text,
    required this.checked,
    required this.onChecked,
  });

  final String text;
  final bool checked;
  final void Function(bool) onChecked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChecked(!checked);
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            height: 30,
            width: 30,
            alignment: Alignment.center,
            child: RoundCheckBox(
              size: 18,
              borderColor: Color(0x1A000000),
              isChecked: checked,
              checkedWidget: Icon(
                Icons.check,
                color: Colors.white,
                size: 10,
              ),
              uncheckedColor: Colors.white,
              checkedColor: Theme.of(context).primaryColor,
              onTap: (bool? checkedFlag) {
                onChecked(checkedFlag == true);
                // onChecked(checkedFlag == true);
              },
            ),
          ),
          Container(
            width: 10,
          ),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0x80000000),
                    fontWeight: FontWeight.w400,
                  )))
        ],
      ),
    );
  }
}
