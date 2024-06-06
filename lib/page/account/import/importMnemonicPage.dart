import 'dart:async';
import 'dart:math';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:bip39/src/wordlists/english.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/page/account/import/importSuccessPage.dart';
import 'package:auro_wallet/common/consts/enums.dart';

class ImportMnemonicPage extends StatefulWidget {
  const ImportMnemonicPage(this.store);

  static final String route = '/wallet/import_mnemonic';
  final AppStore store;

  @override
  _ImportMnemonicPageState createState() => _ImportMnemonicPageState(store);
}

class _ImportMnemonicPageState extends State<ImportMnemonicPage> {
  _ImportMnemonicPageState(this.store);

  final AppStore store;
  final TextEditingController _mnemonicCtrl = new TextEditingController();

  List<String> tips = [];
  bool submitting = false;
  String? errorMsg;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mnemonicCtrl.addListener(onTextChange);
    });
  }

  void onTextChange() {
    final selection = _mnemonicCtrl.value.selection;
    RegExp blank = new RegExp(r'\s$');
    final text = _mnemonicCtrl.value.text.replaceAll(blank, ' ');
    if (!selection.isValid) {
      return;
    }
    final before = selection.textBefore(text);
    final after = selection.textAfter(text);
    print('after'+  after);
    print('before' + before);
    if (errorMsg != null) {
      setState(() {
        errorMsg = null;
      });
    }
    if (after.isEmpty && !blank.hasMatch(before)) {
      String? lastChars = new RegExp(r'[\w]+$').stringMatch(before);
      if (lastChars != null) {
        List<String> words = WORDLIST.where((word) => word.lastIndexOf(lastChars) == 0).toList();
        List<String> shortWords = words.sublist(0, min(words.length, 10));
        if (!(words.length == 1 && words[0] == lastChars)) {
          setState(() {
            tips = shortWords;
          });
          return;
        }
      }
    }
    setState(() {
      tips = [];
    });
  }

  @override
  void dispose() {
    super.dispose();
    _mnemonicCtrl.dispose();
  }
  Future<bool> _checkAccountDuplicate(Map<String, dynamic> acc) async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    int index = store.wallet!.walletList.indexWhere((i) => i.id == acc['pubKey']);
    if (index > -1) {
      setState(() {
        errorMsg = dic.improtRepeat;
      });
      return true;
    }
    return false;
  }
  void _handleSubmit() async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    String mnemonic = _mnemonicCtrl.text.trim().split(RegExp(r"(\s)")).join(' ');
    bool isMnemonicValid = webApi.account.isMnemonicValid(mnemonic);
    if (!isMnemonicValid) {
      setState(() {
        errorMsg = dic.seed_error;
      });
      return;
    }
    setState(() {
      submitting = true;
    });
    widget.store.wallet!.setNewWalletSeed(mnemonic, WalletStore.seedTypeMnemonic);
    var acc = await webApi.account.importWalletByWalletParams();
    if(acc['error']!=null){
      UI.toast(acc['error']['message']);
       setState(() {
        submitting = false;
      });
      return ;
    }

    final duplicated = await _checkAccountDuplicate(acc);
    if (duplicated) {
      return;
    }
    await webApi.account.saveWallet(
        acc,
        context: context,
        seedType: WalletStore.seedTypeMnemonic,
        walletSource:  WalletSource.outside
    );
    widget.store.wallet!.resetNewWallet();
    await Navigator.pushNamedAndRemoveUntil(context, ImportSuccessPage.route, (Route<dynamic> route) => false, arguments: {
      'type': 'restore'
    });
  }
  void selectWord(String word) {
    final text = _mnemonicCtrl.text.replaceAll(new RegExp(r'[\w]+$'), word + ' ');

    _mnemonicCtrl.value = TextEditingValue(
        text: text,
        selection: TextSelection.fromPosition(TextPosition( affinity: TextAffinity.downstream, offset: text.length))
    );
  }
  Widget renderTips(BuildContext context) {
    return SizedBox(
      height: 27,
      child: ListView.separated(
        itemCount: tips.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => GestureDetector(
          child: Container(
            height: 27,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: Color(0x0D000000),
              borderRadius: BorderRadius.all(Radius.circular(4))
            ),
            child: Center(
              child: Text(tips[index], style: TextStyle(
                  fontSize: 14,
                  color: Colors.black
              ),),
            ),
          ),
          onTap: () {
            selectWord(tips[index]);
          },
        ),
        separatorBuilder: (context, index) => SizedBox(
          height: 27,
          width: 10,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.restoreWallet),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body:  SafeArea(
        maintainBottomViewPadding: true,
        child: Stack(
          children: [
            Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Wrap(
                        children: [
                          InputItem(
                            initialValue: '',
                            labelStyle: TextStyle(
                                fontSize: 14
                            ),
                            label: dic.inputSeed,
                            controller: _mnemonicCtrl,
                            backgroundColor: Colors.transparent,
                            borderColor: ColorsUtil.hexColor(0xE5E5E5),
                            focusColor: Theme.of(context).primaryColor,
                            inputPadding: EdgeInsets.only(top: 20),
                            maxLines: 6,
                            isError: errorMsg != null,
                          ),
                          errorMsg != null ?  Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(errorMsg!, style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFD65A5A)
                          ),),) : Container()
                        ],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 30),
                        child: NormalButton(
                          submitting: submitting,
                          color: ColorsUtil.hexColor(0x6D5FFE),
                          text: dic.confirm,
                          onPressed: _handleSubmit,
                        )
                    )
                  ],
                )
            ),
            Positioned(
                bottom: max(MediaQuery.of(context).viewInsets.bottom - MediaQuery.of(context).viewPadding.bottom + 10, 90),
                left: 20,
                right: 20,
                child: renderTips(context),
            )
          ],
        ),
      ),

      // Stack(
      //   children: [
      //     Positioned(
      //         bottom: max(MediaQuery.of(context).viewInsets.bottom, 60),
      //         left: 0,
      //         right: 0,
      //         child: renderTips(context),
      //     )
      //   ],
      // ),
    );
  }
}