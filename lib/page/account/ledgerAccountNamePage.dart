import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/import/importSuccessPage.dart';
import 'package:auro_wallet/page/account/walletManagePage.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/services.dart';

class LedgerAccountNameParams {
  LedgerAccountNameParams({
    required this.defaultName,
    this.fromInitialization = false,
  });

  final String defaultName;
  final bool fromInitialization;
}

class LedgerAccountNamePage extends StatefulWidget {
  const LedgerAccountNamePage(this.store);

  static final String route = '/wallet/ledgerAccountName';
  final AppStore store;

  @override
  _LedgerAccountNamePageState createState() =>
      _LedgerAccountNamePageState(store);
}

class _LedgerAccountNamePageState extends State<LedgerAccountNamePage> {
  _LedgerAccountNamePageState(this.store);

  final AppStore store;
  final TextEditingController _accountIndexCtrl = new TextEditingController();
  final TextEditingController _nameCtrl = new TextEditingController();
  bool visibility = false;
  bool importing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _accountIndexCtrl.text = '0';
    });
  }

  void _onToggle() {
    setState(() {
      visibility = !visibility;
      // widget.nonceCtrl.clear();
      // widget.feeCtrl.clear();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameCtrl.dispose();
  }

  void _handleSubmit() async {
    LedgerAccountNameParams params =
        ModalRoute.of(context)!.settings.arguments as LedgerAccountNameParams;
    // Use input name or default name as fallback
    String accountName = _nameCtrl.text.trim();
    if (accountName.isEmpty) {
      accountName = params.defaultName;
    }
    final accountIndex = int.tryParse(_accountIndexCtrl.text) ?? 0;
    setState(() {
      importing = true;
    });
    
    // Check if password is already set (from initialization flow)
    String password = store.wallet!.newWalletParams.password;
    if (password.isEmpty) {
      // Password not set, show dialog (from wallet management flow)
      final dialogPassword = await UI.showPasswordDialog(
          context: context,
          wallet: store.wallet!.currentWallet,
          inputPasswordRequired: true);
      if (dialogPassword == null) {
        setState(() {
          importing = false;
        });
        return;
      }
      password = dialogPassword;
    }
    
    bool? generated = await UI.showImportLedgerDialog(
      context: context,
      accountIndex: accountIndex,
      generateAddress: true,
      accountName: accountName,
      password: password,
    );
    if (generated == true) {
      // Check if coming from initialization flow or wallet management
      if (params.fromInitialization) {
        // From initialization - go to success page and clear navigation stack
        store.wallet!.resetNewWallet();
        Navigator.pushNamedAndRemoveUntil(
          context, 
          ImportSuccessPage.route, 
          (Route<dynamic> route) => false,
          arguments: {'type': 'restore'}
        );
      } else {
        // From wallet management
        Navigator.popUntil(context, (route) => route.settings.name == WalletManagePage.route);
      }
    }
    setState(() {
      importing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    LedgerAccountNameParams params =
        ModalRoute.of(context)!.settings.arguments as LedgerAccountNameParams;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.accountName),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      InputItem(
                        maxLength: 16,
                        label: dic.inputAccountName,
                        initialValue: '',
                        placeholder: params.defaultName,
                        controller: _nameCtrl,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: TextButton(
                            onPressed: _onToggle,
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Text(
                                    dic.advanceMode,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Positioned(
                                    right: 0,
                                    top: -1,
                                    child: Icon(
                                      !visibility
                                          ? Icons.arrow_drop_down
                                          : Icons.arrow_drop_up,
                                      size: 20,
                                    ))
                              ],
                            )),
                      ),
                      visibility
                          ? Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Wrap(
                                children: [
                                  Text(
                                    dic.selectHdPath,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black),
                                  ),
                                  Container(
                                    height: 12,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "m / 44' / 12586'/",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF666666)),
                                      ),
                                      Container(
                                        width: 60,
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        // height: 20,
                                        child: InputItem(
                                          controller: _accountIndexCtrl,
                                          padding: EdgeInsets.zero,
                                          borderRadius: 6,
                                          textAlign: TextAlign.center,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 3),
                                        ),
                                      ),
                                      Text(
                                        " ' / 0 / 0",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF666666)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          : Container()
                    ])),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 30),
                    child: NormalButton(
                      submitting: importing,
                      color: ColorsUtil.hexColor(0x6D5FFE),
                      text: dic.confirm,
                      onPressed: _handleSubmit,
                    ))
              ],
            ),
          )),
    );
  }
}
