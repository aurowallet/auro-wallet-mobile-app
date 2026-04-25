import 'package:auro_wallet/common/consts/testKeys.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/import/importSuccessPage.dart';
import 'package:auro_wallet/page/account/walletManagePage.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/common/consts/enums.dart';


class ImportPrivateKeyPage extends StatefulWidget {
  const ImportPrivateKeyPage(this.store);

  static final String route = '/wallet/importprivate';
  final AppStore store;

  @override
  _ImportPrivateKeyPageState createState() => _ImportPrivateKeyPageState(store);
}

class _ImportPrivateKeyPageState extends State<ImportPrivateKeyPage> {
  _ImportPrivateKeyPageState(this.store);

  final AppStore store;
  final TextEditingController _privateKeyCtrl = new TextEditingController();

  bool submitting = false;

  @override
  void initState() {
    super.initState();

  }
  @override
  void dispose() {
    super.dispose();
    _privateKeyCtrl.dispose();
  }

  void _handleSubmit() async {
    UI.unfocus(context);
    AppLocalizations dic = AppLocalizations.of(context)!;
    String privateKey = _privateKeyCtrl.text.trim();
    bool isPrivateKeyValid = await webApi.account.isPrivateKeyValid(privateKey);
    if (!mounted) return;
    if (!isPrivateKeyValid) {
      UI.toast(dic.privateError);
      return;
    }
    Map params = ModalRoute.of(context)!.settings.arguments as Map;
    String accountName = params["accountName"];
    
    // Check if password is already set (from initialization flow)
    String password = store.wallet!.newWalletParams.password;
    if (password.isEmpty) {
      // Password not set, show dialog (from wallet management flow)
      final dialogPassword = await UI.showPasswordDialog(
          context: context,
          wallet: store.wallet!.currentWallet,
          inputPasswordRequired: true
      );
      if (!mounted) return;
      if (dialogPassword == null) {
        return;
      }
      password = dialogPassword;
    }
    
    setState(() {
      submitting = true;
    });
    var isSuccess = await webApi.account.createWalletByPrivateKey(accountName, privateKey, password, context: context, source: WalletSource.outside);
    if (!mounted) return;
    setState(() {
      submitting = false;
    });
    if(isSuccess) {
      store.wallet!.resetNewWallet();
      // Check if coming from initialization flow or wallet management
      bool fromInitialization = params["fromInitialization"] == true;
      if (fromInitialization) {
        // From initialization - go to success page and clear navigation stack
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
  }
  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic.import),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 20),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputItem(
                      key: TestKeys.privateKeyInput,
                      padding: EdgeInsets.zero,
                      inputPadding: EdgeInsets.only(top: 20),
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000).withValues(alpha: 0.8),
                      ),
                      label: dic.pleaseInputPriKey,
                      controller: _privateKeyCtrl,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 30),
                  child: NormalButton(
                    key: TestKeys.importButton,
                    submitting: submitting,
                    color: ColorsUtil.hexColor(0x6D5FFE),
                    text: dic.confirm,
                    onPressed: _handleSubmit,
                  )
              ),

            ],
          )
        ),
      ),
    );
  }
}