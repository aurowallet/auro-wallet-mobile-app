import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/inputItem.dart';

class CustomNodeDialog extends StatefulWidget {
  CustomNodeDialog({this.onOk, this.onCancel, this.name, this.url});

  final bool Function(String name, String address)? onOk;
  final Function? onCancel;
  final String? name;
  final String? url;

  @override
  _CustomNodeDialogState createState() => _CustomNodeDialogState();
}

class _CustomNodeDialogState extends State<CustomNodeDialog> {

  final TextEditingController _nameCtrl = new TextEditingController();
  final TextEditingController _urlCtrl = new TextEditingController();

  bool _submitDisabled = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_monitorSummitStatus);
    _urlCtrl.addListener(_monitorSummitStatus);
  }

  @override
  void dispose() {
    super.dispose();
  }
  void _monitorSummitStatus() {
    if (_nameCtrl.text.isEmpty || _urlCtrl.text.isEmpty) {
      if (!_submitDisabled) {
        setState((){
          _submitDisabled = true;
        });
      }
    } else if(_submitDisabled) {
      setState((){
        _submitDisabled = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;
    var theme = Theme.of(context).textTheme;
    double height = MediaQuery.of(context).size.height;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: height * 0.7, minHeight: 0),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 0, bottom: 16),
              child: Text(dic['addNetWork']!, style: TextStyle(fontSize: 20)),
            ),
            Container(
              child: Text(dic['nodeAlert']!,
                  style: theme.headline5!.copyWith(
                      color: ColorsUtil.hexColor(0xFF3B48),
                      fontWeight: FontWeight.w500)),
            ),
            InputItem(
              initialValue: widget.name,
              placeholder: dic['networkName'],
              padding: EdgeInsets.only(top: 10),
              controller: _nameCtrl,
            ),
            Container(
              height: 16,
            ),
            Flexible(
              flex: 1,
              child: SingleChildScrollView(
                child: Wrap(
                  children: [
                    InputItem(
                      initialValue: widget.url,
                      placeholder: 'https://',
                      padding: EdgeInsets.only(top: 0),
                      controller: _urlCtrl,
                      maxLines: null,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 27,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 130, minHeight: 40),
                child: OutlineButton(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  highlightedBorderColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(dic['cancel']!,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor, fontSize: 16)),
                  onPressed: () {
                    if (widget.onCancel != null) {
                      widget.onCancel!();
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ),
              FlatButton(
                height: 40,
                minWidth: 130,
                color: Theme.of(context).primaryColor,
                shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(dic['confirm']!,
                        style: TextStyle(color: Colors.white, fontSize: 16))
                  ],
                ),
                disabledColor: Colors.black12,
                disabledTextColor: Colors.blueGrey,
                onPressed: _submitDisabled
                    ? null
                    : () {
                        if (widget.onOk != null) {
                          bool close =
                              widget.onOk!(_nameCtrl.text, _urlCtrl.text);
                          if (!close) {
                            return;
                          }
                        }
                        Navigator.of(context)
                            .pop([_nameCtrl.text, _urlCtrl.text]);
                      },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
