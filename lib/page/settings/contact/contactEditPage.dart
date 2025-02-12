import 'package:auro_wallet/common/components/inputErrorTip.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/store/settings/types/contactData.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/common/components/normalButton.dart';

class ContactEditPage extends StatefulWidget {
  final SettingsStore store;
  static final String route = '/profile/edit_contacts';
  ContactEditPage(this.store);
  @override
  _ContactEditPageState createState() => _ContactEditPageState();
}

class _ContactEditPageState extends State<ContactEditPage> {

  final Api api = webApi;
  final TextEditingController _nameCtrl = new TextEditingController();
  final TextEditingController _addressCtrl = new TextEditingController();
  FocusNode _addressFocus = new FocusNode();
  bool addressError = false;
  bool submitDisabled = true;
  bool isEdit = false;
  String? errorText;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map args =
      ModalRoute.of(context)!.settings.arguments as Map;
      final initName = args['name'] as String?;
      final initAddress = args['address'] as String?;
      if (initName != null) {
        _nameCtrl.text = initName;
      }
      if (initAddress != null) {
        _addressCtrl.text = initAddress;
        setState(() {
          isEdit = true;
        });
      }
      _monitorSummitStatus();
      _addressCtrl.addListener(_monitorSummitStatus);
      _nameCtrl.addListener(_monitorSummitStatus);
    });
  }
  @override
  void dispose() {
    super.dispose();
    _addressCtrl.dispose();
    _nameCtrl.dispose();
  }

  void _monitorSummitStatus() {
    if (_addressCtrl.text.isEmpty || _nameCtrl.text.isEmpty) {
      if (!submitDisabled) {
        setState((){
          submitDisabled = true;
        });
      }
    } else if(submitDisabled) {
      setState((){
        submitDisabled = false;
      });
    }
  }

  void _confirm() async {
    _addressFocus.unfocus();
    final valid = await _validateAddress(_addressCtrl.text);
    if (!valid) {
      return null;
    }
    Navigator.of(context).pop([_nameCtrl.text, _addressCtrl.text]);
  }

  Future<bool> _validateAddress(String address) async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    bool isValid = await webApi.account.isAddressValid(address);
    String? error;
    if (!isValid) {
      error = dic.invalidContact;
    }
    if (!isEdit && isValid && widget.store.contactList.any((element) => element.address == address)) {
      error = dic.repeatContact;
    }
    setState(() {
      errorText = error;
      addressError = error != null;
    });
    print('errorText');
    print(errorText);
    return error == null;
  }

  void _onDelete() async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final name = args['name'] as String;
    final address = args['address'] as String;
    bool? rejected = await UI.showConfirmDialog(context: context, title: dic.deleteaddress, contents: [], okText: dic.confirm, cancelText: dic.cancel);
    if (rejected != true) {
      return;
    }
    await widget.store.removeContact(new ContactData(name: name, address: address));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? dic.editaddress : dic.addaddress),
        centerTitle: true,
        actions: isEdit ? [
          TextButton(
            child: Text(dic.delete, style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFD65A5A)
            ),),
            onPressed: _onDelete,
          )
        ] : [],
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  children: <Widget>[
                    InputItem(
                      padding: const EdgeInsets.only(top: 0),
                      label: dic.name,
                      controller: _nameCtrl,
                    ),
                    InputItem(
                      label: dic.address,
                      focusNode: _addressFocus,
                      padding: EdgeInsets.only(top: 22),
                      controller: _addressCtrl,
                      maxLines: 2,
                      isError: addressError,
                    ),
                    InputErrorTip(
                      padding: EdgeInsets.only(top: 8),
                      ctrl: _addressCtrl,
                      message: errorText ?? '',
                      asyncValidate: _validateAddress,
                      keepShow: false,
                      hideIcon: true,
                      focusNode: _addressFocus,
                    ),
                  ]
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 38, right: 38, top: 12, bottom: 30),
              child: NormalButton(
                disabled: addressError || _nameCtrl.text.isEmpty,
                text: dic.confirm,
                onPressed: _confirm ,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

