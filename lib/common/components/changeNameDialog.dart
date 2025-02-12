import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/inputItem.dart';

class ChangeNameDialog extends StatefulWidget {
  ChangeNameDialog({this.onOk, this.onCancel});

  final Function? onOk;
  final Function? onCancel;

  @override
  _ChangeNameDialogDialogState createState() => _ChangeNameDialogDialogState();
}

class _ChangeNameDialogDialogState extends State<ChangeNameDialog> {
  final TextEditingController _nameCtrl = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;

    return Dialog(
      clipBehavior: Clip.hardEdge,
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(dic.renameAccountName,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: InputItem(
                  maxLength: 16,
                  initialValue: '',
                  placeholder: dic.accountNameLimit,
                  padding: EdgeInsets.only(top: 20),
                  controller: _nameCtrl,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30),
                height: 1,
                color: Colors.black.withValues(alpha: 0.05),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                    child: SizedBox(
                  height: 48,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          // side: BorderSide(color: Colors.red)
                        ),
                        textStyle: TextStyle(color: Colors.black)),
                    child: Text(dic.cancel,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    onPressed: () {
                      if (widget.onCancel != null) {
                        widget.onCancel!();
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                )),
                Container(
                  width: 0.5,
                  height: 48,
                  color: Colors.black.withValues(alpha: 0.1),
                ),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            // side: BorderSide(color: Colors.red)
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(dic.confirm,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600))
                        ],
                      ),
                      onPressed: () {
                        if (widget.onOk != null) {
                          widget.onOk!();
                        }
                        Navigator.of(context).pop(_nameCtrl.text.trim());
                      },
                    ),
                  ),
                )
              ]),
            ],
          ),
        )
      ]),
    );
  }
}
