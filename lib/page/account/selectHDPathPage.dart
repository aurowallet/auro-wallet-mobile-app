import 'package:auro_wallet/common/components/customStyledText.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/homePage.dart';
import 'package:auro_wallet/page/account/walletManagePage.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auro_wallet/common/components/inputItem.dart';

class SelectHDPathParams {
  SelectHDPathParams({
    required this.defaultName,
    this.fromInitialization = false,
  });

  final String defaultName;
  final bool fromInitialization;
}

class SelectHDPathPage extends StatefulWidget {
  const SelectHDPathPage(this.store);

  static final String route = '/wallet/selectHDPath';
  final AppStore store;

  @override
  _SelectHDPathPageState createState() => _SelectHDPathPageState();
}

class _SelectHDPathPageState extends State<SelectHDPathPage> {
  final TextEditingController _accountIndexCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _accountIndexCtrl.text = '0';
    });
  }

  @override
  void dispose() {
    _accountIndexCtrl.dispose();
    super.dispose();
  }

  void _handleNext() async {
    final params =
        ModalRoute.of(context)!.settings.arguments as SelectHDPathParams;
    final accountIndex = int.tryParse(_accountIndexCtrl.text) ?? 0;
    final accountName = params.defaultName;

    setState(() {
      _submitting = true;
    });

    // Check if password is already set (from initialization flow)
    String password = widget.store.wallet!.newWalletParams.password;
    if (password.isEmpty) {
      // Password not set, show dialog (from wallet management flow)
      final dialogPassword = await UI.showPasswordDialog(
        context: context,
        wallet: widget.store.wallet!.currentWallet,
        inputPasswordRequired: true,
      );
      if (dialogPassword == null) {
        setState(() {
          _submitting = false;
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
      if (params.fromInitialization) {
        // From initialization - go to home, then push WalletManagePage
        widget.store.wallet!.resetNewWallet();
        final navigator = Navigator.of(context);
        navigator.pushNamedAndRemoveUntil(
          HomePage.route,
          (Route<dynamic> route) => false,
        );
        navigator.pushNamed(WalletManagePage.route);
      } else {
        // From wallet management - go back to WalletManagePage
        Navigator.popUntil(context,
            (route) => route.settings.name == WalletManagePage.route);
      }
    }

    if (mounted) {
      setState(() {
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic.selectHdPath),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    CustomStyledText(
                      text: dic.hdPathDesc,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 24),
                    // HD Path selector
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "m / 44' / 12586'/",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF666666),
                          ),
                        ),
                        Container(
                          width: 60,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: InputItem(
                            controller: _accountIndexCtrl,
                            padding: EdgeInsets.zero,
                            borderRadius: 6,
                            textAlign: TextAlign.center,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                          ),
                        ),
                        Text(
                          "' / 0 / 0",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 30),
                child: NormalButton(
                  submitting: _submitting,
                  color: ColorsUtil.hexColor(0x594AF1),
                  text: dic.next,
                  onPressed: _handleNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
