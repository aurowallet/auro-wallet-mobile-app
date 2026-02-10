import 'package:auro_wallet/common/components/termsDialog.dart';
import 'package:auro_wallet/common/consts/testKeys.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/setNewWalletPasswordPage.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateAccountEntryPage extends StatelessWidget {
  CreateAccountEntryPage(this.store, this.changeLang);

  static final String route = '/account/entry';
  final SettingsStore store;
  final Function changeLang;

  /// Check and show terms dialog if not agreed yet
  Future<bool> _checkTermsAgreement(BuildContext context) async {
    if (store.termsAgreed) {
      return true;
    }
    bool? agree = await showDialog<bool?>(
      context: context,
      builder: (_) {
        return TermsDialog(store: store);
      },
    );
    if (agree == true) {
      await store.setTermsAgreed(true);
      return true;
    }
    return false;
  }

  void _onCreateWallet(BuildContext context) async {
    if (!await _checkTermsAgreement(context)) return;
    Navigator.pushNamed(context, SetNewWalletPasswordPage.route,
        arguments: {"type": "create"});
  }

  void _onRestoreWallet(BuildContext context) async {
    if (!await _checkTermsAgreement(context)) return;
    _showRestoreOptions(context);
  }

  void _showRestoreOptions(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                dic.importWallet,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _RestoreOptionItem(
              title: dic.mnemonicPhrase,
              subtitle: dic.mnemonicImportDesc,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, SetNewWalletPasswordPage.route,
                    arguments: {"type": "import"});
              },
            ),
            _RestoreOptionItem(
              title: dic.privateKey,
              subtitle: dic.privateKeyImportDesc,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, SetNewWalletPasswordPage.route,
                    arguments: {"type": "privateKey"});
              },
            ),
            _RestoreOptionItem(
              title: 'Keystore',
              subtitle: dic.keystoreImportDesc,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, SetNewWalletPasswordPage.route,
                    arguments: {"type": "keystore"});
              },
            ),
            _RestoreOptionItem(
              title: dic.hardwareWallet,
              subtitle: dic.ledgerImportDesc,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, SetNewWalletPasswordPage.route,
                    arguments: {"type": "ledger"});
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    var theme = Theme.of(context).textTheme;
    return Container(
      color: Colors.white,
      child: SafeArea(
          maintainBottomViewPadding: true,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: null,
              title: null,
              toolbarHeight: 0,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              actions: null,
            ),
            resizeToAvoidBottomInset: false,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(height: 50),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: MediaQuery.of(context).size.width - 40,
                              margin: EdgeInsets.only(left: 20),
                              child: SvgPicture.asset(
                                "assets/images/entry/desc.svg",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Image.asset(
                      "assets/images/entry/auro_logo.png",
                      width: MediaQuery.of(context).size.width * (245 / 375),
                      height: MediaQuery.of(context).size.width *
                          (245 / 375) *
                          (221 / 245),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 38, right: 38),
                  child: ElevatedButton(
                    key: TestKeys.createWalletButton,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      backgroundColor: ColorsUtil.hexColor(0x594AF1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      _onCreateWallet(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset("assets/images/entry/icon_add.svg"),
                        SizedBox(width: 8),
                        Text(dic.createWallet,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 38, right: 38),
                  child: OutlinedButton(
                    key: TestKeys.restoreWalletButton,
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: Color.fromRGBO(0, 0, 0, 0.10),
                      ),
                    ),
                    onPressed: () {
                      _onRestoreWallet(context);
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset(
                            "assets/images/entry/icon_restore.svg"),
                        SizedBox(width: 8),
                        Text(dic.restoreWallet,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 0),
                  child: Text(
                    dic.restoreTip,
                    style: theme.bodySmall
                        ?.copyWith(color: ColorsUtil.hexColor(0xCCCCCC)),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 31, 0, 24),
                  child: Text(
                    'aurowallet.com',
                    style: theme.bodySmall
                        ?.copyWith(color: ColorsUtil.hexColor(0xB9B9B9)),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class _RestoreOptionItem extends StatelessWidget {
  const _RestoreOptionItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorsUtil.hexColor(0x999999),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: ColorsUtil.hexColor(0xCCCCCC),
            ),
          ],
        ),
      ),
    );
  }
}
